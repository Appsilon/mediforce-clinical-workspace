# ============================================================
# TLG ID: T-14.2.1
# Title: Primary Analysis: ADAS-Cog (11) at Week 24
# Population: Efficacy Population
# Source: ADEFF
# Method: ANCOVA with treatment as continuous variable
# ============================================================

source("/workspace/tlg_code/00_setup.R")

cat("Generating T-14.2.1: Primary Analysis: ADAS-Cog (11) at Week 24...\n")

# ---- Read data ----
adeff <- read_adam("ADEFF")
adsl <- read_adam("ADSL")

# ---- Filter population and data ----
# Get efficacy population
eff_pop <- adsl %>% filter(EFFFL == "Y") %>% pull(USUBJID)

# Filter ADEFF for ADAS-Cog at Week 24
analysis_data <- adeff %>%
  filter(
    USUBJID %in% eff_pop,
    PARAMCD == "ADAS11",
    AVISIT == "Week 24"
  ) %>%
  select(USUBJID, TRTP, AVAL, BASE) %>%
  left_join(
    adsl %>% select(USUBJID, TRT01P, TRT01PN, SITEGR1),
    by = "USUBJID"
  ) %>%
  mutate(
    CHG = AVAL - BASE,
    TRT01PN = as.numeric(TRT01PN)  # Convert to numeric for continuous treatment
  )

# ---- ANCOVA analysis ----
# Fit ANCOVA model
ancova_result <- run_ancova(
  data = analysis_data,
  response = "CHG",
  baseline = "BASE",
  covariates = c("SITEGR1"),
  trt_var = "TRT01PN"
)

# Extract LS means and contrasts
lsmeans <- ancova_result$lsmeans
contrasts <- ancova_result$contrasts

# Get treatment mapping
trt_mapping <- analysis_data %>%
  distinct(TRT01P, TRT01PN) %>%
  arrange(TRT01PN)

# ---- Prepare table data ----
# Counts by treatment
counts <- analysis_data %>%
  group_by(TRT01P) %>%
  summarise(
    n = n(),
    baseline_mean = mean(BASE, na.rm = TRUE),
    baseline_sd = sd(BASE, na.rm = TRUE),
    week24_mean = mean(AVAL, na.rm = TRUE),
    week24_sd = sd(AVAL, na.rm = TRUE)
  )

# Combine LS means with counts
table_data <- lsmeans %>%
  left_join(trt_mapping, by = c("TRT01PN" = "TRT01PN")) %>%
  left_join(counts, by = "TRT01P") %>%
  mutate(
    lsmean_se = paste0(
      sprintf("%.2f", emmean), " (", sprintf("%.3f", SE), ")"
    )
  )

# Prepare contrast data (vs placebo)
contrast_data <- contrasts %>%
  filter(grepl("Placebo", contrast)) %>%
  mutate(
    contrast_clean = gsub(" - Placebo", "", contrast),
    lsmean_diff_se = paste0(
      sprintf("%.2f", estimate), " (", sprintf("%.3f", SE), ")"
    ),
    ci = paste0(
      "(", sprintf("%.2f", lower.CL), ", ", sprintf("%.2f", upper.CL), ")"
    ),
    p_value = format_pvalue(p.value)
  ) %>%
  select(contrast_clean, lsmean_diff_se, ci, p_value)

# ---- Build table ----
# Create base table
tbl_df <- data.frame(
  Parameter = c(
    "n with post-baseline assessment",
    "Change from baseline at Week 24",
    "  LS Mean (SE)",
    "  LS Mean difference vs placebo (SE)",
    "  95% CI for difference",
    "  p-value vs placebo",
    "Baseline ADAS-Cog (11) score",
    "  Mean (SD)",
    "Week 24 ADAS-Cog (11) score",
    "  Mean (SD)"
  ),
  Placebo = c(
    as.character(counts$n[counts$TRT01P == "Placebo"]),
    "", table_data$lsmean_se[table_data$TRT01P == "Placebo"],
    "—", "—", "—",
    "", 
    paste0(sprintf("%.1f", counts$baseline_mean[counts$TRT01P == "Placebo"]), 
           " (", sprintf("%.2f", counts$baseline_sd[counts$TRT01P == "Placebo"]), ")"),
    "",
    paste0(sprintf("%.1f", counts$week24_mean[counts$TRT01P == "Placebo"]), 
           " (", sprintf("%.2f", counts$week24_sd[counts$TRT01P == "Placebo"]), ")")
  ),
  Xanomeline_low = c(
    as.character(counts$n[counts$TRT01P == "Xanomeline low dose"]),
    "", table_data$lsmean_se[table_data$TRT01P == "Xanomeline low dose"],
    contrast_data$lsmean_diff_se[contrast_data$contrast_clean == "Xanomeline low dose"],
    contrast_data$ci[contrast_data$contrast_clean == "Xanomeline low dose"],
    contrast_data$p_value[contrast_data$contrast_clean == "Xanomeline low dose"],
    "",
    paste0(sprintf("%.1f", counts$baseline_mean[counts$TRT01P == "Xanomeline low dose"]), 
           " (", sprintf("%.2f", counts$baseline_sd[counts$TRT01P == "Xanomeline low dose"]), ")"),
    "",
    paste0(sprintf("%.1f", counts$week24_mean[counts$TRT01P == "Xanomeline low dose"]), 
           " (", sprintf("%.2f", counts$week24_sd[counts$TRT01P == "Xanomeline low dose"]), ")")
  ),
  Xanomeline_high = c(
    as.character(counts$n[counts$TRT01P == "Xanomeline high dose"]),
    "", table_data$lsmean_se[table_data$TRT01P == "Xanomeline high dose"],
    contrast_data$lsmean_diff_se[contrast_data$contrast_clean == "Xanomeline high dose"],
    contrast_data$ci[contrast_data$contrast_clean == "Xanomeline high dose"],
    contrast_data$p_value[contrast_data$contrast_clean == "Xanomeline high dose"],
    "",
    paste0(sprintf("%.1f", counts$baseline_mean[counts$TRT01P == "Xanomeline high dose"]), 
           " (", sprintf("%.2f", counts$baseline_sd[counts$TRT01P == "Xanomeline high dose"]), ")"),
    "",
    paste0(sprintf("%.1f", counts$week24_mean[counts$TRT01P == "Xanomeline high dose"]), 
           " (", sprintf("%.2f", counts$week24_sd[counts$TRT01P == "Xanomeline high dose"]), ")")
  )
)

# Create gt table
tbl <- tbl_df %>%
  gt() %>%
  tab_header(
    title = "Primary Analysis: Change from Baseline in ADAS-Cog (11) Total Score at Week 24",
    subtitle = "Population: Efficacy Population — Study CDISCPILOT01"
  ) %>%
  cols_label(
    Parameter = "",
    Placebo = "Placebo",
    Xanomeline_low = "Xanomeline low dose",
    Xanomeline_high = "Xanomeline high dose"
  ) %>%
  tab_footnote(
    footnote = "From ANCOVA model with treatment as continuous variable, adjusted for baseline ADAS-Cog score and site. Two-sided test at α=0.05.",
    locations = cells_body(rows = 6, columns = c(2, 3, 4))
  ) %>%
  tab_footnote(
    footnote = "Abbreviations: ADAS-Cog = Alzheimer's Disease Assessment Scale - Cognitive Subscale; CI = confidence interval; LS = least squares; N = number of subjects in population; n = number of subjects with assessment; SD = standard deviation; SE = standard error.",
    locations = cells_title()
  ) %>%
  tab_footnote(
    footnote = "Missing data imputed using last observation carried forward (LOCF).",
    locations = cells_title()
  ) %>%
  tab_source_note(
    source_note = "Source: ADEFF"
  )

# ---- Export ----
output_file <- file.path(output_dir, "tables", "t_03_adascog_w24.html")
gt::gtsave(tbl, output_file)
cat("Saved to:", output_file, "\n")

cat("T-14.2.1 generation complete.\n")