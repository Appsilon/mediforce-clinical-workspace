# Simple test script
library(readr)
library(dplyr)

cat("Testing data reading...\n")

# Read ADSL
adsl <- read_csv("/workspace/data/adsl.csv", show_col_types = FALSE)
cat("ADSL columns:", ncol(adsl), "rows:", nrow(adsl), "\n")
cat("ADSL TRT01P values:", unique(adsl$TRT01P), "\n")

# Read ADAE
adae <- read_csv("/workspace/data/adae.csv", show_col_types = FALSE)
cat("ADAE columns:", ncol(adae), "rows:", nrow(adae), "\n")
cat("ADAE TRT01P values:", unique(adae$TRT01P), "\n")

# Check if TRT01P exists
if ("TRT01P" %in% names(adae)) {
  cat("TRT01P exists in ADAE\n")
  cat("Unique TRT01P values:", unique(adae$TRT01P), "\n")
} else {
  cat("TRT01P does NOT exist in ADAE\n")
  cat("Available columns:", names(adae), "\n")
}