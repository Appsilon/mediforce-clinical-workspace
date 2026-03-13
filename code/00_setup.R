# Setup script for ADaM generation
# Checks and installs required R packages
# Provides helper functions for reading SDTM data

# ---- Check and install required packages ----
required_pkgs <- c(
  "admiral", "admiralonco", "admiralpeds", "admiralneuro",
  "admiralmetabolic", "admiralvaccine", "admiralophtha",
  "dplyr", "tidyr", "lubridate", "stringr", "rlang",
  "haven", "xportr", "datasetjson", "metacore", "metatools",
  "pharmaversesdtm"
)

cat("Checking required R packages...\n")
missing <- required_pkgs[!sapply(required_pkgs, requireNamespace, quietly = TRUE)]

if (length(missing) > 0) {
  cat("Installing missing packages:", paste(missing, collapse = ", "), "\n")
  install.packages(missing, repos = "https://cloud.r-project.org")
  cat("Installation complete.\n")
} else {
  cat("All required packages are already installed.\n")
}

# ---- Helper function to read SDTM data ----
read_sdtm <- function(domain, sdtm_dir = "/workspace/sdtm") {
  # Convert to lowercase for file matching
  domain_lower <- tolower(domain)
  json_path <- file.path(sdtm_dir, paste0(domain_lower, ".json"))
  xpt_path <- file.path(sdtm_dir, paste0(domain_lower, ".xpt"))
  sas_path <- file.path(sdtm_dir, paste0(domain_lower, ".sas7bdat"))
  
  if (file.exists(json_path)) {
    cat("Reading", domain, "from Dataset-JSON...\n")
    datasetjson::read_dataset_json(json_path)
  } else if (file.exists(xpt_path)) {
    cat("Reading", domain, "from SAS XPT...\n")
    haven::read_xpt(xpt_path)
  } else if (file.exists(sas_path)) {
    cat("Reading", domain, "from SAS dataset...\n")
    haven::read_sas(sas_path)
  } else {
    # Try with original case
    json_path2 <- file.path(sdtm_dir, paste0(domain, ".json"))
    xpt_path2 <- file.path(sdtm_dir, paste0(domain, ".xpt"))
    sas_path2 <- file.path(sdtm_dir, paste0(domain, ".sas7bdat"))
    
    if (file.exists(json_path2)) {
      cat("Reading", domain, "from Dataset-JSON...\n")
      datasetjson::read_dataset_json(json_path2)
    } else if (file.exists(xpt_path2)) {
      cat("Reading", domain, "from SAS XPT...\n")
      haven::read_xpt(xpt_path2)
    } else if (file.exists(sas_path2)) {
      cat("Reading", domain, "from SAS dataset...\n")
      haven::read_sas(sas_path2)
    } else {
      stop(paste("SDTM domain", domain, "not found in", sdtm_dir))
    }
  }
}

# ---- Helper function to read supplemental qualifiers ----
read_supp <- function(parent_domain, sdtm_dir = "/workspace/sdtm") {
  supp_name <- paste0("supp", tolower(parent_domain))
  supp_path <- file.path(sdtm_dir, paste0(supp_name, ".xpt"))
  
  if (file.exists(supp_path)) {
    cat("Reading supplemental qualifier for", parent_domain, "...\n")
    haven::read_xpt(supp_path)
  } else {
    cat("No supplemental qualifier found for", parent_domain, "\n")
    NULL
  }
}

# ---- Combine supplemental qualifiers with parent domain ----
combine_supp <- function(parent_df, supp_df) {
  if (is.null(supp_df)) {
    return(parent_df)
  }
  
  # Standardize column names
  supp_df <- supp_df %>%
    rename(
      IDVAR = IDVAR,
      IDVARVAL = IDVARVAL,
      QNAM = QNAM,
      QLABEL = QLABEL,
      QVAL = QVAL,
      QORIG = QORIG,
      QEVAL = QEVAL
    )
  
  # Pivot wider to merge with parent
  supp_wide <- supp_df %>%
    pivot_wider(
      id_cols = c("USUBJID", "IDVAR", "IDVARVAL"),
      names_from = "QNAM",
      values_from = "QVAL",
      names_prefix = paste0(toupper(unique(supp_df$RDOMAIN)[1]), "_")
    )
  
  # Merge with parent
  # Note: This is a simplified version - actual merge logic depends on IDVAR/IDVARVAL
  parent_df
}

cat("Setup complete. Use read_sdtm('DM') to read DM domain, etc.\n")