# TLG-to-ADaM Cross-Reference — CDISCPILOT01

**Generated**: 2026-03-13

## TLG-to-ADaM Cross-Reference

| TLG ID | TLG Title | Required ADaM | Status | Notes |
|--------|-----------|---------------|--------|-------|
| T-01 | Summary of Populations | ADSL | **OK** | ITTFL, SAFFL, EFFFL, COMPFL, COMP26FL, EOSSTT present |
| T-02 | Summary of End of Study Data | ADSL | **OK** | EOSSTT, DCDECOD, DCREASCD, TRT01A present |
| T-03 | Summary of Demographic and Baseline Characteristics | ADSL | **OK** | AGE, SEX, RACE, MMSEBL, BMIBL, HEIGHTBL, WEIGHTBL, DURDIS, EDUCLVL present |
| T-04 | Summary of Number of Subjects by Site | ADSL | **OK** | SITEID, ITTFL, EFFFL, COMPFL present |
| T-05 | Primary: ADAS-Cog (11) Change from Baseline to Week 24 (LOCF) | ADQSADAS | **OK** | AVAL, BASE, CHG at Week 24 with LOCF; EFFFL population |
| T-06 | Primary: CIBIC+ Summary at Week 24 (LOCF) | ADQSCIBC | **OK** | AVAL at Week 24 with LOCF; EFFFL population |
| T-07 | ADAS-Cog (11) Change from Baseline to Week 8 (LOCF) | ADQSADAS | **OK** | Week 8 AVAL/CHG with LOCF |
| T-08 | CIBIC+ Summary at Week 8 (LOCF) | ADQSCIBC | **OK** | Week 8 AVAL with LOCF |
| T-09 | ADAS-Cog (11) Change from Baseline to Week 16 (LOCF) | ADQSADAS | **OK** | Week 16 AVAL/CHG with LOCF |
| T-10 | CIBIC+ Summary at Week 16 (LOCF) | ADQSCIBC | **OK** | Week 16 AVAL with LOCF |
| T-11 | ADAS-Cog (11) Change from Baseline to Week 24, Completers | ADQSADAS | **OK** | Non-LOCF records at Week 24; COMPFL for filtering |
| T-12 | ADAS-Cog (11) Change from Baseline to Week 24 – Males (LOCF) | ADQSADAS | **OK** | SEX variable in dataset for subgroup filtering |
| T-13 | ADAS-Cog (11) Change from Baseline to Week 24 – Females (LOCF) | ADQSADAS | **OK** | SEX variable in dataset for subgroup filtering |
| T-14 | ADAS-Cog (11) Mean Score and Change Over Time | ADQSADAS | **OK** | All 4 analysis visits present; AVAL and CHG |
| T-15 | ADAS-Cog (11) MMRM Repeated Measures Analysis | ADQSADAS | **OK** | Observed (non-LOCF) values available for MMRM |
| T-16 | Mean NPI-X Total Score from Week 4 Through Week 24 | ADQSNPIX | **OK** | NPTMN24 parameter (mean Weeks 4-24); NPTOT9 for visit-level |
| T-17 | Summary of Planned Exposure to Study Drug | ADEX | **OK** | AVGDOSE, CUMEXDOS, TOTEXDUR by SAFFL/COMPFL |
| T-18 | Incidence of Treatment-Emergent Adverse Events by SOC/PT | ADAE | **OK** | TRTEMFL, AEBODSYS, AEDECOD, TRT01A present |
| T-19 | Incidence of Treatment-Emergent Serious Adverse Events | ADAE | **OK** | AESERF='Y' + TRTEMFL='Y' for SAE filter |
| T-20 | Summary Statistics for Continuous Laboratory Values by Visit | ADLB | **OK** | AVAL, BASE, CHG by PARAMCD and AVISITN |
| T-21 | Frequency of Normal/Abnormal Lab Values During Treatment | ADLB | **OK** | ANRIND, CRITFL present |
| T-22 | Frequency of Clinically Significant Lab Changes | ADLB | **OK** | ANRIND, BNRIND, CRITFL for change-from-previous-visit analyses |
| T-23 | Shifts of Lab Values by Visit (Threshold Ranges) | ADLB | **OK** | SHIFT1, SHIFT1BL, SHTBL1, AVISITN present |
| T-24 | Shifts of Lab Values Overall (CMH test) | ADLB | **OK** | Same as T-23 aggregated |
| T-25 | Shifts of Hy's Law Values | ADLB | **OK** | ALT, AST, BILI parameters present; shift variables available |
| T-26 | Summary of Vital Signs at Baseline and End of Treatment | ADVS | **OK** | SYSBP, VSSBPST, DIABP, VSDBPST, PULSE, VSPULST, BASE, AVAL at key visits |
| T-27 | Summary of Vital Signs Change from Baseline at End of Treatment | ADVS | **OK** | CHG at Week 24 / end of treatment |
| T-28 | Summary of Weight Change from Baseline at End of Treatment | ADVS + ADSL | **OK** | WEIGHT paramcd in ADVS; WEIGHTBL in ADSL |
| T-29 | Summary of Concomitant Medications | ADCM | **OK** | CMTRT, CMDECOD, CMCLAS1 by TRT01A |
| T-30 | CIBIC+ Categorical Analysis (Ad hoc, FDA Request) | ADQSCIBC | **OK** | AVAL (1-7 scale) at Weeks 8/16/24 for categorical grouping |
| F-01 | Time to First Dermatological Event (Kaplan-Meier) | ADTTE | **OK** | TTDERM parameter: AVAL (days), CNSR, by TRT01A |
| L-01 | Subject Disposition Listing | ADSL | **OK** | EOSSTT, DCDECOD, DCREASCD present |
| L-02 | Protocol Deviations Listing | ADSL/SUPPDS | **PARTIAL** | SUPPDS.ENTCRIT available; no separate ADDV dataset created |
| L-03 | Deaths Listing | ADAE | **OK** | AESDTHFL derived from AESDTH; TRT01A present |
| L-04 | Serious Adverse Events Listing | ADAE | **OK** | AESERF='Y' filter; all AE details present |
| L-05 | AEs Leading to Study Drug Discontinuation Listing | ADAE + ADSL | **OK** | AEACN='DRUG WITHDRAWN' + ADSL.DCDECOD='ADVERSE EVENT' |
| L-06 | Treatment-Emergent Adverse Events Listing | ADAE | **OK** | TRTEMFL='Y' with full AE details |

## Summary

- **Total TLGs evaluated**: 37
- **Fully supported (OK)**: 36
- **Partially supported (PARTIAL)**: 1 (L-02: Protocol Deviations — uses SUPPDS but no separate ADDV dataset)
- **Not supported**: 0

## Notes

1. **T-15 MMRM**: Observed (non-LOCF) values are available in ADQSADAS (records without DTYPE='LOCF'). The MMRM model itself is computed at TLG programming time, not stored in ADaM.
2. **T-25 Hy's Law**: ALT (ALAT), AST (ASAT), and BILI parameters are present in ADLB. The Hy's Law shift table requires: any visit with ALT or AST >3×ULN AND BILI >2×ULN. ULN is available via ANRHI.
3. **L-02 Protocol Deviations**: SUPPDS contains ENTCRIT flag for entry criteria deviations. A full ADDV dataset is not required since SAP does not specify a protocol deviations table in the formal TLG shells; the listing can be derived from DS+SUPPDS.
4. **T-28 Weight**: ADVS contains WEIGHT parameter with BASE and CHG. ADSL has WEIGHTBL for demographic table.
5. **Population note**: Data contains 254 randomized subjects (vs. 295 stated in SAP metadata). This reflects the actual CDISC Pilot dataset.
