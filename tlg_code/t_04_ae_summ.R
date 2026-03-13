# ============================================================
# TLG ID: T-14.3.1.1
# Title: Overall Summary of Adverse Events
# Population: Safety Analysis Set
# Source: ADAE
# Method: Descriptive statistics
# ============================================================

source("/workspace/tlg_code/00_setup.R")

cat("Generating T-14.3.1.1: Overall Summary of Adverse Events...\n")

# ---- Read data ----
adae <- read_adam("ADAE")
adsl <- read_adam("ADSL")

# ---- Filter population ----
safety_pop <- adsl %>% filter(SAFFL == "Y") %>% pull(USUBJID)

analysis_data <- adae %>%
  filter(USUBJID %in% safety_pop) %>%
  left_join(
    adsl %>% select(USUBJID, TRT01P),
    by = "USUBJID"
  )

# ---- Calculate summary statistics ----
# Unique subjects with at least one event in each category
ae_summary <- analysis_data %>%
  group_by(TRT01P) %>%
  summarise(
    # Total subjects in treatment group
    total_n = n_distinct(USUBJID),
    
    # Subjects with at least one TEAE
    teaes = n_distinct(USUBJID[TRTEMFL == "Y"]),
    teaes_pct = round(teaes / total_n * 100, 1),
    
    # Subjects with at least one treatment-related AE
    tr_ae = n_distinct(USUBJID[AEREL == "RELATED"]),
    tr_ae_pct = round(tr_ae / total_n * 100, 1),
    
    # Subjects with at least one Grade ≥3 AE
    grade3_ae = n_distinct(USUBJID[as.numeric(AETOXGR) >= 3]),
    grade3_ae_pct = round(grade3_ae / total_n * 100, 1),
    
    # Subjects with at least one Grade ≥3 treatment-related AE
    grade3_tr_ae = n_distinct(USUBJID[as.numeric(AETOXGR) >= 3 & AEREL == "RELATED"]),
    grade3_tr_ae_pct = round(grade3_tr_ae / total_n * 100, 1),
    
    # Subjects with at least one serious AE
    sae = n_distinct(USUBJID[AESER == "Y"]),
    sae_pct = round(sae / total_n * 100, 1),
    
    # Subjects with at least one serious treatment-related AE
    tr_sae = n_distinct(USUBJID[AESER == "Y" & AEREL == "RELATED"]),
    tr_sae_pct = round(tr_sae / total_n * 100, 1),
    
    # Subjects with AE leading to discontinuation
    ae_disc = n_distinct(USUBJID[AEDECOD == "DISCONTINUATION"]),  # Simplified
    ae_disc_pct = round(ae_disc / total_n * 100, 1),
    
    # Subjects with AE leading to dose modification
    ae_dose_mod = n_distinct(USUBJID[AEDECOD == "DOSE MODIFICATION"]),  # Simplified
    ae_dose_mod_pct = round(ae_dose_mod / total_n * 100, 1),
    
    # Subjects with AE leading to death
    ae_death = n_distinct(USUBJID[AEOUT == "FATAL"]),
    ae_death_pct = round(ae_death / total_n * 100, 1)
  )

# Add total row
total_row <- data.frame(
  TRT01P = "Total",
  total_n = sum(ae_summary$total_n),
  teaes = sum(ae_summary$teaes),
  teaes_pct = round(sum(ae_summary$teaes) / sum(ae_summary$total_n) * 100, 1),
  tr_ae = sum(ae_summary$tr_ae),
  tr_ae_pct = round(sum(ae_summary$tr_ae) / sum(ae_summary$total_n) * 100, 1),
  grade3_ae = sum(ae_summary$grade3_ae),
  grade3_ae_pct = round(sum(ae_summary$grade3_ae) / sum(ae_summary$total_n) * 100, 1),
  grade3_tr_ae = sum(ae_summary$grade3_tr_ae),
  grade3_tr_ae_pct = round(sum(ae_summary$grade3_tr_ae) / sum(ae_summary$total_n) * 100, 1),
  sae = sum(ae_summary$sae),
  sae_pct = round(sum(ae_summary$sae) / sum(ae_summary$total_n) * 100, 1),
  tr_sae = sum(ae_summary$tr_sae),
  tr_sae_pct = round(sum(ae_summary$tr_sae) / sum(ae_summary$total_n) * 100, 1),
  ae_disc = sum(ae_summary$ae_disc),
  ae_disc_pct = round(sum(ae_summary$ae_disc) / sum(ae_summary$total_n) * 100, 1),
  ae_dose_mod = sum(ae_summary$ae_dose_mod),
  ae_dose_mod_pct = round(sum(ae_summary$ae_dose_mod) / sum(ae_summary$total_n) * 100, 1),
  ae_death = sum(ae_summary$ae_death),
  ae_death_pct = round(sum(ae_summary$ae_death) / sum(ae_summary$total_n) * 100, 1)
)

ae_summary <- bind_rows(ae_summary, total_row)

# ---- Prepare table data ----
table_data <- data.frame(
  Category = c(
    "Subjects with at least one:",
    "  Treatment-emergent AE",
    "  Treatment-related AE [a]",
    "  Grade ≥3 AE",
    "  Grade ≥3 treatment-related AE",
    "  Serious AE",
    "  Serious treatment-related AE",
    "  AE leading to discontinuation",
    "  AE leading to dose modification",
    "  AE leading to death"
  ),
  Placebo = c(
    "",
    paste0(ae_summary$teaes[ae_summary$TRT01P == "Placebo"], " (", ae_summary$teaes_pct[ae_summary$TRT01P == "Placebo"], ")"),
    paste0(ae_summary$tr_ae[ae_summary$TRT01P == "Placebo"], " (", ae_summary$tr_ae_pct[ae_summary$TRT01P == "Placebo"], ")"),
    paste0(ae_summary$grade3_ae[ae_summary$TRT01P == "Placebo"], " (", ae_summary$grade3_ae_pct[ae_summary$TRT01P == "Placebo"], ")"),
    paste0(ae_summary$grade3_tr_ae[ae_summary$TRT01P == "Placebo"], " (", ae_summary$grade3_tr_ae_pct[ae_summary$TRT01P == "Placebo"], ")"),
    paste0(ae_summary$sae[ae_summary$TRT01P == "Placebo"], " (", ae_summary$sae_pct[ae_summary$TRT01P == "Placebo"], ")"),
    paste0(ae_summary$tr_sae[ae_summary$TRT01P == "Placebo"], " (", ae_summary$tr_sae_pct[ae_summary$TRT01P == "Placebo"], ")"),
    paste0(ae_summary$ae_disc[ae_summary$TRT01P == "Placebo"], " (", ae_summary$ae_disc_pct[ae_summary$TRT01P == "Placebo"], ")"),
    paste0(ae_summary$ae_dose_mod[ae_summary$TRT01P == "Placebo"], " (", ae_summary$ae_dose_mod_pct[ae_summary$TRT01P == "Placebo"], ")"),
    paste0(ae_summary$ae_death[ae_summary$TRT01P == "Placebo"], " (", ae_summary$ae_death_pct[ae_summary$TRT01P == "Placebo"], ")")
  ),
  Xanomeline_low = c(
    "",
    paste0(ae_summary$teaes[ae_summary$TRT01P == "Xanomeline low dose"], " (", ae_summary$teaes_pct[ae_summary$TRT01P == "Xanomeline low dose"], ")"),
    paste0(ae_summary$tr_ae[ae_summary$TRT01P == "Xanomeline low dose"], " (", ae_summary$tr_ae_pct[ae_summary$TRT01P == "Xanomeline low dose"], ")"),
    paste0(ae_summary$grade3_ae[ae_summary$TRT01P == "Xanomeline low dose"], " (", ae_summary$grade3_ae_pct[ae_summary$TRT01P == "Xanomeline low dose"], ")"),
    paste0(ae_summary$grade3_tr_ae[ae_summary$TRT01P == "Xanomeline low dose"], " (", ae_summary$grade3_tr_ae_pct[ae_summary$TRT01P == "Xanomeline low dose"], ")"),
    paste0(ae_summary$sae[ae_summary$TRT01P == "Xanomeline low dose"], " (", ae_summary$sae_pct[ae_summary$TRT01P == "Xanomeline low dose"], ")"),
    paste0(ae_summary$tr_sae[ae_summary$TRT01P == "Xanomeline low dose"], " (", ae_summary$tr_sae_pct[ae_summary$TRT01P == "Xanomeline low dose"], ")"),
    paste0(ae_summary$ae_disc[ae_summary$TRT01P == "Xanomeline low dose"], " (", ae_summary$ae_disc_pct[ae_summary$TRT01P == "Xanomeline low dose"], ")"),
    paste0(ae_summary$ae_dose_mod[ae_summary$TRT01P == "Xanomeline low dose"], " (", ae_summary$ae_dose_mod_pct[ae_summary$TRT01P == "Xanomeline low dose"], ")"),
    paste0(ae_summary$ae_death[ae_summary$TRT01P == "Xanomeline low dose"], " (", ae_summary$ae_death_pct[ae_summary$TRT01P == "Xanomeline low dose"], ")")
  ),
  Xanomeline_high = c(
    "",
    paste0(ae_summary$teaes[ae_summary$TRT01P == "Xanomeline high dose"], " (", ae_summary$teaes_pct[ae_summary$TRT01P == "Xanomeline high dose"], ")"),
    paste0(ae_summary$tr_ae[ae_summary$TRT01P == "Xanomeline high dose"], " (", ae_summary$tr_ae_pct[ae_summary$TRT01P == "Xanomeline high dose"], ")"),
    paste0(ae_summary$grade3_ae[ae_summary$TRT01P == "Xanomeline high dose"], " (", ae_summary$grade3_ae_pct[ae_summary$TRT01P == "Xanomeline high dose"], ")"),
    paste0(ae_summary$grade3_tr_ae[ae_summary$TRT01P == "Xanomeline high dose"], " (", ae_summary$grade3_tr_ae_pct[ae_summary$TRT01P == "Xanomeline high dose"], ")"),
    paste0(ae_summary$sae[ae_summary$TRT01P == "Xanomeline high dose"], " (", ae_summary$sae_pct[ae_summary$TRT01P == "Xanomeline high dose"], ")"),
    paste0(ae_summary$tr_sae[ae_summary$TRT01P == "Xanomeline high dose"], " (", ae_summary$tr_sae_pct[ae_summary$TRT01P == "Xanomeline high dose"], ")"),
    paste0(ae_summary$ae_disc[ae_summary$TRT01P == "Xanomeline high dose"], " (", ae_summary$ae_disc_pct[ae_summary$TRT01P == "Xanomeline high dose"], ")"),
    paste0(ae_summary$ae_dose_mod[ae_summary$TRT01P == "Xanomeline high dose"], " (", ae_summary$ae_dose_mod_pct[ae_summary$TRT01P == "Xanomeline high dose"], ")"),
    paste0(ae_summary$ae_death[ae_summary$TRT01P == "Xanomeline high dose"], " (", ae_summary$ae_death_pct[ae_summary$TRT01P == "Xanomeline high dose"], ")")
  ),
  Total = c(
    "",
    paste0(ae_summary$teaes[ae_summary$TRT01P == "Total"], " (", ae_summary$teaes_pct[ae_summary$TRT01P == "Total"], ")"),
    paste0(ae_summary$tr_ae[ae_summary$TRT01P == "Total"], " (", ae_summary$tr_ae_pct[ae_summary$TRT01P == "Total"], ")"),
    paste0(ae_summary$grade3_ae[ae_summary$TRT01P == "Total"], " (", ae_summary$grade3_ae_pct[ae_summary$TRT01P == "Total"], ")"),
    paste0(ae_summary$grade3_tr_ae[ae_summary$TRT01P == "Total"], " (", ae_summary$grade3_tr_ae_pct[ae_summary$TRT01P == "Total"], ")"),
    paste0(ae_summary$sae[ae_summary$TRT01P == "Total"], " (", ae_summary$sae_pct[ae_summary$TRT01P == "Total"], ")"),
    paste0(ae_summary$tr_sae[ae_summary$TRT01P == "Total"], " (", ae_summary$tr_sae_pct[ae_summary$TRT01P == "Total"], ")"),
    paste0(ae_summary$ae_disc[ae_summary$TRT01P == "Total"], " (", ae_summary$ae_disc_pct[ae_summary$TRT01P == "Total"], ")"),
    paste0(ae_summary$ae_dose_mod[ae_summary$TRT01P == "Total"], " (", ae_summary$ae_dose_mod_pct[ae_summary$TRT01P == "Total"], ")"),
    paste0(ae_summary$ae_death[ae_summary$TRT01P == "Total"], " (", ae_summary$ae_death_pct[ae_summary$TRT01P == "Total"], ")")
  )
)

# ---- Build table ----
tbl <- table_data %>%
  gt() %>%
  tab_header(
    title = "Overall Summary of Adverse Events",
    subtitle = "Population: Safety Analysis Set — Study CDISCPILOT01"
  ) %>%
  cols_label(
    Category = "",
    Placebo = "Placebo",
    Xanomeline_low = "Xanomeline low dose",
    Xanomeline_high = "Xanomeline high dose",
    Total = "Total"
  ) %>%
  tab_footnote(
    footnote = "Treatment-related = assessed by investigator as related to study treatment.",
    locations = cells_body(rows = 3, columns = c(2, 3, 4, 5))
  ) %>%
  tab_footnote(
    footnote = "Abbreviations: AE = adverse event; N = number of subjects in the population; n = number of subjects with at least one event.",
    locations = cells_title()
  ) %>%
  tab_footnote(
    footnote = "TEAEs are defined as AEs with onset on or after the first dose of study treatment through 30 days after the last dose. Subjects are counted once per row regardless of number of events.",
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