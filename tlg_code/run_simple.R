# ============================================================
# Simple TLG Generation
# Study: CDISCPILOT01
# ============================================================

cat("========================================\n")
cat("Simple TLG Generation\n")
cat("Study: CDISCPILOT01\n")
cat("Date:", format(Sys.Date(), "%Y-%m-%d"), "\n")
cat("========================================\n\n")

# Load packages
library(gtsummary)
library(gt)
library(ggplot2)
library(dplyr)
library(tidyr)
library(readr)

# Create output directories
output_dir <- "/workspace/tlg_outputs"
dir.create(file.path(output_dir, "tables"), showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(output_dir, "figures"), showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(output_dir, "listings"), showWarnings = FALSE, recursive = TRUE)

# ---- 1. Demographics Table (T-14.1.2) ----
cat("1. Generating Demographics Table...\n")
adsl <- read_csv("/workspace/data/adsl.csv", show_col_types = FALSE)

# Create age groups
adsl <- adsl %>%
  mutate(
    AGEGR1 = case_when(
      AGE < 65 ~ "<65 years",
      AGE >= 65 ~ ">=65 years",
      TRUE ~ NA_character_
    )
  )

# Build table
tbl_demo <- adsl %>%
  select(TRT01P, AGE, AGEGR1, SEX, RACE, ETHNIC) %>%
  tbl_summary(
    by = TRT01P,
    type = list(
      c(AGE) ~ "continuous",
      c(AGEGR1, SEX, RACE, ETHNIC) ~ "categorical"
    ),
    statistic = list(
      all_continuous() ~ "{mean} ({sd})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    digits = list(
      all_continuous() ~ c(1, 2),
      all_categorical() ~ c(0, 1)
    ),
    missing = "no"
  ) %>%
  add_overall() %>%
  modify_header(
    label = "**Characteristic**",
    stat_0 = "**Total**",
    stat_1 = "**Placebo**",
    stat_2 = "**Xanomeline Low Dose**",
    stat_3 = "**Xanomeline High Dose**"
  ) %>%
  bold_labels()

# Export
output_file <- file.path(output_dir, "tables", "t_demographics.html")
gt::gtsave(as_gt(tbl_demo), output_file)
cat("  Saved to:", output_file, "\n")

# ---- 2. Adverse Events Summary (T-14.3.1.1) ----
cat("\n2. Generating Adverse Events Summary...\n")
adae <- read_csv("/workspace/data/adae.csv", show_col_types = FALSE)

# Calculate summary
ae_summary <- adae %>%
  group_by(TRT01P) %>%
  summarise(
    total_n = n_distinct(USUBJID),
    aes = n_distinct(USUBJID),
    aes_pct = round(aes / total_n * 100, 1),
    tr_ae = n_distinct(USUBJID[AEREL %in% c("PROBABLE", "POSSIBLE")]),
    tr_ae_pct = round(tr_ae / total_n * 100, 1),
    sae = n_distinct(USUBJID[AESER == "Y"]),
    sae_pct = round(sae / total_n * 100, 1)
  )

# Add total
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

# Create table
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
  Xanomeline_Low = c(
    "",
    paste0(ae_summary$aes[ae_summary$TRT01P == "Xanomeline Low Dose"], " (", ae_summary$aes_pct[ae_summary$TRT01P == "Xanomeline Low Dose"], ")"),
    paste0(ae_summary$tr_ae[ae_summary$TRT01P == "Xanomeline Low Dose"], " (", ae_summary$tr_ae_pct[ae_summary$TRT01P == "Xanomeline Low Dose"], ")"),
    paste0(ae_summary$sae[ae_summary$TRT01P == "Xanomeline Low Dose"], " (", ae_summary$sae_pct[ae_summary$TRT01P == "Xanomeline Low Dose"], ")")
  ),
  Xanomeline_High = c(
    "",
    paste0(ae_summary$aes[ae_summary$TRT01P == "Xanomeline High Dose"], " (", ae_summary$aes_pct[ae_summary$TRT01P == "Xanomeline High Dose"], ")"),
    paste0(ae_summary$tr_ae[ae_summary$TRT01P == "Xanomeline High Dose"], " (", ae_summary$tr_ae_pct[ae_summary$TRT01P == "Xanomeline High Dose"], ")"),
    paste0(ae_summary$sae[ae_summary$TRT01P == "Xanomeline High Dose"], " (", ae_summary$sae_pct[ae_summary$TRT01P == "Xanomeline High Dose"], ")")
  ),
  Total = c(
    "",
    paste0(ae_summary$aes[ae_summary$TRT01P == "Total"], " (", ae_summary$aes_pct[ae_summary$TRT01P == "Total"], ")"),
    paste0(ae_summary$tr_ae[ae_summary$TRT01P == "Total"], " (", ae_summary$tr_ae_pct[ae_summary$TRT01P == "Total"], ")"),
    paste0(ae_summary$sae[ae_summary$TRT01P == "Total"], " (", ae_summary$sae_pct[ae_summary$TRT01P == "Total"], ")")
  )
)

tbl_ae <- table_data %>%
  gt() %>%
  tab_header(
    title = "Overall Summary of Adverse Events",
    subtitle = "Study CDISCPILOT01"
  ) %>%
  cols_label(
    Category = "",
    Placebo = "Placebo",
    Xanomeline_Low = "Xanomeline Low Dose",
    Xanomeline_High = "Xanomeline High Dose",
    Total = "Total"
  )

# Export
output_file <- file.path(output_dir, "tables", "t_ae_summary.html")
gt::gtsave(tbl_ae, output_file)
cat("  Saved to:", output_file, "\n")

# ---- 3. AE Listing (L-16.3.4) ----
cat("\n3. Generating AE Listing...\n")
# Take first 50 rows for demonstration
listing_data <- adae %>%
  select(USUBJID, TRT01P, AEDECOD, AEBODSYS, AESTDTC, AESER, AEREL) %>%
  head(50)

tbl_listing <- listing_data %>%
  gt() %>%
  tab_header(
    title = "Listing of Adverse Events",
    subtitle = "Study CDISCPILOT01 (First 50 records)"
  ) %>%
  cols_label(
    USUBJID = "Subject ID",
    TRT01P = "Treatment",
    AEDECOD = "Adverse Event",
    AEBODSYS = "System Organ Class",
    AESTDTC = "Start Date",
    AESER = "Serious",
    AEREL = "Relationship"
  )

# Export
output_file <- file.path(output_dir, "listings", "l_ae_listing.html")
gt::gtsave(tbl_listing, output_file)
cat("  Saved to:", output_file, "\n")

# Also save as CSV
csv_file <- file.path(output_dir, "listings", "l_ae_listing.csv")
write_csv(listing_data, csv_file)
cat("  CSV saved to:", csv_file, "\n")

# ---- 4. Simple Figure: AE Count by Treatment ----
cat("\n4. Generating AE Count Figure...\n")
library(ggplot2)

ae_counts <- adae %>%
  group_by(TRT01P, AEDECOD) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(TRT01P) %>%
  slice_max(order_by = count, n = 10) %>%
  ungroup()

p <- ggplot(ae_counts, aes(x = reorder(AEDECOD, count), y = count, fill = TRT01P)) +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip() +
  labs(
    title = "Top 10 Adverse Events by Treatment",
    subtitle = "Study CDISCPILOT01",
    x = "Adverse Event",
    y = "Count",
    fill = "Treatment"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    legend.position = "bottom"
  )

# Export
output_file <- file.path(output_dir, "figures", "f_ae_counts.png")
ggsave(output_file, plot = p, width = 10, height = 7, dpi = 300)
cat("  Saved to:", output_file, "\n")

# ---- Summary ----
cat("\n========================================\n")
cat("Generation Complete\n")
cat("========================================\n")
cat("Outputs generated:\n")
cat("1. Demographics Table: t_demographics.html\n")
cat("2. AE Summary Table: t_ae_summary.html\n")
cat("3. AE Listing: l_ae_listing.html/.csv\n")
cat("4. AE Count Figure: f_ae_counts.png\n")
cat("\nAll files saved to:", output_dir, "\n")