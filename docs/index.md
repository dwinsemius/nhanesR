Download, harmonize, and analyze NHANES data with mortality linkage.

## Overview

`nhanesR` provides a structured workflow for working with
[NHANES](https://www.cdc.gov/nchs/nhanes/) (National Health and
Nutrition Examination Survey) public-use data and the NCHS Public-Use
Linked Mortality Files (LMF). It handles the main friction points in
multi-cycle NHANES analysis:

- File names change across cycles (e.g. total cholesterol: `LAB13` →
  `L13_B` → `L13_C` → `TCHOL_D` onward)
- Variable names change across cycles (e.g. HDL: `LBDHDL` → `LBXHDD` →
  `LBDHDD`)
- SI-unit duplicate columns appear alongside conventional-unit columns
  in the same file
- Mortality linkage requires fixed-width file parsing and SEQN joining
  across cycles

## Installation

`# install.packages("remotes")`` ``remotes``::`[`install_github`](https://remotes.r-lib.org/reference/install_github.html)`(``"dwinsemius/nhanesR"``, build_vignettes ``=`` ``TRUE``, force ``=`` ``TRUE``)`

**Requirements:** R ≥ 4.1.0. The following packages are used optionally
and will be requested if needed:

- `rvest` — required for
  [`nhanes_manifest()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md)
  and
  [`nhanes_search_variables()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md)
- `foreign` — fallback parser for older XPT files (pre-2003 cycles)
- `survey`, `survival` — for the vignette examples

## Quick start

[`library`](https://rdrr.io/r/base/library.html)`(`[`nhanesR`](https://dwinsemius.github.io/nhanesR/)`)`` `` ``# 1. Find available cycles`` ``cycles`` ``<-`` `[`nhanes_cycles`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md)`(``)``[[``"cycle"``]``]`` ``# character vector of all cycle labels`` `` ``# 2. Browse files available in a cycle`` `[`nhanes_manifest`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md)`(``"2015-2016"``, ``"Laboratory"``)`` `` ``# 3. Search the variable catalog by keyword`` `[`nhanes_search_variables`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md)`(``"total cholesterol"``, component ``=`` ``"Laboratory"``)`` `[`nhanes_variable_map`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md)`(``"total cholesterol"``)`` ``# per-cycle file/variable lookup`` `` ``# 4. Download — use nhanes_download_analyte() when file names changed across cycles`` ``demo_list`` ``<-`` `[`nhanes_download`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md)`(``"DEMO"``, ``cycles``[``1``:``10``]``)`` ``# stable name`` ``tchol_list`` ``<-`` `[`nhanes_download_analyte`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md)`(``"total cholesterol"``, ``# resolves renames`` `` ``cycles``[``1``:``10``]``)`` `` ``# 5. Harmonize variable names and stack into one data frame`` ``TC`` ``<-`` `[`nhanes_harmonize`](https://dwinsemius.github.io/nhanesR/reference/nhanes_harmonize.md)`(``tchol_list``,`` `` unit ``=`` ``"mg/dL"``,`` `` name ``=`` ``"TC_mgdl"``,`` `` label_pattern ``=`` ``"total cholesterol"``)`` `` ``# 6. Merge components by SEQN`` ``demo`` ``<-`` `[`nhanes_stack`](https://dwinsemius.github.io/nhanesR/reference/nhanes_stack.md)`(``demo_list``)`` ``analytic`` ``<-`` `[`nhanes_merge`](https://dwinsemius.github.io/nhanesR/reference/nhanes_merge.md)`(``demo``, ``TC``, by ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"SEQN"``, ``"cycle"``)``)`` `` ``# 7. Link mortality follow-up (through December 31, 2019)`` ``analytic_mort`` ``<-`` `[`nhanes_mortality_link`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md)`(``analytic``)`` `` ``# 8. Prepare survival dataset`` ``surv_data`` ``<-`` `[`nhanes_survival_prep`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md)`(``analytic_mort``,`` `` origin ``=`` ``"exam"``,`` `` time_unit ``=`` ``"years"``,`` `` weight_var ``=`` ``"WTMEC2YR"``)`

## Configuration

Downloaded files are cached locally. Three options control behavior —
set them in `~/.Rprofile` to make changes permanent:

[`options`](https://rdrr.io/r/base/options.html)`(`` `` nhanesR.cache_dir ``=`` ``"/path/to/cache"``, ``# default: tempdir()/nhanesR (session only)`` `` nhanesR.verbose ``=`` ``FALSE``, ``# suppress progress messages`` `` nhanesR.timeout ``=`` ``300L`` ``# HTTP timeout in seconds`` ``)`

View or change the cache location interactively:

[`nhanes_cache_dir`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cache_dir.md)`(``)`` ``# show current path`` `[`nhanes_cache_dir`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cache_dir.md)`(``"~/my_nhanes_cache"``)`` ``# change for this session`

## Vignettes

Two vignettes are included:

`# Package overview and complete function map`` `[`vignette`](https://rdrr.io/r/utils/vignette.html)`(``"nhanesR-overview"``, package ``=`` ``"nhanesR"``)`` `` ``# Full worked example: TC/HDL and all-cause mortality across 10 cycles`` ``# with survey-weighted Cox proportional hazards model`` `[`vignette`](https://rdrr.io/r/utils/vignette.html)`(``"nhanes-mortality-workflow"``, package ``=`` ``"nhanesR"``)`

## Function reference

| Stage | Functions |
|----|----|
| Discovery | [`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md), [`nhanes_manifest()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md) |
| Variable search | [`nhanes_search_variables()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md), [`nhanes_variable_map()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md) |
| Download | [`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md), [`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md) |
| Harmonize / stack / merge | [`nhanes_harmonize()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_harmonize.md), [`nhanes_stack()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_stack.md), [`nhanes_merge()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_merge.md) |
| Variable labelling | [`NH_label()`](https://dwinsemius.github.io/nhanesR/reference/NH_label.md), [`NH_describe()`](https://dwinsemius.github.io/nhanesR/reference/NH_describe.md) |
| Mortality linkage | [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md), [`nhanes_mortality_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_download.md), [`nhanes_mortality_parse()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_parse.md), [`nhanes_lmf_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_lmf_cycles.md) |
| Survival prep | [`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md), [`nhanes_followup_summary()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_followup_summary.md), [`nhanes_ucod_labels()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_ucod_labels.md) |
| Survey-weighted Cox | [`svycph_fuse()`](https://dwinsemius.github.io/nhanesR/reference/svycph_fuse.md), [`weighted_basehaz()`](https://dwinsemius.github.io/nhanesR/reference/weighted_basehaz.md), [`svycph_set_basehaz()`](https://dwinsemius.github.io/nhanesR/reference/svycph_set_basehaz.md) |
| Cache | [`nhanes_cache_dir()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cache_dir.md) |

## Acknowledgements

Developed with assistance from [Claude Code](https://claude.ai/code)
(Anthropic).
