# ============================================================
# TLG ID: T-14.1.2
# Title: Demographics and Baseline Characteristics
# Population: All Subjects
# Source: ADSL
# Method: Descriptive statistics
# ============================================================

source("/workspace/tlg_code/00_setup_simple.R")

cat("Generating T-14.1.2: Demographics and Baseline Characteristics...\n")

# ---- Read data ----
adsl <- read_adam("ADSL")

# Use all subjects (since population flags not available)
analysis_data <- adsl

# ---- Prepare variables ----
# Create age groups
analysis_data <- analysis_data %>%
  mutate(
    AGEGR1 = case_when(
      AGE < 65 ~ "<65 years",
      AGE >= 65 ~ ">=65 years",
      TRUE ~ NA_character_
    )
  )

# ---- Build table ----
tbl <- analysis_data %>%
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
    stat_2 = "**Xanomeline low dose**",
    stat_3 = "**Xanomeline high dose**"
  ) %>%
  modify_header(
    label = "**Characteristic**",
    stat_0 = "**Total**",
    stat_1 = "**Placebo**",
    stat_2 = "**Xanomeline low dose**",
    stat_3 = "**Xanomeline high dose**"
  ) %>%
  modify_table_styling(
    columns = label,
    footnote = "Demographics and Baseline Characteristics\nStudy CDISCPILOT01"
  ) %>%
  modify_footnote(
    update = everything() ~ "Abbreviations: N = number of subjects in the population; n = number of subjects in specified category; SD = standard deviation."
  ) %>%
  bold_labels()

# ---- Export ----
output_file <- file.path(output_dir, "tables", "t_02_demo.html")
gt::gtsave(as_gt(tbl), output_file)
cat("Saved to:", output_file, "\n")

cat("T-14.1.2 generation complete.\n")