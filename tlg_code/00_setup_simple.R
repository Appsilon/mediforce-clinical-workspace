# ============================================================
# TLG Setup Script (Simplified)
# Study: CDISCPILOT01
# Generated: 2026-03-13
# ============================================================

# ---- Load required packages ----
required_pkgs <- c(
  "gtsummary", "gt", "ggplot2", "dplyr", "tidyr", "stringr",
  "survival", "emmeans", "broom",
  "readr", "tools"
)

missing <- required_pkgs[!sapply(required_pkgs, requireNamespace, quietly = TRUE)]
if (length(missing) > 0) {
  install.packages(missing, repos = "https://cloud.r-project.org")
}

library(gtsummary)
library(gt)
library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)
library(survival)
library(emmeans)
library(broom)
library(readr)

# ---- Path configuration ----
adam_dir <- "/workspace/data"
output_dir <- "/workspace/tlg_outputs"
code_dir <- "/workspace/tlg_code"

# Create output directories if they don't exist
dir.create(file.path(output_dir, "tables"), showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(output_dir, "figures"), showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(output_dir, "listings"), showWarnings = FALSE, recursive = TRUE)

# ---- ADaM data reading helper ----
read_adam <- function(dataset_name) {
  # Try CSV first
  csv_path <- file.path(adam_dir, paste0(tolower(dataset_name), ".csv"))
  if (file.exists(csv_path)) {
    return(read_csv(csv_path, show_col_types = FALSE))
  }
  
  # Try RDS
  rds_path <- file.path(adam_dir, paste0(tolower(dataset_name), ".rds"))
  if (file.exists(rds_path)) {
    return(readRDS(rds_path))
  }
  
  stop(paste("Dataset", dataset_name, "not found in", adam_dir))
}

# ---- Study metadata ----
study_id <- "CDISCPILOT01"
study_title <- "Safety and Efficacy of the Xanomeline Transdermal Therapeutic System (TTS) in Patients with Mild to Moderate Alzheimer's Disease"

# Treatment arms
treatment_arms <- c(
  "Placebo" = "Placebo",
  "Xanomeline low dose" = "Xanomeline low dose", 
  "Xanomeline high dose" = "Xanomeline high dose"
)

# ---- Helper functions ----

# Format p-values
format_pvalue <- function(p) {
  if (is.na(p)) return("NA")
  if (p < 0.001) return("<0.001")
  if (p < 0.01) return(sprintf("%.3f", p))
  return(sprintf("%.3f", p))
}

# Format confidence intervals
format_ci <- function(estimate, lower, upper, digits = 2) {
  sprintf("%.*f (%.*f, %.*f)", digits, estimate, digits, lower, digits, upper)
}

# Get treatment column names with N
get_treatment_cols_with_n <- function(data, trt_var = "TRT01P") {
  trt_counts <- data %>%
    count(!!sym(trt_var)) %>%
    mutate(col_name = paste0(!!sym(trt_var), " (N=", n, ")"))
  
  setNames(trt_counts$col_name, trt_counts[[trt_var]])
}

# ANCOVA helper
run_ancova <- function(data, response, baseline = NULL, covariates = c(), trt_var = "TRT01PN") {
  # Create formula
  if (!is.null(baseline)) {
    formula_str <- paste(response, "~", baseline, "+", trt_var)
  } else {
    formula_str <- paste(response, "~", trt_var)
  }
  
  if (length(covariates) > 0) {
    formula_str <- paste(formula_str, "+", paste(covariates, collapse = " + "))
  }
  
  formula <- as.formula(formula_str)
  
  # Fit model
  model <- lm(formula, data = data)
  
  # Get LS means
  emm <- emmeans(model, specs = trt_var)
  
  # Pairwise comparisons vs placebo
  contrasts <- pairs(emm, reverse = TRUE)
  
  # Extract results
  lsmeans_df <- as.data.frame(emm)
  contrasts_df <- as.data.frame(contrasts)
  
  list(
    model = model,
    lsmeans = lsmeans_df,
    contrasts = contrasts_df,
    formula = formula_str
  )
}

# ANOVA helper
run_anova <- function(data, response, covariates = c(), trt_var = "TRT01PN") {
  formula_str <- paste(response, "~", trt_var)
  
  if (length(covariates) > 0) {
    formula_str <- paste(formula_str, "+", paste(covariates, collapse = " + "))
  }
  
  formula <- as.formula(formula_str)
  
  # Fit model
  model <- lm(formula, data = data)
  
  # Get LS means
  emm <- emmeans(model, specs = trt_var)
  
  # Pairwise comparisons vs placebo
  contrasts <- pairs(emm, reverse = TRUE)
  
  # Extract results
  lsmeans_df <- as.data.frame(emm)
  contrasts_df <- as.data.frame(contrasts)
  
  list(
    model = model,
    lsmeans = lsmeans_df,
    contrasts = contrasts_df,
    formula = formula_str
  )
}

# Kaplan-Meier helper
run_km <- function(data, time_var, event_var, trt_var = "TRT01P") {
  formula <- as.formula(paste("Surv(", time_var, ",", event_var, ") ~", trt_var))
  surv_fit <- survfit(formula, data = data)
  
  # Log-rank test
  logrank <- survdiff(formula, data = data)
  
  list(
    surv_fit = surv_fit,
    logrank = logrank,
    formula = formula
  )
}

# ggplot2 study theme
study_theme <- function() {
  theme_bw() +
    theme(
      plot.title = element_text(size = 12, face = "bold"),
      plot.subtitle = element_text(size = 10),
      legend.position = "bottom",
      legend.title = element_blank(),
      panel.grid.minor = element_blank(),
      axis.title = element_text(size = 10),
      axis.text = element_text(size = 9)
    )
}

# Print startup message
cat("TLG setup complete for study:", study_id, "\n")
cat("ADaM data directory:", adam_dir, "\n")
cat("Output directory:", output_dir, "\n")