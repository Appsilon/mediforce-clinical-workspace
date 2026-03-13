# ============================================================
# TLG ID: T-14.3.1.1
# Title: Overall Summary of Adverse Events
# Population: All Subjects
# Source: ADAE
# Method: Descriptive statistics
# ============================================================

source("/workspace/tlg_code/00_setup_simple.R")

cat("Generating T-14.3.1.1: Overall Summary of Adverse Events...\n")

# ---- Read data ----
adae <- read_adam("ADAE")
adsl <- read_adam("ADSL")

# Use all subjects
analysis_data <- adae %>%
  left_join(
    adsl %>% select(USUBJID, TRT01P),
    by = "USUBJID"
  ) %>%
  # Fill missing TRT01P with "Unknown"
  mutate(TRT01P = ifelse(is.na(TRT01P), "Unknown", TRT01P))

# ---- Calculate summary statistics ----
# Unique subjects with at least one event in each category
ae_summary <- analysis_data %>%
  group_by(TRT01P) %>%
  summarise(
    # Total subjects in treatment group
    total_n = n_distinct(USUBJID),
    
    # Subjects with at least one AE
    aes = n_distinct(USUBJID),
    aes_pct = round(aes / total_n * 100, 1),
    
    # Subjects with at least one treatment-related AE
    tr_ae = n_distinct(USUBJID[AEREL == "PROBABLE" | AEREL == "POSSIBLE"]),
    tr_ae_pct = round(tr_ae / total_n * 100, 1),
    
    # Subjects with at least one serious AE
    sae = n_distinct(USUBJID[AESER == "Y"]),
    sae_pct = round(sae / total_n * 100, 1)
  )

# Add total row
total_row <- data.frame(
  TRT01P = "Total",
  total_n = sum(ae_summary$total_n),
  aes = sum(ae_summary$aes),
  aes_pct = round(sum(ae_summary$aes) / sum(ae_summary$total_n) * 100, 1),
  tr_ae = sum(ae_summary$tr_ae),
  tr_ae_pct = round(sum(ae_summary$tr_ae) / sum(ae_summary$total_n) * 100, 1),
  sae = sum(ae_summary$sae),
  sae_pct = round(sum(ae_summary$sae) / sum(ae_summary$total_n) * 100, 1)
)

ae_summary <- bind_rows(ae_summary, total_row)

# ---- Prepare table data ----
table_data <- data.frame(
  Category = c(
    "Subjects with at least one:",
    "  Adverse event",
    "  Treatment-related AE",
    "  Serious AE"
  ),
  Placebo = c(
    "",
    paste0(ae_summary$aes[ae_summary$TRT01P == "Placebo"], " (", ae_summary$aes_pct[ae_summary$TRT01P == "Placebo"], ")"),
    paste0(ae_summary$tr_ae[ae_summary$TRT01P == "Placebo"], " (", ae_summary$tr_ae_pct[ae_summary$TRT01P == "Placebo"], ")"),
    paste0(ae_summary$sae[ae_summary$TRT01P == "Placebo"], " (", ae_summary$sae_pct[ae_summary$TRT01P == "Placebo"], ")")
  ),
  Xanomeline_low = c(
    "",
    paste0(ae_summary$aes[ae_summary$TRT01P == "Xanomeline low dose"], " (", ae_summary$aes_pct[ae_summary$TRT01P == "Xanomeline low dose"], ")"),
    paste0(ae_summary$tr_ae[ae_summary$TRT01P == "Xanomeline low dose"], " (", ae_summary$tr_ae_pct[ae_summary$TRT01P == "Xanomeline low dose"], ")"),
    paste0(ae_summary$sae[ae_summary$TRT01P == "Xanomeline low dose"], " (", ae_summary$sae_pct[ae_summary$TRT01P == "Xanomeline low dose"], ")")
  ),
  Xanomeline_high = c(
    "",
    paste0(ae_summary$aes[ae_summary$TRT01P == "Xanomeline high dose"], " (", ae_summary$aes_pct[ae_summary$TRT01P == "Xanomeline high dose"], ")"),
    paste0(ae_summary$tr_ae[ae_summary$TRT01P == "Xanomeline high dose"], " (", ae_summary$tr_ae_pct[ae_summary$TRT01P == "Xanomeline high dose"], ")"),
    paste0(ae_summary$sae[ae_summary$TRT01P == "Xanomeline high dose"], " (", ae_summary$sae_pct[ae_summary$TRT01P == "Xanomeline high dose"], ")")
  ),
  Total = c(
    "",
    paste0(ae_summary$aes[ae_summary$TRT01P == "Total"], " (", ae_summary$aes_pct[ae_summary$TRT01P == "Total"], ")"),
    paste0(ae_summary$tr_ae[ae_summary$TRT01P == "Total"], " (", ae_summary$tr_ae_pct[ae_summary$TRT01P == "Total"], ")"),
    paste0(ae_summary$sae[ae_summary$TRT01P == "Total"], " (", ae_summary$sae_pct[ae_summary$TRT01P == "Total"], ")")
  )
)

# ---- Build table ----
tbl <- table_data %>%
  gt() %>%
  tab_header(
    title = "Overall Summary of Adverse Events",
    subtitle = "Study CDISCPILOT01"
  ) %>%
  cols_label(
    Category = "",
    Placebo = "Placebo",
    Xanomeline_low = "Xanomeline low dose",
    Xanomeline_high = "Xanomeline high dose",
    Total = "Total"
  ) %>%
  tab_footnote(
    footnote = "Treatment-related = assessed by investigator as probable or possible.",
    locations = cells_body(rows = 3, columns = c(2, 3, 4, 5))
  ) %>%
  tab_footnote(
    footnote = "Abbreviations: AE = adverse event; N = number of subjects in the population; n = number of subjects with at least one event.",
    locations = cells_title()
  ) %>%
  tab_source_note(
    source_note = "Source: ADAE"
  )

# ---- Export ----
output_file <- file.path(output_dir, "tables", "t_04_ae_summ.html")
gt::gtsave(tbl, output_file)
cat("Saved to:", output_file, "\n")

cat("T-14.3.1.1 generation complete.\n")