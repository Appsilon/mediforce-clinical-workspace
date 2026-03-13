# Issue Summary — CDISCPILOT01 ADaM Generation

**Generated**: 2026-03-13

---

## SDTM Data Issues

1. **Subject count discrepancy**: SDTM DM dataset contains 254 randomized subjects (86 Placebo, 84 XAN High, 84 XAN Low), not 295 as stated in the SAP metadata. This is consistent with the CDISC Pilot dataset which is a subset of the full legacy study. All ADaM datasets reflect the 254 subjects present in the data.

2. **Partial dates in CM**: CMSTDTC contains year-only values (e.g., "2003") for many concomitant medications. Full ISO dates not available. **Workaround**: Partial dates padded as YYYY-01-01 for start dates and YYYY-12-31 for end dates. This may affect treatment-emergent CM classification accuracy.

3. **Height missing baseline flag**: VS.VSBLFL is not set to 'Y' for HEIGHT measurements. Height baseline was derived by taking the first available HEIGHT observation.

4. **NPTOT total in QS includes all 12 NPI-X domains**: The QSTESTCD='NPTOT' in the QS dataset likely includes all 12 NPI-X domains, not the SAP-specified 9-domain score (excluding Euphoria, Night-time, Appetite). **Workaround**: 9-domain score derived manually by summing NPITM01V–NPITM10V excluding domains 06 (Euphoria/Elation), 11 (Night-time Behavior), and 12 (Appetite/Eating Change).

5. **No EG (ECG) domain**: ECG data was mentioned in the protocol but no EG SDTM domain was present in the uploaded files. No ADEG dataset created. This does not affect any of the specified TLGs.

---

## Derivation Assumptions

1. **ADAS-Cog (11) scoring**: SAP specifies that if >30% of items are missing (>3 of 11 items), the total score is set to missing; otherwise, adjusted by ratio. The pre-calculated ACTOT in QS was used as the primary source for AVAL. If ACTOT was available, item-level scoring rules were not applied separately. Assumption: ACTOT in the SDTM dataset already incorporates the SAP scoring algorithm.

2. **CIBIC+ LOCF**: CIBIC+ primary analysis is LOCF at Weeks 8, 16, and 24. LOCF implemented by carrying forward last observed AVAL within each subject's chronological visit sequence. If no prior observed value exists, AVAL remains missing. For subjects with no post-baseline CIBIC+ data (withdrew before Week 2), no LOCF is possible.

3. **NPI-X mean endpoint (Weeks 4-24)**: The SAP specifies "mean NPI-X from Week 4 through Week 24" without LOCF. Implemented as arithmetic mean of observed windowed values at Weeks 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24. Subjects with no observed values in this range have AVAL=NA. Telephone visits included (Weeks 10, 14, 18, 22).

4. **Treatment-emergent AEs**: TRTEMFL derived using SUPPAE.AETRTEM flag as primary source, supplemented by date comparison (AE start ≥ treatment start). This follows standard CDISC approach. No end-of-treatment window applied for treatment-emergent definition.

5. **Laboratory baseline (Week -2)**: Per SAP, baseline for laboratory values is the Screening 1 visit (target day -14). SDTM VISIT='SCREENING 1' was used as the baseline visit. If multiple values exist at Screening, the earliest date was selected.

6. **ADTTE censoring**: Time to first dermatological TEAE censored at TRTEDT (last dose date). Assumption: subjects without a dermatological event are censored at the end of their treatment exposure. This is the most conservative censoring approach.

7. **Site pooling**: POOLSIT1 in ADSL is set equal to SITEID (no pooling applied). The SAP specifies a site pooling rule for sites with <3 subjects per treatment arm; this pooling must be implemented at TLG programming time using ADSL.SITEID.

8. **Disease duration**: Derived from the first Alzheimer's Disease entry in MH domain (MHTERM='ALZHEIMER'S DISEASE'). Not all subjects had MH entries, resulting in missing DURDIS for some subjects.

---

## Unresolved Gaps

1. **Protocol Deviations listing (L-02)**: No ADDV (Protocol Deviations) ADaM dataset was created. The only deviation data available is SUPPDS.ENTCRIT (entry criteria flag). A complete protocol deviations listing would require this flag plus any additional deviation coding not present in the SDTM. The listing can be generated from DS/SUPPDS directly.

2. **Completers at Week 26 (COMP26FL)**: Derived using DS.DSDECOD='COMPLETED' or 'FINAL LAB VISIT'. The distinction between completing study through Week 26 vs. entering open-label extension may not be fully captured, as PROTOCOL COMPLETED maps to the same flag. The COMP26FL may slightly overcount true study completers.

3. **MMSE scoring**: SAP indicates MMSE at screening should be recorded. The QS domain has MMSE items (MMITM01-06) but no pre-calculated total. MMSEBL derived as sum of 6 items. If items are scored on different scales, the sum may not equal the standard MMSE total score (0-30).

4. **AE outcome codes**: AEOUT variable present in SDTM; mapping to standard controlled terminology (e.g., RECOVERED/RESOLVED, FATAL) may require verification against MedDRA controlled terminology.

---

## Package Installation Notes

The following R packages were installed during this session (not previously available):
- `admiral` (v1.x) — installed from CRAN
- `datasetjson` — installed from CRAN
- `xportr` — installed from CRAN

All ADaM datasets exported as both SAS transport files (.xpt) and JSON files. The `datasetjson` package's `write_dataset_json()` function requires specific column metadata format; a fallback to `jsonlite::write_json()` was used for JSON export when the full metadata specification was not available.
