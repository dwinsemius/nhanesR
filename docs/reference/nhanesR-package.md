# nhanesR: Download, Parse, and Analyze NHANES Data with Mortality Linkage

Tools for downloading and organizing National Health and Nutrition
Examination Survey (NHANES) public-use data files and the National
Center for Health Statistics (NCHS) Public-Use Linked Mortality Files,
with structured local caching, codebook access, survey-aware merging,
survival-analysis data preparation, NHIS download and mortality linkage,
and descriptive mortality-rate tabulation.

## Vignettes

Start with
[`vignette("nhanesR-overview", package = "nhanesR")`](https://dwinsemius.github.io/nhanesR/articles/nhanesR-overview.md).
All of them are listed by `browseVignettes("nhanesR")`.

- `nhanesR-overview`: Getting Started with nhanesR.

- `nhanes-mortality-workflow`: NHANES Mortality Linkage, a complete
  workflow.

- `nhanes-iii`: NHANES III (1988-1994), fixed-width files, cotinine and
  mortality.

- `analyte-harmonization`: Navigating variable name changes and analyte
  gaps.

- `uacr-bridging`: Urinary albumin-to-creatinine ratio across NHANES
  cycles.

- `survey-weighted-survival`: Survey-weighted survival analysis, fusing
  `svycoxph` and `rms`.

- `survival-framework-comparison`: Comparing Cox, piecewise-exponential
  and mgcv-Poisson survival frameworks.

Vignettes are built when the package is installed from a built tarball
(for example `R CMD build` then `R CMD INSTALL`, or
`devtools::install(build_vignettes = TRUE)`); an install straight from
the source directory leaves them out.

## Main groups of functions

- Discovery:
  [`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md),
  [`nhanes_manifest()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md),
  [`nhanes_search_variables()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md),
  [`nhanes_variable_map()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md).

- Download, harmonize, stack and merge:
  [`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md),
  [`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md),
  [`nhanes_harmonize()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_harmonize.md),
  [`nhanes_stack()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_stack.md),
  [`nhanes_merge()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_merge.md).

- NHANES III fixed-width files:
  [`nhanes3_files()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_files.md),
  [`nhanes3_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_download.md),
  [`nhanes3_layout()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_layout.md)
  (browse variables and labels),
  [`nhanes3_read()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_read.md)
  (read chosen columns).

- Mortality linkage:
  [`nhanes_mortality_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_download.md),
  [`nhanes_mortality_parse()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_parse.md),
  [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md),
  and the NHIS counterparts
  [`nhis_download()`](https://dwinsemius.github.io/nhanesR/reference/nhis_download.md)
  and
  [`nhis_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhis_mortality_link.md).

- Survival preparation and summaries:
  [`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md),
  [`nhanes_followup_summary()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_followup_summary.md),
  [`nhanes_ucod_labels()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_ucod_labels.md).

- Survey-weighted Cox models:
  [`svycph_fuse()`](https://dwinsemius.github.io/nhanesR/reference/svycph_fuse.md),
  [`weighted_basehaz()`](https://dwinsemius.github.io/nhanesR/reference/weighted_basehaz.md),
  [`svycph_set_basehaz()`](https://dwinsemius.github.io/nhanesR/reference/svycph_set_basehaz.md).

- Descriptive rates:
  [`mortality_tabulation()`](https://dwinsemius.github.io/nhanesR/reference/mortality_tabulation.md),
  [`tabulation_grid()`](https://dwinsemius.github.io/nhanesR/reference/tabulation_grid.md).

## See also

Useful links: <https://dwinsemius.github.io/nhanesR/> and
<https://github.com/dwinsemius/nhanesR>.

## Author

**Maintainer**: David Winsemius <dwinsemius@comcast.net>

Authors:

- David Winsemius <dwinsemius@comcast.net>
