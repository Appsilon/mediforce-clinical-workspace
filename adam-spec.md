# ADaM Specification — CDISCPILOT01
## Xanomeline TTS in Mild to Moderate Alzheimer's Disease

**Generated**: 2026-03-13
**Study**: CDISCPILOT01
**Phase**: Phase III, Randomized, double-blind, placebo-controlled, 26-week
**Subjects (in data)**: 254 randomized (86 Placebo, 84 XAN Low, 84 XAN High)

---

## ADSL — Subject-Level Analysis Dataset

- **Structure**: One record per subject
- **Source SDTM**: DM, SUPPDM, DS, SUPPDS, EX, SC, VS, QS
- **Supports TLGs**: T-01, T-02, T-03, T-04, T-17 (partial), T-28, T-29, L-01, and as merge key for all other ADaM datasets
- **Records**: 254

| Variable | Label | Type | Source/Derivation |
|----------|-------|------|-------------------|
| USUBJID | Unique Subject ID | Char | DM.USUBJID |
| SUBJID | Subject ID | Char | DM.SUBJID |
| SITEID | Study Site ID | Char | DM.SITEID |
| AGE | Age (years) | Num | DM.AGE |
| AGEU | Age Unit | Char | DM.AGEU |
| AGEGR1 | Age Group 1 | Char | Derived: <65, 65-80, >80 |
| AGEGR1N | Age Group 1 (N) | Num | Derived: 1=<65, 2=65-80, 3=>80 |
| SEX | Sex | Char | DM.SEX |
| SEXN | Sex (N) | Num | Derived: 1=M, 2=F |
| RACE | Race | Char | DM.RACE |
| RACEN | Race (N) | Num | Derived numeric mapping |
| ETHNIC | Ethnicity | Char | DM.ETHNIC |
| ARMCD | Planned Arm Code | Char | DM.ARMCD |
| ARM | Planned Arm | Char | DM.ARM |
| ACTARMCD | Actual Arm Code | Char | DM.ACTARMCD |
| ACTARM | Actual Arm | Char | DM.ACTARM |
| TRT01A | Actual Treatment Arm | Char | Derived from DM.ARM |
| TRT01AN | Actual Treatment Arm (N) | Num | 1=Placebo, 2=XAN Low, 3=XAN High |
| TRT01P | Planned Treatment Arm | Char | Same as TRT01A |
| TRT01PN | Planned Treatment Arm (N) | Num | Same as TRT01AN |
| TRTSDT | Date of First Exposure | Date | DM.RFXSTDTC |
| TRTEDT | Date of Last Exposure | Date | DM.RFXENDTC |
| TRTDUR | Treatment Duration (days) | Num | TRTEDT − TRTSDT + 1 |
| ITTFL | ITT Population Flag | Char | SUPPDM.ITT |
| SAFFL | Safety Population Flag | Char | SUPPDM.SAFETY |
| EFFFL | Efficacy Population Flag | Char | SUPPDM.EFFICACY |
| COMPFL | Completers at Week 24 Flag | Char | SUPPDM.COMPLT24 |
| COMP8FL | Completers at Week 8 Flag | Char | SUPPDM.COMPLT8 |
| COMP16FL | Completers at Week 16 Flag | Char | SUPPDM.COMPLT16 |
| COMP26FL | Completed Study Through Week 26 Flag | Char | Derived from DS |
| EOSSTT | End of Study Status | Char | DS.DSDECOD mapped to COMPLETED/DISCONTINUED |
| DCDECOD | Discontinuation Reason (CDISC) | Char | DS.DSDECOD (if DISCONTINUED) |
| DCREASCD | Discontinuation Reason | Char | DS.DSTERM (if DISCONTINUED) |
| MMSEBL | MMSE Score at Baseline | Num | Sum of QS MMITM01-06 at SCREENING 1 |
| EDUCLVL | Education Level (years) | Num | SC.SCSTRESN where SCTESTCD='EDLEVEL' |
| HEIGHTBL | Height at Baseline (cm) | Num | VS.VSSTRESN where VSTESTCD='HEIGHT' (first) |
| WEIGHTBL | Weight at Baseline (kg) | Num | VS.VSSTRESN where VSTESTCD='WEIGHT' at BASELINE |
| BMIBL | BMI at Baseline | Num | Derived: WEIGHTBL/(HEIGHTBL/100)^2 |
| DISONSDT | Alzheimer's Disease Onset Date | Date | MH.MHSTDTC where MHTERM='ALZHEIMER'S DISEASE' |
| DURDIS | Duration of Disease (years) | Num | (TRTSDT − DISONSDT) / 365.25 |
| DURDSGR1 | Disease Duration Group | Char | Derived: <1yr, 1-<2yr, >=2yr |

- **Population flags**: ITTFL (all=Y), SAFFL (all=Y), EFFFL (234/254=Y), COMPFL (118/254=Y)
- **Special derivations**: Population flags directly available in SUPPDM; disease duration from MH; BMI computed from VS baseline values

---

## ADQSADAS — ADAS-Cog (11) Analysis Dataset

- **Structure**: One record per subject per analysis visit
- **Source SDTM**: QS (QSCAT='ALZHEIMER'S DISEASE ASSESSMENT SCALE'), ADSL
- **Supports TLGs**: T-05, T-07, T-09, T-11, T-12, T-13, T-14, T-15
- **Records**: 936 (234 subjects × 4 visits)

| Variable | Label | Type | Source/Derivation |
|----------|-------|------|-------------------|
| USUBJID | Unique Subject ID | Char | QS.USUBJID |
| PARAMCD | Parameter Code | Char | 'ACTOT11' |
| PARAM | Parameter | Char | 'ADAS-Cog (11) Total Score' |
| AVISIT | Analysis Visit | Char | Windowed: Baseline/Week 8/16/24 |
| AVISITN | Analysis Visit (N) | Num | 0/8/16/24 |
| ADT | Analysis Date | Date | QS.QSDTC |
| ADY | Analysis Day | Num | QS.QSDY |
| AVAL | Analysis Value | Num | ACTOT from QS (11-item ADAS total) |
| BASE | Baseline Value | Num | AVAL at Baseline (AVISITN=0) |
| CHG | Change from Baseline | Num | AVAL − BASE |
| PCHG | Percent Change from Baseline | Num | CHG/BASE × 100 |
| DTYPE | Derivation Type | Char | 'LOCF' if imputed, else missing |
| ABLFL | Baseline Record Flag | Char | 'Y' at Baseline |
| ANL01FL | Analysis Flag | Char | 'Y' for primary analysis records |

- **Population flags**: EFFFL (primary), COMPFL (T-11 completers analysis), SEX subgroups (T-12/T-13)
- **Visit windowing**: Baseline (day≤1), Week 8 (days 2-84, target 56), Week 16 (days 85-140, target 112), Week 24 (days>140, target 168); retrieval visit included in Week 24 window
- **LOCF imputation**: Applied for missing post-baseline values; 162 LOCF records out of 702 post-baseline records

---

## ADQSCIBC — CIBIC+ Analysis Dataset

- **Structure**: One record per subject per analysis visit
- **Source SDTM**: QS (QSCAT='CLINICIAN'S INTERVIEW-BASED IMPRESSION OF CHANGE (CIBIC+)'), ADSL
- **Supports TLGs**: T-06, T-08, T-10, T-30
- **Records**: 2,106 (234 subjects × 9 visits)

| Variable | Label | Type | Source/Derivation |
|----------|-------|------|-------------------|
| PARAMCD | Parameter Code | Char | 'CIBIC' |
| AVISIT | Analysis Visit | Char | Weeks 2, 4, 6, 8, 12, 16, 20, 24, 26 |
| AVISITN | Analysis Visit (N) | Num | 2/4/6/8/12/16/20/24/26 |
| AVAL | Analysis Value | Num | CIBIC+ score (1-7 scale) |
| DTYPE | Derivation Type | Char | 'LOCF' if imputed |

- **Special derivations**: CIBIC+ is already a change-from-baseline impression score (1=markedly improved, 7=markedly worse, 4=no change); no BASE or CHG derived. LOCF applied at Weeks 8, 16, 24. 212 LOCF records.

---

## ADQSNPIX — NPI-X Analysis Dataset

- **Structure**: One record per subject per analysis visit
- **Source SDTM**: QS (QSCAT='NEUROPSYCHIATRIC INVENTORY - REVISED (NPI-X)'), ADSL
- **Supports TLGs**: T-16
- **Records**: 2,395

| Variable | Label | Type | Source/Derivation |
|----------|-------|------|-------------------|
| PARAMCD | Parameter Code | Char | 'NPTOT9' (9-domain total), 'NPTMN24' (mean Wks 4-24) |
| AVISIT | Analysis Visit | Char | Baseline through Week 24 (biweekly) |
| AVAL | Analysis Value | Num | 9-domain sum (excl. Euphoria/Night-time/Appetite) |
| BASE | Baseline Value | Num | AVAL at Baseline |
| CHG | Change from Baseline | Num | AVAL − BASE |

- **Special derivations**: 9-domain NPI-X score = sum of NPITM01-05V + NPITM07-10V (excludes domains 6, 11, 12). Mean NPI-X endpoint (NPTMN24) = mean of Weeks 4-24 observed values (no LOCF per SAP).

---

## ADAE — Adverse Events Analysis Dataset

- **Structure**: One record per subject per adverse event
- **Source SDTM**: AE, SUPPAE, ADSL
- **Supports TLGs**: T-18, T-19, L-03, L-04, L-05, L-06
- **Records**: 1,191

| Variable | Label | Type | Source/Derivation |
|----------|-------|------|-------------------|
| AETERM | Verbatim AE Term | Char | AE.AETERM |
| AEDECOD | MedDRA Preferred Term | Char | AE.AEDECOD |
| AEBODSYS | MedDRA System Organ Class | Char | AE.AEBODSYS |
| ASTDT | Start Date | Date | AE.AESTDTC |
| AENDT | End Date | Date | AE.AEENDTC |
| AESEV | Severity | Char | AE.AESEV |
| AESER | Serious | Char | AE.AESER |
| AEREL | Causality | Char | AE.AEREL |
| TRTEMFL | Treatment-Emergent Flag | Char | SUPPAE.AETRTEM + ASTDT≥TRTSDT check |
| DERM_FL | Dermatological Event Flag | Char | SOC='SKIN AND SUBCUTANEOUS TISSUE DISORDERS' |
| AESERF | Serious AE Flag | Char | Derived from AESER |

- **Special derivations**: TRTEMFL from SUPPAE (AETRTEM) supplemented by date comparison. 260 dermatological TEAEs present (used for ADTTE).

---

## ADLB — Laboratory Data Analysis Dataset

- **Structure**: One record per subject per parameter per visit
- **Source SDTM**: LB, SUPPLB, ADSL
- **Supports TLGs**: T-20, T-21, T-22, T-23, T-24, T-25
- **Records**: 57,951

| Variable | Label | Type | Source/Derivation |
|----------|-------|------|-------------------|
| PARAMCD | Parameter Code | Char | LB.LBTESTCD |
| PARAM | Parameter | Char | LB.LBTEST |
| PARCAT1 | Category | Char | LB.LBCAT (Chemistry/Hematology/Urinalysis) |
| AVISIT | Analysis Visit | Char | Mapped from VISIT |
| AVAL | Analysis Value | Num | LB.LBSTRESN |
| BASE | Baseline Value | Num | AVAL at Screening (SCREENING 1 = Visit 1) |
| CHG | Change from Baseline | Num | AVAL − BASE |
| ANRLO | Lower Normal Range | Num | LB.LBSTNRLO |
| ANRHI | Upper Normal Range | Num | LB.LBSTNRHI |
| ANRIND | Normal Range Indicator | Char | LB.LBNRIND |
| BNRIND | Baseline Normal Range Indicator | Char | ANRIND at Baseline |
| SHIFT1 | Shift Category at Visit | Char | L/N/H |
| SHIFT1BL | Shift Category at Baseline | Char | L/N/H |
| SHTBL1 | Shift: Baseline→Visit | Char | e.g., N->H |
| CRITFL | Emergent Abnormality Flag | Char | 'Y' if post-BL abnormal and BL normal |

- **Population flags**: SAFFL
- **Baseline**: SCREENING 1 (Visit 1, approximately Week -2) per SAP
- **43 unique parameters** across Chemistry, Hematology, Urinalysis categories

---

## ADVS — Vital Signs Analysis Dataset

- **Structure**: One record per subject per parameter per visit
- **Source SDTM**: VS, ADSL
- **Supports TLGs**: T-26, T-27, T-28
- **Records**: 16,923

| Variable | Label | Type | Source/Derivation |
|----------|-------|------|-------------------|
| PARAMCD | Parameter Code | Char | SYSBP, VSSBPST, DIABP, VSDBPST, PULSE, VSPULST, WEIGHT, HEIGHT, TEMP |
| AVAL | Analysis Value | Num | VS.VSSTRESN |
| BASE | Baseline Value | Num | AVAL at BASELINE visit |
| CHG | Change from Baseline | Num | AVAL − BASE |
| AVISIT | Analysis Visit | Char | Screening through Week 26 |

- **Special derivations**: Supine vs. standing blood pressure/pulse distinguished by VSPOS. Weight baseline = Visit 3 (BASELINE). Height baseline = first available visit.

---

## ADEX — Exposure Analysis Dataset

- **Structure**: One record per subject (summary) + interval records
- **Source SDTM**: EX, ADSL
- **Supports TLGs**: T-17
- **Records**: 254 (summary) + 591 (interval)

| Variable | Label | Type | Source/Derivation |
|----------|-------|------|-------------------|
| CUMEXDOS | Cumulative Dose (mg) | Num | Sum(EXDOSE × duration) |
| AVGDOSE | Average Daily Dose (mg/day) | Num | CUMEXDOS / TOTEXDUR |
| TOTEXDUR | Total Treatment Duration (days) | Num | Sum of exposure interval days |

---

## ADCM — Concomitant Medications Analysis Dataset

- **Structure**: One record per subject per medication
- **Source SDTM**: CM, ADSL
- **Supports TLGs**: T-29
- **Records**: 7,510

| Variable | Label | Type | Source/Derivation |
|----------|-------|------|-------------------|
| CMTRT | Verbatim CM Term | Char | CM.CMTRT |
| CMDECOD | Standardized CM Term | Char | CM.CMDECOD |
| CMCLAS1 | ATC Class | Char | CM.CMCLAS |
| ASTDT | Start Date | Date | CM.CMSTDTC (partial dates padded) |
| TRTEMFL | Treatment-Emergent Flag | Char | ASTDT ≥ TRTSDT |
| CMRFL | Concomitant (Ongoing) Flag | Char | Started before and ongoing at TRTSDT |

- **Special derivations**: Partial dates (year-only) in CMSTDTC padded to full ISO dates (YYYY-01-01)

---

## ADTTE — Time-to-Event Analysis Dataset

- **Structure**: One record per subject per TTE parameter
- **Source ADaM**: ADAE, ADSL
- **Supports TLGs**: F-01 (Kaplan-Meier)
- **Records**: 254

| Variable | Label | Type | Source/Derivation |
|----------|-------|------|-------------------|
| PARAMCD | Parameter Code | Char | 'TTDERM' |
| PARAM | Parameter | Char | 'Time to First Dermatological TEAE (days)' |
| AVAL | Analysis Value (days) | Num | Days from TRTSDT to event/censoring + 1 |
| CNSR | Censoring Indicator | Num | 0=event, 1=censored |
| EVNTFL | Event Flag | Char | 'Y' if event occurred |
| ADT | Analysis Date | Date | Event date or censoring date (TRTEDT) |
| CNSDTDSC | Censoring Date Description | Char | 'LAST KNOWN ON-STUDY DATE' |

- **Events**: 99 subjects with dermatological TEAE; 155 censored
- **Censoring date**: Treatment end date (TRTEDT)
