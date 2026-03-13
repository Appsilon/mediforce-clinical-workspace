# ============================================================
# TLG ID: T-14.1.1
# Title: Subject Disposition
# Population: All Enrolled Subjects
# Source: ADSL
# Method: Descriptive statistics
# ============================================================

source("/workspace/tlg_code/00_setup.R")

cat("Generating T-14.1.1: Subject Disposition...\n")

# ---- Read data ----
adsl <- read_adam("ADSL")

# ---- Filter population ----
analysis_data <- adsl %>% filter(ENRLFL == "Y")

# ---- Prepare disposition data ----
# Count enrolled
enrolled <- analysis_data %>%
  count(TRT01P, name = "enrolled_n")

# Count randomized
randomized <- analysis_data %>%
  filter(RANDFL == "Y") %>%
  count(TRT01P, name = "randomized_n")

# Count completed
completed <- analysis_data %>%
  filter(DCSREAS == "COMPLETED") %>%
  count(TRT01P, name = "completed_n")

# Count discontinued
discontinued <- analysis_data %>%
  filter(DCSREAS != "COMPLETED" & !is.na(DCSREAS)) %>%
  count(TRT01P, name = "discontinued_n")

# Count by discontinuation reason
dc_reasons <- analysis_data %>%
  filter(DCSREAS != "COMPLETED" & !is.na(DCSREAS)) %>%
  count(TRT01P, DCSREAS, name = "reason_n") %>%
  pivot_wider(names_from = DCSREAS, values_from = reason_n, values_fill = 0)

# Combine all counts
disposition <- enrolled %>%
  left_join(randomized, by = "TRT01P") %>%
  left_join(completed, by = "TRT01P") %>%
  left_join(discontinued, by = "TRT01P") %>%
  mutate(
    randomized_pct = ifelse(is.na(randomized_n), 0, round(randomized_n / enrolled_n * 100, 1)),
    completed_pct = ifelse(is.na(completed_n), 0, round(completed_n / enrolled_n * 100, 1)),
    discontinued_pct = ifelse(is.na(discontinued_n), 0, round(discontinued_n / enrolled_n * 100, 1))
  )

# Add total row
total_row <- data.frame(
  TRT01P = "Total",
  enrolled_n = sum(disposition$enrolled_n),
  randomized_n = sum(disposition$randomized_n, na.rm = TRUE),
  completed_n = sum(disposition$completed_n, na.rm = TRUE),
  discontinued_n = sum(disposition$discontinued_n, na.rm = TRUE),
  randomized_pct = round(sum(disposition$randomized_n, na.rm = TRUE) / sum(disposition$enrolled_n) * 100, 1),
  completed_pct = round(sum(disposition$completed_n, na.rm = TRUE) / sum(disposition$enrolled_n) * 100, 1),
  discontinued_pct = round(sum(disposition$discontinued_n, na.rm = TRUE) / sum(disposition$enrolled_n) * 100, 1)
)

disposition <- bind_rows(disposition, total_row)

# ---- Build table ----
tbl <- disposition %>%
  gt() %>%
  tab_header(
    title = "Subject Disposition",
    subtitle = "Population: All Enrolled Subjects — Study CDISCPILOT01"
  ) %>%
  cols_label(
    TRT01P = "",
    enrolled_n = "Enrolled, n",
    randomized_n = "Randomized, n",
    randomized_pct = "%",
    completed_n = "Completed study, n",
    completed_pct = "%",
    discontinued_n = "Discontinued study, n",
    discontinued_pct = "%"
  ) %>%
  fmt_number(
    columns = c(enrolled_n, randomized_n, completed_n, discontinued_n),
    decimals = 0
  ) %>%
  fmt_number(
    columns = c(randomized_pct, completed_pct, discontinued_pct),
    decimals = 1,
    pattern = "{x}%"
  ) %>%
  tab_spanner(
    label = "Placebo",
    columns = c(enrolled_n, randomized_n, randomized_pct, completed_n, completed_pct, discontinued_n, discontinued_pct),
    level = 1
  ) %>%
  tab_footnote(
    footnote = "Percentages based on the number of enrolled subjects.",
    locations = cells_column_labels(columns = c(randomized_pct, completed_pct, discontinued_pct))
  ) %>%
  tab_footnote(
    footnote = "Abbreviations: N = number of subjects in the population; n = number of subjects in the specified category.",
    locations = cells_title()
  ) %>%
  tab_source_note(
    source_note = "Source: ADSL"
  )

# ---- Export ----
output_file <- file.path(output_dir, "tables", "t_01_disp.html")
gt::gtsave(tbl, output_file)
cat("Saved to:", output_file, "\n")

cat("T-14.1.1 generation complete.\n")