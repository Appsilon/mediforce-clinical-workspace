# ADaM Specification — CDISCPILOT01

## Generation metadata
- **Study**: CDISCPILOT01 — Safety and Efficacy of the Xanomeline Transdermal Therapeutic System (TTS) in Patients with Mild to Moderate Alzheimer's Disease
- **Generated**: 2026-03-13
- **Source TLGs**: 42 TLG shells (28 tables, 8 listings, 6 figures)
- **Source SDTM**: 20 domains available in SAS XPT format
- **Required ADaM datasets**: 8

## ADSL — Subject-Level Analysis Dataset

- **Structure**: One record per subject
- **Source SDTM**: DM, DS, EX, SV, SUPPDM, SUPPDS
- **Supports TLGs**: T-14.1.1, T-14.1.2, L-16.1.1, L-16.2.1
- **Key variables**:
  | Variable | Label | Type | Source/Derivation |
  |----------|-------|------|-------------------|
  | USUBJID | Unique Subject Identifier | Char | DM.USUBJID |
  | SUBJID | Subject Identifier for the Study | Char | DM.SUBJID |
  | SITEID | Study Site Identifier | Char | DM.SITEID |
  | AGE | Age | Num | DM.AGE |
  | AGEGR1 | Age Group (<65, >=65) | Char | Derived from AGE |
  | SEX | Sex | Char | DM.SEX |
  | RACE | Race | Char | DM.RACE |
  | ETHNIC | Ethnicity | Char | DM.ETHNIC |
  | ARM | Description of Planned Arm | Char | DM.ARM |
  | TRT01P | Planned Treatment for Period 01 | Char | DM.ARMCD |
  | TRT01PN | Planned Treatment for Period 01 (N) | Num | Derived from TRT01P |
  | RFSTDTC | Subject Reference Start Date/Time | Char | DM.RFSTDTC |
  | RFENDTC | Subject Reference End Date/Time | Char | DM.RFENDTC |
  | RFXSTDTC | Date/Time of First Study Treatment | Char | EX.EXSTDTC (first) |
  | RFXENDTC | Date/Time of Last Study Treatment | Char | EX.EXENDTC (last) |
  | DTHDTC | Date/Time of Death | Char | DS.DSDTC where DS.DECOD="DEATH" |
  | DTHFL | Death Flag | Char | Derived from DTHDTC |
  | SAFFL | Safety Population Flag | Char | EX.EXSEQ exists |
  | ITTFL | Intent-to-Treat Population Flag | Char | DM.RFSTDTC not null |
  | EFFFL | Efficacy Population Flag | Char | Has post-baseline QS records for ADAS-Cog and CIBIC+ |
  | COMPLFL | Completed Study Flag | Char | DS.DSDTC where DS.DECOD="COMPLETED" |
  | DISCONFL | Discontinued Study Flag | Char | DS.DSDTC where DS.DECOD not in ("COMPLETED", "SCREEN FAILURE") |
  | DISCONREA | Reason for Discontinuation | Char | DS.DSREAS |
  | WEIGHTBL | Baseline Weight (kg) | Num | VS.VSSTRESN where VS.VSTESTCD="WEIGHT" and VS.VISIT="BASELINE" |
  | HEIGHTBL | Baseline Height (cm) | Num | VS.VSSTRESN where VS.VSTESTCD="HEIGHT" and VS.VISIT="SCREENING" |
  | BMIBL | Baseline BMI (kg/m²) | Num | Derived from WEIGHTBL and HEIGHTBL |
  | MMSEBL | Baseline MMSE Score | Num | QS.QSSTRESN where QS.QSCAT="MMSE" and QS.VISITNUM=3 |
  | ADASCOGBL | Baseline ADAS-Cog (11) Score | Num | QS.QSSTRESN where QS.QSTESTCD="ADAS11" and QS.VISITNUM=3 |
  | CIBICBL | Baseline CIBIC+ Score | Num | QS.QSSTRESN where QS.QSTESTCD="CIBIC+" and QS.VISITNUM=3 |
  | DISDURBL | Disease Duration at Baseline (years) | Num | SC.SCSTRESN where SC.SCTESTCD="DISDUR" |
- **Population flags**: SAFFL, ITTFL, EFFFL, COMPLFL, DISCONFL
- **Special derivations**: Baseline values from screening/baseline visits, population flags based on protocol criteria

## ADMH — Medical History Analysis Dataset

- **Structure**: One record per subject per medical history condition
- **Source SDTM**: MH, SUPPAE (if needed)
- **Supports TLGs**: T-14.1.3
- **Key variables**:
  | Variable | Label | Type | Source/Derivation |
  |----------|-------|------|-------------------|
  | USUBJID | Unique Subject Identifier | Char | MH.USUBJID |
  | MHSEQ | Sequence Number | Num | MH.MHSEQ |
  | MHTERM | Reported Term for the Medical History | Char | MH.MHTERM |
  | MHDECOD | Dictionary-Derived Term | Char | MH.MHDECOD |
  | MHBODSYS | Body System or Organ Class | Char | MH.MHBODSYS |
  | MHCAT | Category for Medical History | Char | MH.MHCAT |
  | MHSCAT | Subcategory for Medical History | Char | MH.MHSCAT |
  | MHPRESP | Medical History Pre-specified | Char | MH.MHPRESP |
  | MHOCCUR | Medical History Occurrence | Char | MH.MHOCCUR |
  | MHSTDTC | Start Date/Time of Medical History | Char | MH.MHSTDTC |
  | MHENDTC | End Date/Time of Medical History | Char | MH.MHENDTC |
- **Population flags**: SAFFL (from ADSL)
- **Special derivations**: None beyond SDTM

## ADCM — Concomitant Medications Analysis Dataset

- **Structure**: One record per subject per concomitant medication
- **Source SDTM**: CM, SUPPCM
- **Supports TLGs**: T-14.1.4, L-16.1.2
- **Key variables**:
  | Variable | Label | Type | Source/Derivation |
  |----------|-------|------|-------------------|
  | USUBJID | Unique Subject Identifier | Char | CM.USUBJID |
  | CMSEQ | Sequence Number | Num | CM.CMSEQ |
  | CMTRT | Reported Name of Drug, Med, or Therapy | Char | CM.CMTRT |
  | CMDECOD | Standardized Medication Name | Char | CM.CMDECOD |
  | CMCAT | Category for Medication | Char | CM.CMCAT |
  | CMSCAT | Subcategory for Medication | Char | CM.CMSCAT |
  | CMPRESP | Pre-specified Medication | Char | CM.CMPRESP |
  | CMOCCUR | Concomitant Medication Occurrence | Char | CM.CMOCCUR |
  | CMSTDTC | Start Date/Time of Medication | Char | CM.CMSTDTC |
  | CMENDTC | End Date/Time of Medication | Char | CM.CMENDTC |
  | CMROUTE | Route of Administration | Char | CM.CMROUTE |
  | CMDOSE | Dose per Administration | Num | CM.CMDOSE |
  | CMDOSU | Dose Units | Char | CM.CMDOSU |
  | CMFRQ | Dosing Frequency per Interval | Char | CM.CMFRQ |
  | CMPRIOR | Prior/Concomitant Medication | Char | Derived from CMSTDTC relative to RFXSTDTC |
- **Population flags**: SAFFL (from ADSL)
- **Special derivations**: CMPRIOR flag (prior vs concomitant based on start date relative to first study treatment)

## ADEX — Exposure Analysis Dataset

- **Structure**: One record per subject per exposure interval
- **Source SDTM**: EX, SV
- **Supports TLGs**: T-14.1.5
- **Key variables**:
  | Variable | Label | Type | Source/Derivation |
  |----------|-------|------|-------------------|
  | USUBJID | Unique Subject Identifier | Char | EX.USUBJID |
  | EXSEQ | Sequence Number | Num | EX.EXSEQ |
  | EXTRT | Name of Treatment | Char | EX.EXTRT |
  | EXDOSE | Dose per Administration | Num | EX.EXDOSE |
  | EXDOSU | Dose Units | Char | EX.EXDOSU |
  | EXDOSFRM | Dose Form | Char | EX.EXDOSFRM |
  | EXDOSFRQ | Dosing Frequency per Interval | Char | EX.EXDOSFRQ |
  | EXROUTE | Route of Administration | Char | EX.EXROUTE |
  | EXSTDTC | Start Date/Time of Treatment | Char | EX.EXSTDTC |
  | EXENDTC | End Date/Time of Treatment | Char | EX.EXENDTC |
  | EXDUR | Duration of Exposure | Num | Derived from EXSTDTC and EXENDTC |
  | CUMDOSE | Cumulative Dose | Num | Sum of EXDOSE across all exposures |
  | NEXP | Number of Exposures | Num | Count of EXSEQ per subject |
  | EXPOSFL | Exposure Flag | Char | Derived (Y if EXSEQ exists) |
- **Population flags**: SAFFL (from ADSL)
- **Special derivations**: Duration, cumulative dose, exposure summary statistics

## ADEFF — Efficacy Analysis Dataset

- **Structure**: One record per subject per parameter per analysis visit
- **Source SDTM**: QS, SUPPQS (if available), VS (for weight/height if needed)
- **Supports TLGs**: T-14.2.1 through T-14.2.9, T-14.1.2 (baseline values), F-15.1.1 through F-15.1.3, L-16.2.1
- **Key variables**:
  | Variable | Label | Type | Source/Derivation |
  |----------|-------|------|-------------------|
  | USUBJID | Unique Subject Identifier | Char | QS.USUBJID |
  | PARAMCD | Parameter Code | Char | Derived from QS.QSTESTCD |
  | PARAM | Parameter | Char | Derived from QS.QSTEST |
  | AVISITN | Analysis Visit (N) | Num | Derived from QS.VISITNUM |
  | AVISIT | Analysis Visit | Char | Derived from QS.VISIT |
  | ADT | Analysis Date | Date | Derived from QS.QSDTC |
  | ADY | Analysis Relative Day | Num | Derived from ADT and RFSTDTC |
  | AVAL | Analysis Value | Num | QS.QSSTRESN |
  | BASE | Baseline Value | Num | AVAL where AVISITN=3 (Baseline) |
  | CHG | Change from Baseline | Num | AVAL - BASE |
  | PCHG | Percent Change from Baseline | Num | (CHG/BASE)*100 |
  | ABLFL | Baseline Record Flag | Char | Derived (Y if AVISITN=3) |
  | ANL01FL | Analysis Flag 01 | Char | Derived for LOCF imputation |
  | LOCF | Last Observation Carried Forward Flag | Char | Derived for missing visits |
  | TRTP | Planned Treatment | Char | ADSL.TRT01P |
  | TRTPN | Planned Treatment (N) | Num | ADSL.TRT01PN |
  | SEX | Sex | Char | ADSL.SEX |
  | AGE | Age | Num | ADSL.AGE |
  | AGEGR1 | Age Group | Char | ADSL.AGEGR1 |
  | RACE | Race | Char | ADSL.RACE |
  | ETHNIC | Ethnicity | Char | ADSL.ETHNIC |
  | MMSEBL | Baseline MMSE Score | Num | ADSL.MMSEBL |
  | ADASCOGBL | Baseline ADAS-Cog Score | Num | ADSL.ADASCOGBL |
  | CIBICBL | Baseline CIBIC+ Score | Num | ADSL.CIBICBL |
- **Parameters included**:
  - ADAS11: ADAS-Cog (11) total score
  - CIBIC: CIBIC+ score (1-7)
  - NPI-X: Neuropsychiatric Inventory total score
  - MMSE: Mini-Mental State Examination score
- **Population flags**: EFFFL (from ADSL)
- **Special derivations**: LOCF imputation for missing visits, change from baseline, analysis visits mapped from collection visits with windowing rules

## ADAE — Adverse Events Analysis Dataset

- **Structure**: One record per subject per adverse event
- **Source SDTM**: AE, SUPPAE, EX
- **Supports TLGs**: T-14.3.1.1 through T-14.3.1.6, L-16.3.1 through L-16.3.4, F-15.2.1 through F-15.2.2
- **Key variables**:
  | Variable | Label | Type | Source/Derivation |
  |----------|-------|------|-------------------|
  | USUBJID | Unique Subject Identifier | Char | AE.USUBJID |
  | AESEQ | Sequence Number | Num | AE.AESEQ |
  | AETERM | Reported Term for the Adverse Event | Char | AE.AETERM |
  | AEDECOD | Dictionary-Derived Term | Char | AE.AEDECOD |
  | AEBODSYS | Body System or Organ Class | Char | AE.AEBODSYS |
  | AESER | Serious Event | Char | AE.AESER |
  | AEREL | Causality | Char | AE.AEREL |
  | AEOUT | Outcome of Adverse Event | Char | AE.AEOUT |
  | AESEV | Severity/Intensity | Char | AE.AESEV |
  | AETOXGR | Standard Toxicity Grade | Num | AE.AETOXGR |
  | AESTDTC | Start Date/Time of Adverse Event | Char | AE.AESTDTC |
  | AEENDTC | End Date/Time of Adverse Event | Char | AE.AEENDTC |
  | TRTEMFL | Treatment Emergent Flag | Char | Derived (Y if AESTDTC >= RFXSTDTC) |
  | TRTRELFL | Treatment Related Flag | Char | Derived from AEREL |
  | SERFL | Serious Flag | Char | Derived from AESER |
  | WDRAWFL | Led to Withdrawal Flag | Char | Derived from AEOUT |
  | DSCHFL | Led to Discontinuation Flag | Char | Derived from AEOUT |
  | DEATHFL | Resulted in Death Flag | Char | Derived from AEOUT |
  | AESTDY | Study Day of Start of Adverse Event | Num | Derived from AESTDTC and RFSTDTC |
  | AEENDY | Study Day of End of Adverse Event | Num | Derived from AEENDTC and RFSTDTC |
  | AEDUR | Duration of Adverse Event | Num | Derived from AESTDTC and AEENDTC |
- **Population flags**: SAFFL (from ADSL)
- **Special derivations**: Treatment-emergent flag (onset on or after first dose), severity flags, outcome flags

## ADLB — Laboratory Analysis Dataset

- **Structure**: One record per subject per parameter per visit
- **Source SDTM**: LB, SUPPLB, VS (if needed)
- **Supports TLGs**: T-14.3.2.1, T-14.3.2.2, L-16.3.5
- **Key variables**:
  | Variable | Label | Type | Source/Derivation |
  |----------|-------|------|-------------------|
  | USUBJID | Unique Subject Identifier | Char | LB.USUBJID |
  | LBSEQ | Sequence Number | Num | LB.LBSEQ |
  | LBTESTCD | Lab Test or Examination Short Name | Char | LB.LBTESTCD |
  | LBTEST | Lab Test or Examination Name | Char | LB.LBTEST |
  | LBCAT | Category for Lab Test | Char | LB.LBCAT |
  | LBSCAT | Subcategory for Lab Test | Char | LB.LBSCAT |
  | LBORRES | Result or Finding in Original Units | Char | LB.LBORRES |
  | LBORRESU | Original Units | Char | LB.LBORRESU |
  | LBSTRESC | Character Result/Finding in Std Format | Char | LB.LBSTRESC |
  | LBSTRESN | Numeric Result/Finding in Standard Units | Num | LB.LBSTRESN |
  | LBSTRESU | Standard Units | Char | LB.LBSTRESU |
  | LBNRIND | Reference Range Indicator | Char | LB.LBNRIND |
  | LBLLN | Lower Limit of Normal Range | Num | LB.LBLLN |
  | LBULN | Upper Limit of Normal Range | Num | LB.LBULN |
  | LBDTC | Date/Time of Specimen Collection | Char | LB.LBDTC |
  | VISITNUM | Visit Number | Num | LB.VISITNUM |
  | VISIT | Visit Name | Char | LB.VISIT |
  | AVAL | Analysis Value | Num | LBSTRESN |
  | BASE | Baseline Value | Num | AVAL where VISITNUM=3 |
  | CHG | Change from Baseline | Num | AVAL - BASE |
  | A1LO | Analysis Range Low Value | Num | LBLLN |
  | A1HI | Analysis Range High Value | Num | LBULN |
  | ANRIND | Analysis Reference Range Indicator | Char | Derived from AVAL, A1LO, A1HI |
  | ANRLO | Analysis Normal Range Lower Limit | Num | LBLLN |
  | ANRHI | Analysis Normal Range Upper Limit | Num | LBULN |
  | SHIFT1 | Shift from Baseline Category 1 | Char | Derived from BASERIND and ANRIND |
- **Population flags**: SAFFL (from ADSL)
- **Special derivations**: Shift tables, reference range indicators, change from baseline

## ADVS — Vital Signs Analysis Dataset

- **Structure**: One record per subject per parameter per visit
- **Source SDTM**: VS
- **Supports TLGs**: T-14.3.3.1, T-14.3.3.2, T-14.3.4.1
- **Key variables**:
  | Variable | Label | Type | Source/Derivation |
  |----------|-------|------|-------------------|
  | USUBJID | Unique Subject Identifier | Char | VS.USUBJID |
  | VSSEQ | Sequence Number | Num | VS.VSSEQ |
  | VSTESTCD | Vital Signs Test Short Name | Char | VS.VSTESTCD |
  | VSTEST | Vital Signs Test Name | Char | VS.VSTEST |
  | VSCAT | Category for Vital Signs | Char | VS.VSCAT |
  | VSORRES | Result or Finding in Original Units | Char | VS.VSORRES |
  | VSORRESU | Original Units | Char | VS.VSORRESU |
  | VSSTRESC | Character Result/Finding in Std Format | Char | VS.VSSTRESC |
  | VSSTRESN | Numeric Result/Finding in Standard Units | Num | VS.VSSTRESN |
  | VSSTRESU | Standard Units | Char | VS.VSSTRESU |
  | VSDTC | Date/Time of Measurements | Char | VS.VSDTC |
  | VISITNUM | Visit Number | Num | VS.VISITNUM |
  | VISIT | Visit Name | Char | VS.VISIT |
  | AVAL | Analysis Value | Num | VSSTRESN |
  | BASE | Baseline Value | Num | AVAL where VISITNUM=3 |
  | CHG | Change from Baseline | Num | AVAL - BASE |
  | A1LO | Analysis Range Low Value | Num | Derived (e.g., SBP <90, DBP <60) |
  | A1HI | Analysis Range High Value | Num | Derived (e.g., SBP >140, DBP >90) |
  | ANRIND | Analysis Reference Range Indicator | Char | Derived from AVAL, A1LO, A1HI |
- **Population flags**: SAFFL (from ADSL)
- **Special derivations**: Categorical analysis flags (hypertension, hypotension), change from baseline

## Cross-reference to TLG shells

| TLG ID | TLG Title | Required ADaM | Key Variables Needed |
|--------|-----------|---------------|----------------------|
| T-14.1.1 | Subject Disposition | ADSL | USUBJID, TRT01P, COMPLFL, DISCONFL, DISCONREA |
| T-14.1.2 | Demographics and Baseline Characteristics | ADSL | AGE, AGEGR1, SEX, RACE, ETHNIC, WEIGHTBL, HEIGHTBL, BMIBL, MMSEBL, ADASCOGBL, CIBICBL, DISDURBL |
| T-14.1.3 | Medical History | ADMH | USUBJID, MHDECOD, MHBODSYS, MHOCCUR |
| T-14.1.4 | Prior and Concomitant Medications | ADCM | USUBJID, CMDECOD, CMCAT, CMOCCUR, CMPRIOR |
| T-14.1.5 | Study Drug Exposure Summary | ADEX | USUBJID, EXDUR, CUMDOSE, NEXP |
| T-14.2.1 | Primary Analysis: ADAS-Cog (11) at Week 24 | ADEFF | USUBJID, PARAMCD="ADAS11", AVISIT="Week 24", AVAL, BASE, CHG, TRTP |
| T-14.2.2 | Primary Analysis: CIBIC+ at Week 24 | ADEFF | USUBJID, PARAMCD="CIBIC", AVISIT="Week 24", AVAL, TRTP |
| T-14.2.3 | Secondary Analysis: ADAS-Cog (11) at Weeks 8 and 16 | ADEFF | USUBJID, PARAMCD="ADAS11", AVISIT=c("Week 8","Week 16"), AVAL, BASE, CHG, TRTP |
| T-14.2.4 | Secondary Analysis: CIBIC+ at Weeks 8 and 16 | ADEFF | USUBJID, PARAMCD="CIBIC", AVISIT=c("Week 8","Week 16"), AVAL, TRTP |
| T-14.2.5 | Secondary Analysis: Mean NPI-X from Week 4 to Week 24 | ADEFF | USUBJID, PARAMCD="NPI-X", AVISIT, AVAL (mean across visits) |
| T-14.2.6 | Change from Baseline in ADAS-Cog (11) by Visit | ADEFF | USUBJID, PARAMCD="ADAS11", AVISIT, AVAL, BASE, CHG, TRTP |
| T-14.2.7 | CIBIC+ Score Distribution by Visit | ADEFF | USUBJID, PARAMCD="CIBIC", AVISIT, AVAL, TRTP |
| T-14.2.8 | Subgroup Analysis of ADAS-Cog (11) at Week 24 | ADEFF, ADSL | USUBJID, PARAMCD="ADAS11", AVISIT="Week 24", AVAL, BASE, CHG, TRTP, SEX, AGE, RACE, MMSEBL |
| T-14.2.9 | Subgroup Analysis of CIBIC+ at Week 24 | ADEFF, ADSL | USUBJID, PARAMCD="CIBIC", AVISIT="Week 24", AVAL, TRTP, SEX, AGE, RACE, MMSEBL |
| T-14.3.1.1 | Overall Summary of Adverse Events | ADAE | USUBJID, TRTEMFL, TRTRELFL, SERFL, WDRAWFL, DSCHFL, DEATHFL, AETOXGR |
| T-14.3.1.2 | Treatment-Emergent AEs by SOC, PT, and Grade | ADAE | USUBJID, AEDECOD, AEBODSYS, TRTEMFL, AETOXGR |
| T-14.3.1.3 | Treatment-Related AEs by SOC, PT, and Grade | ADAE | USUBJID, AEDECOD, AEBODSYS, TRTRELFL, AETOXGR |
| T-14.3.1.4 | Serious Adverse Events by SOC, PT | ADAE | USUBJID, AEDECOD, AEBODSYS, SERFL |
| T-14.3.1.5 | AEs Leading to Treatment Discontinuation | ADAE | USUBJID, AEDECOD, DSCHFL |
| T-14.3.1.6 | Deaths Summary | ADAE, ADSL | USUBJID, DEATHFL, DTHDTC |
| T-14.3.2.1 | Laboratory Abnormalities by Worst Grade | ADLB | USUBJID, LBTESTCD, ANRIND, AETOXGR (if available) |
| T-14.3.2.2 | Laboratory Shift Table | ADLB | USUBJID, LBTESTCD, BASERIND, ANRIND |
| T-14.3.3.1 | Vital Signs Summary Statistics by Visit | ADVS | USUBJID, VSTESTCD, AVISIT, AVAL |
| T-14.3.3.2 | Vital Signs Categorical Analysis | ADVS | USUBJID, VSTESTCD, ANRIND |
| T-14.3.4.1 | ECG Parameters Summary | ADVS | USUBJID, VSTESTCD contains "ECG", AVAL |
| L-16.1.1 | Protocol Deviations Listing | ADSL | USUBJID, DISCONREA (if deviation) |
| L-16.3.1 | Death Listing | ADAE, ADSL | USUBJID, DTHDTC, AEDECOD (if AE-related) |
| L-16.3.2 | Serious Adverse Events Listing | ADAE | USUBJID, AEDECOD, AESTDTC, AEENDTC, AESER, AEREL, AEOUT |
| L-16.3.3 | AEs Leading to Discontinuation Listing | ADAE | USUBJID, AEDECOD, AESTDTC, DSCHFL |
| L-16.3.4 | Listing of All Adverse Events | ADAE | USUBJID, AEDECOD, AESTDTC, AEENDTC, AESEV, AEREL, AEOUT |
| L-16.3.5 | Patients with Grade ≥3 Laboratory Toxicities | ADLB | USUBJID, LBTESTCD, ANRIND, AETOXGR≥3 |
| L-16.2.1 | Individual Patient Efficacy Data | ADEFF | USUBJID, PARAMCD, AVISIT, AVAL, BASE, CHG, TRTP |
| L-16.1.2 | Concomitant Medications Listing | ADCM | USUBJID, CMDECOD, CMSTDTC, CMENDTC, CMROUTE, CMDOSE |
| F-15.1.1 | Mean Change from Baseline in ADAS-Cog Over Time | ADEFF | USUBJID, PARAMCD="ADAS11", AVISIT, CHG, TRTP |
| F-15.1.2 | CIBIC+ Score Distribution by Visit | ADEFF | USUBJID, PARAMCD="CIBIC", AVISIT, AVAL, TRTP |
| F-15.1.3 | Mean NPI-X Score Over Time | ADEFF | USUBJID, PARAMCD="NPI-X", AVISIT, AVAL, TRTP |
| F-15.2.1 | Time to First Treatment-Emergent Adverse Event | ADAE | USUBJID, TRTEMFL, AESTDY |
| F-15.2.2 | Time to First Grade ≥3 Adverse Event | ADAE | USUBJID, TRTEMFL, AETOXGR≥3, AESTDY |
| F-15.2.3 | Forest Plot: Subgroup Analysis of ADAS-Cog at Week 24 | ADEFF, ADSL | USUBJID, PARAMCD="ADAS11", AVISIT="Week 24", CHG, TRTP, SEX, AGE, RACE, MMSEBL |

## Derivation assumptions

1. **LOCF imputation**: Missing post-baseline efficacy values will be imputed using Last Observation Carried Forward as specified in the SAP.
2. **Visit windowing**: Analysis visits will be derived from collection visits using windowing rules from the protocol (±3 days for Visits 4,5,7,8,13; ±4 days for Visits 9,10,11,12).
3. **Treatment-emergent AEs**: AEs with onset on or after the first dose date through 30 days after the last dose.
4. **Efficacy population**: Subjects with at least one post-baseline assessment for both ADAS-Cog and CIBIC+.
5. **Baseline**: Data collected at Visit 3 (Week 0) as specified in the SAP.
6. **Shift categories**: Laboratory shift will use standard categories (LOW, NORMAL, HIGH) based on reference ranges.
7. **Subgroup definitions**: Age groups (<65, ≥65), race categories as collected, MMSE severity (Mild: 21-26, Moderate: 10-20).