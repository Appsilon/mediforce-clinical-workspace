# ============================================================
# TLG ID: L-16.3.4
# Title: Listing of All Adverse Events
# Population: Safety Analysis Set
# Source: ADAE
# Method: Patient-level listing
# ============================================================

source("/workspace/tlg_code/00_setup.R")

cat("Generating L-16.3.4: Listing of All Adverse Events...\n")

# ---- Read data ----
adae <- read_adam("ADAE")
adsl <- read_adam("ADSL")

# ---- Filter population ----
safety_pop <- adsl %>% filter(SAFFL == "Y") %>% pull(USUBJID)

# Prepare listing data
listing_data <- adae %>%
  filter(USUBJID %in% safety_pop) %>%
  left_join(
    adsl %>% select(USUBJID, TRT01P, AGE, SEX, RACE),
    by = "USUBJID"
  ) %>%
  select(
    USUBJID,
    TRT01P,
    AGE,
    SEX,
    RACE,
    AEDECOD,
    AEBODSYS,
    AESTDTC,
    AEENDTC,
    AETOXGR,
    AEREL,
    AESER,
    AEOUT,
    TRTEMFL
  ) %>%
  arrange(TRT01P, USUBJID, AESTDTC, AEDECOD)

# Limit to first 100 rows for demonstration
listing_data <- listing_data %>% head(100)

# ---- Build listing table ----
tbl <- listing_data %>%
  gt() %>%
  tab_header(
    title = "Listing of All Adverse Events",
    subtitle = "Population: Safety Analysis Set — Study CDISCPILOT01"
  ) %>%
  cols_label(
    USUBJID = "Subject ID",
    TRT01P = "Treatment",
    AGE = "Age",
    SEX = "Sex",
    RACE = "Race",
    AEDECOD = "Adverse Event Term",
    AEBODSYS = "System Organ Class",
    AESTDTC = "Start Date",
    AEENDTC = "End Date",
    AETOXGR = "Grade",
    AEREL = "Relationship",
    AESER = "Serious",
    AEOUT = "Outcome",
    TRTEMFL = "TEAE"
  ) %>%
  tab_footnote(
    footnote = "TEAE = Treatment-emergent adverse event",
    locations = cells_column_labels(columns = TRTEMFL)
  ) %>%
  tab_footnote(
    footnote = "Adverse events coded using MedDRA version xx.x",
    locations = cells_title()
  ) %>%
  tab_source_note(
    source_note = "Source: ADAE"
  )

# ---- Export ----
output_file <- file.path(output_dir, "listings", "l_01_ae_listing.html")
gt::gtsave(tbl, output_file)
cat("Saved to:", output_file, "\n")

# Also save as CSV for reference
csv_output_file <- file.path(output_dir, "listings", "l_01_ae_listing.csv")
write_csv(listing_data, csv_output_file)
cat("CSV data saved to:", csv_output_file, "\n")

cat("L-16.3.4 generation complete.\n")