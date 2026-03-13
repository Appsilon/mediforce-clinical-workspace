# Master script to generate all ADaM datasets
# Robust version that handles missing columns

library(haven)
library(dplyr)
library(lubridate)

# Create output directory
output_dir <- "/workspace/data"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# Helper function to select columns if they exist
select_if_exists <- function(df, cols) {
  existing_cols <- intersect(cols, colnames(df))
  if (length(existing_cols) > 0) {
    df %>% select(all_of(existing_cols))
  } else {
    df
  }
}

# ---- Read SDTM data ----
cat("Reading SDTM data...\n")
dm <- read_xpt("/workspace/sdtm/dm.xpt")
ds <- read_xpt("/workspace/sdtm/ds.xpt")
ex <- read_xpt("/workspace/sdtm/ex.xpt")
ae <- read_xpt("/workspace/sdtm/ae.xpt")
lb <- read_xpt("/workspace/sdtm/lb.xpt")
vs <- read_xpt("/workspace/sdtm/vs.xpt")
qs <- read_xpt("/workspace/sdtm/qs.xpt")
mh <- read_xpt("/workspace/sdtm/mh.xpt")
cm <- read_xpt("/workspace/sdtm/cm.xpt")

# ---- 1. ADSL - Subject-Level Analysis Dataset ----
cat("\n1. Generating ADSL...\n")
adsl <- dm %>%
  select_if_exists(c("STUDYID", "DOMAIN", "USUBJID", "SUBJID", "SITEID",
                     "AGE", "AGEU", "SEX", "RACE", "ETHNIC", "ARMCD", "ARM",
                     "RFSTDTC", "RFENDTC", "RFXSTDTC", "RFXENDTC",
                     "DTHDTC", "DTHFL")) %>%
  mutate(
    TRT01P = ARM,
    TRT01PN = case_when(
      ARMCD == "PBO" ~ 1,
      ARMCD == "XAN-LOW" ~ 2,
      ARMCD == "XAN-HIGH" ~ 3,
      TRUE ~ NA_real_
    ),
    SAFFL = ifelse(USUBJID %in% unique(ex$USUBJID), "Y", "N"),
    ITTFL = ifelse(!is.na(RFSTDTC), "Y", "N")
  )

saveRDS(adsl, file.path(output_dir, "adsl.rds"))
write.csv(adsl, file.path(output_dir, "adsl.csv"), row.names = FALSE)
cat("ADSL created:", nrow(adsl), "records\n")

# ---- 2. ADMH - Medical History ----
cat("\n2. Generating ADMH...\n")
if (nrow(mh) > 0) {
  admh <- mh %>%
    select_if_exists(c("USUBJID", "MHSEQ", "MHTERM", "MHDECOD", "MHBODSYS",
                       "MHCAT", "MHSCAT", "MHPRESP", "MHOCCUR",
                       "MHSTDTC", "MHENDTC")) %>%
    left_join(adsl %>% select(USUBJID, TRT01P, TRT01PN, SAFFL),
              by = "USUBJID") %>%
    filter(SAFFL == "Y") %>%
    select(-SAFFL)
  
  write.csv(admh, file.path(output_dir, "admh.csv"), row.names = FALSE)
  cat("ADMH created:", nrow(admh), "records\n")
} else {
  cat("No MH data available\n")
}

# ---- 3. ADCM - Concomitant Medications ----
cat("\n3. Generating ADCM...\n")
if (nrow(cm) > 0) {
  adcm <- cm %>%
    select_if_exists(c("USUBJID", "CMSEQ", "CMTRT", "CMDECOD", "CMCAT", "CMSCAT",
                       "CMPRESP", "CMOCCUR", "CMSTDTC", "CMENDTC",
                       "CMROUTE", "CMDOSE", "CMDOSU", "CMFRQ")) %>%
    left_join(adsl %>% select(USUBJID, TRT01P, TRT01PN, SAFFL, RFXSTDTC),
              by = "USUBJID") %>%
    mutate(
      CMPRIOR = ifelse(!is.na(CMSTDTC) & !is.na(RFXSTDTC) & CMSTDTC < RFXSTDTC,
                       "PRIOR", "CONCOMITANT")
    ) %>%
    filter(SAFFL == "Y") %>%
    select(-SAFFL, -RFXSTDTC)
  
  write.csv(adcm, file.path(output_dir, "adcm.csv"), row.names = FALSE)
  cat("ADCM created:", nrow(adcm), "records\n")
} else {
  cat("No CM data available\n")
}

# ---- 4. ADEX - Exposure ----
cat("\n4. Generating ADEX...\n")
if (nrow(ex) > 0) {
  adex <- ex %>%
    select_if_exists(c("USUBJID", "EXSEQ", "EXTRT", "EXDOSE", "EXDOSU",
                       "EXDOSFRM", "EXDOSFRQ", "EXROUTE",
                       "EXSTDTC", "EXENDTC")) %>%
    left_join(adsl %>% select(USUBJID, TRT01P, TRT01PN, SAFFL),
              by = "USUBJID") %>%
    filter(SAFFL == "Y") %>%
    select(-SAFFL)
  
  write.csv(adex, file.path(output_dir, "adex.csv"), row.names = FALSE)
  cat("ADEX created:", nrow(adex), "records\n")
} else {
  cat("No EX data available\n")
}

# ---- 5. ADEFF - Efficacy ----
cat("\n5. Generating ADEFF...\n")
if (nrow(qs) > 0) {
  # Filter to key efficacy parameters
  qs_eff <- qs %>%
    filter(!is.na(QSSTRESN))
  
  if (nrow(qs_eff) > 0) {
    adeff <- qs_eff %>%
      mutate(
        PARAMCD = QSTESTCD,
        PARAM = QSTEST,
        AVISIT = VISIT,
        AVAL = as.numeric(QSSTRESN)
      ) %>%
      select_if_exists(c("USUBJID", "PARAMCD", "PARAM", "AVISIT", "AVAL", "VISITNUM", "QSDTC")) %>%
      left_join(adsl %>% select(USUBJID, TRT01P, TRT01PN, AGE, SEX, RACE),
                by = "USUBJID")
    
    write.csv(adeff, file.path(output_dir, "adeff.csv"), row.names = FALSE)
    cat("ADEFF created:", nrow(adeff), "records\n")
  } else {
    cat("No efficacy data with numeric results\n")
  }
} else {
  cat("No QS data available\n")
}

# ---- 6. ADAE - Adverse Events ----
cat("\n6. Generating ADAE...\n")
if (nrow(ae) > 0) {
  adae <- ae %>%
    select_if_exists(c("USUBJID", "AESEQ", "AETERM", "AEDECOD", "AEBODSYS",
                       "AESER", "AEREL", "AEOUT", "AESEV", "AETOXGR",
                       "AESTDTC", "AEENDTC")) %>%
    left_join(adsl %>% select(USUBJID, TRT01P, TRT01PN, SAFFL, RFXSTDTC),
              by = "USUBJID") %>%
    mutate(
      TRTEMFL = ifelse(!is.na(AESTDTC) & !is.na(RFXSTDTC) & AESTDTC >= RFXSTDTC, "Y", "N"),
      TRTRELFL = ifelse(!is.na(AEREL) & AEREL %in% c("POSSIBLE", "PROBABLE"), "Y", "N"),
      SERFL = ifelse(!is.na(AESER) & AESER == "Y", "Y", "N")
    ) %>%
    filter(SAFFL == "Y") %>%
    select(-SAFFL, -RFXSTDTC)
  
  write.csv(adae, file.path(output_dir, "adae.csv"), row.names = FALSE)
  cat("ADAE created:", nrow(adae), "records\n")
} else {
  cat("No AE data available\n")
}

# ---- 7. ADLB - Laboratory ----
cat("\n7. Generating ADLB...\n")
if (nrow(lb) > 0) {
  adlb <- lb %>%
    filter(!is.na(LBSTRESN)) %>%
    select_if_exists(c("USUBJID", "LBSEQ", "LBTESTCD", "LBTEST", "LBCAT", "LBSCAT",
                       "LBORRES", "LBORRESU", "LBSTRESC", "LBSTRESN", "LBSTRESU",
                       "LBNRIND", "LBLLN", "LBULN", "LBDTC", "VISITNUM", "VISIT")) %>%
    left_join(adsl %>% select(USUBJID, TRT01P, TRT01PN, SAFFL),
              by = "USUBJID") %>%
    filter(SAFFL == "Y") %>%
    select(-SAFFL)
  
  write.csv(adlb, file.path(output_dir, "adlb.csv"), row.names = FALSE)
  cat("ADLB created:", nrow(adlb), "records\n")
} else {
  cat("No LB data available\n")
}

# ---- 8. ADVS - Vital Signs ----
cat("\n8. Generating ADVS...\n")
if (nrow(vs) > 0) {
  advs <- vs %>%
    filter(!is.na(VSSTRESN)) %>%
    select_if_exists(c("USUBJID", "VSSEQ", "VSTESTCD", "VSTEST", "VSCAT",
                       "VSORRES", "VSORRESU", "VSSTRESC", "VSSTRESN", "VSSTRESU",
                       "VSDTC", "VISITNUM", "VISIT")) %>%
    left_join(adsl %>% select(USUBJID, TRT01P, TRT01PN, SAFFL),
              by = "USUBJID") %>%
    filter(SAFFL == "Y") %>%
    select(-SAFFL)
  
  write.csv(advs, file.path(output_dir, "advs.csv"), row.names = FALSE)
  cat("ADVS created:", nrow(advs), "records\n")
} else {
  cat("No VS data available\n")
}

cat("\n=== ADaM Generation Complete ===\n")
cat("Output directory:", output_dir, "\n")
cat("Files created:\n")
system(paste("ls -lh", output_dir, "| grep -E '\\.(csv|rds)$'"))