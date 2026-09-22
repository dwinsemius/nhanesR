# Urinary Albumin-to-Creatinine Ratio Across NHANES Cycles

## Overview

Urinary albumin-to-creatinine ratio (UACR) is a key marker of chronic
kidney disease (CKD) and cardiovascular risk. NHANES has measured
urinary albumin (`URXUMA`) across all ten continuous cycles (1999–2018),
making it well suited for pooled multi-cycle survival analyses.

This vignette illustrates two practical challenges that arise when
assembling UACR from NHANES:

1.  **File disambiguation**: urinary creatinine (`URXUCR`) appears in
    multiple laboratory files per cycle. In early cycles it was measured
    in both the albumin/creatinine file and several
    environmental-exposure files (phthalates, heavy metals).
    [`nhanes_variable_map()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md)
    may find it in the wrong file; we show how to use `keep_vars` to pin
    it to the correct source.

2.  **Method comparability**: NCHS changed the urinary albumin assay and
    analyser platform between cycles. Before pooling, analysts should
    consult the NHANES laboratory methods documents for each cycle and
    apply any published bridging equations.

------------------------------------------------------------------------

## Step 1 — Locate the variables

[`library`](https://rdrr.io/r/base/library.html)`(`[`nhanesR`](https://dwinsemius.github.io/nhanesR/)`)`` `` ``# Confirm URXUMA is present across all ten cycles`` `[`nhanes_search_variables`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md)`(``"albumin"``, component ``=`` ``"Laboratory"``)`` `` ``# Variable map for urinary albumin: maps cleanly to ALB_CR_* files`` ``map_uma`` ``<-`` `[`nhanes_variable_map`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md)`(``"URXUMA"``)`` ``map_uma`

`# nhanes_variable_map("URXUCR") resolves to the wrong file in early cycles:`` ``# URXUCR appears in phthalates / heavy-metals files (e.g. PHPYPA 1999-2000)`` ``# as a dilution-adjustment variable, and the catalog finds those first.`` `[`nhanes_variable_map`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md)`(``"URXUCR"``)`

The early-cycle rows point to files such as `PHPYPA` (1999–2000) and
`SSNO3P_B` (2001–2002). These are not the source we want.

The solution is simpler than it first appears:
[`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md)
downloads the **complete** file for each cycle, not just the named
variable. The albumin/creatinine files (`LAB16`, `L16_B`, `L16_C`,
`ALB_CR_*`) contain both `URXUMA` and `URXUCR` together, so downloading
via `URXUMA` gives us both variables in a single pass.

------------------------------------------------------------------------

## Step 2 — Download and stack

`# Restrict to cycles with public-use mortality linkage (1999-2018)`` ``cycles`` ``<-`` `[`nhanes_cycles`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md)`(``)``[`[`nhanes_cycles`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md)`(``)``$``has_lmf_public``, ``"cycle"``]`` `` ``# nhanes_download_analyte resolves the changing file name automatically.`` ``# Each returned data frame contains the full ALB_CR file — including`` ``# URXUMA (urinary albumin) AND URXUCR (urinary creatinine).`` ``alb_cr_list`` ``<-`` `[`nhanes_download_analyte`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md)`(``"URXUMA"``, ``cycles``)`` ``alb_cr`` ``<-`` `[`nhanes_stack`](https://dwinsemius.github.io/nhanesR/reference/nhanes_stack.md)`(``alb_cr_list``)`

------------------------------------------------------------------------

## Step 3 — Calculate UACR

NHANES reports:

| Variable | Units          |
|----------|----------------|
| `URXUMA` | ug/mL (= mg/L) |
| `URXUCR` | mg/dL          |

The conversion to mg/g is:

``` math
\text{UACR (mg/g)} = \frac{\text{URXUMA (mg/L)}}{\text{URXUCR (mg/dL)} \times 0.01 \text{ (g/dL per mg/dL)}} = \frac{100 \times \text{URXUMA}}{\text{URXUCR}}
```

`alb_cr``$``UACR`` ``<-`` `[`with`](https://rdrr.io/r/base/with.html)`(``alb_cr``, ``100`` ``*`` ``URXUMA`` ``/`` ``URXUCR``)`` `` ``# Clinical thresholds (KDIGO 2012)`` ``alb_cr``$``UACR_cat`` ``<-`` `[`cut`](https://rdrr.io/r/base/cut.html)`(`` `` ``alb_cr``$``UACR``,`` `` breaks ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0``, ``30``, ``300``, ``Inf``)``,`` `` labels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Normal-mildly increased (<30)"``,`` `` ``"Moderately increased (30-300)"``,`` `` ``"Severely increased (>300)"``)``,`` `` right ``=`` ``FALSE`` ``)`

------------------------------------------------------------------------

## Step 4 — Method comparability and bridging

### Known method changes

NCHS changed the urinary albumin assay platform and reagents in
**\[VERIFY: exact cycle transition\]**. Analysts pooling data across
this transition should check the NHANES laboratory methods documentation
for each cycle and apply published bridging equations before pooling if
values are not directly comparable.

`# The NHANES laboratory methods document for each cycle is linked from the`` ``# online data browser. For urinary albumin (ALB_CR files), look for entries`` ``# under "Albumin, Urine" describing the analyser make/model and reagent kit.`` ``# Key things to record for each cycle:`` ``# - Analyser (e.g. Roche Hitachi 917, Beckman UniCel DxC 800, ...)`` ``# - Reagent/method (immunoturbidimetric, immunonephelometric, ...)`` ``# - Calibrator traceability (JCTLM-listed reference material?)`` ``# - LOD (ug/mL) -- differs across cycles`

### Bridging equations for serum creatinine

As a reference example of how NCHS handles bridging, serum creatinine
(`LBXSCR`) was transitioned from the Jaffe (alkaline picrate) method to
the enzymatic/IDMS-traceable method around the 2007–2008 cycle. NCHS
published regression-based bridging equations to convert Jaffe values to
the enzymatic scale, enabling pooling across the transition. See the
NHANES laboratory methods documentation and the NKDEP guidance for the
specific equations.

Urinary creatinine (`URXUCR`) may require analogous treatment if method
changes are identified in the laboratory methods documents.

------------------------------------------------------------------------

## Step 5 — Survival analysis with survey weights

Once UACR is assembled and any bridging applied, the workflow follows
the standard nhanesR mortality linkage pipeline.

[`library`](https://rdrr.io/r/base/library.html)`(`[`survival`](https://github.com/therneau/survival)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`survey`](http://r-survey.r-forge.r-project.org/survey/)`)`` `` ``# Link mortality`` ``alb_cr_mort`` ``<-`` `[`nhanes_mortality_link`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md)`(``alb_cr``)`` ``alb_cr_surv`` ``<-`` `[`nhanes_survival_prep`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md)`(`` `` ``alb_cr_mort``,`` `` origin ``=`` ``"exam"``,`` `` time_unit ``=`` ``"years"``,`` `` weight_var ``=`` ``"WTMEC2YR"`` ``)`` `` ``# Survey design`` `[`options`](https://rdrr.io/r/base/options.html)`(``survey.lonely.psu ``=`` ``"adjust"``)`` ``svy`` ``<-`` `[`svydesign`](https://rdrr.io/pkg/survey/man/svydesign.html)`(`` `` ids ``=`` ``~``SDMVPSU``,`` `` strata ``=`` ``~``SDMVSTRA``,`` `` weights ``=`` ``~``survey_weight``,`` `` nest ``=`` ``TRUE``,`` `` data ``=`` ``alb_cr_surv`` ``)`` `` ``# Unadjusted rate by UACR category`` `[`svyby`](https://rdrr.io/pkg/survey/man/svyby.html)`(``~``event``, ``~``UACR_cat``, ``svy``, ``svymean``, na.rm ``=`` ``TRUE``)`

------------------------------------------------------------------------

## Notes and caveats

- The 2017–2020 pre-pandemic file (`P_ALB_CR`) should be used instead of
  the 2017–2018 file in pooled analyses to avoid double-counting
  participants.
  [`nhanes_variable_map()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md)
  will warn about this overlap.

- Spot urine samples (used here) are subject to substantial
  within-person variability. Single-void UACR is standard in
  epidemiological cohorts but regression dilution bias should be
  considered in exposure-response analyses.

- UACR below the limit of detection (`URXUMA < LOD`) should be handled
  using standard methods (e.g. LOD/sqrt(2) substitution). The LOD varies
  by cycle and is documented in the NHANES laboratory methods pages.

------------------------------------------------------------------------

## See also

- [`nhanes_variable_map()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md)
  for cross-cycle variable file disambiguation
- [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md)
  for adding NCHS mortality follow-up
- [`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md)
  for constructing time and event columns
- [`nhanes_harmonize()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_harmonize.md)
  for unit harmonization across cycles
