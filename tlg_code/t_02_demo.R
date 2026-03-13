# ============================================================
# TLG ID: T-14.1.2
# Title: Demographics and Baseline Characteristics
# Population: Efficacy Population
# Source: ADSL
# Method: Descriptive statistics
# ============================================================

source("/workspace/tlg_code/00_setup.R")

cat("Generating T-14.1.2: Demographics and Baseline Characteristics...\n")

# ---- Read data ----
adsl <- read_adam("ADSL")

# ---- Filter population ----
analysis_data <- adsl %>% filter(EFFFL == "Y")

# ---- Prepare variables ----
# Create age groups
analysis_data <- analysis_data %>%
  mutate(
    AGEGR1 = case_when(
      AGE < 65 ~ "<65 years",
      AGE >= 65 ~ ">=65 years",
      TRUE ~ NA_character_
    ),
    # Create BMI if not present
    BMI = ifelse(!is.na(HEIGHT) & HEIGHT > 0 & !is.na(WEIGHT) & WEIGHT > 0,
                 WEIGHT / ((HEIGHT/100)^2), NA_real_)
  )

# ---- Build table ----
tbl <- analysis_data %>%
  select(TRT01P, AGE, AGEGR1, SEX, RACE, ETHNIC, WEIGHT, HEIGHT, BMI) %>%
  tbl_summary(
    by = TRT01P,
    type = list(
      c(AGE, WEIGHT, HEIGHT, BMI) ~ "continuous",
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
  modify_caption(
    caption = "Demographics and Baseline Characteristics",
    subtitle = "Population: Efficacy Population — Study CDISCPILOT01"
  ) %>%
  modify_footnote(
    update = everything() ~ "Abbreviations: BMI = body mass index; N = number of subjects in the population; n = number of subjects in specified category; SD = standard deviation."
  ) %>%
  bold_labels()

# ---- Export ----
output_file <- file.path(output_dir, "tables", "t_02_demo.html")
gt::gtsave(as_gt(tbl), output_file)
cat("Saved to:", output_file, "\n")

cat("T-14.1.2 generation complete.\n")