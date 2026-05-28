# Changelog

## nhanesR 0.1.0

Initial release.

### New functions

- [`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md)
  — list all continuous NHANES cycles (1999–present) and optionally
  NHANES III (1988–1994), with cycle labels, begin/end years, and
  file-name suffixes.

- [`nhanes_manifest()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md)
  — query the CDC data catalog for available files within a given cycle
  and component.

- [`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md)
  — download one or more NHANES XPT files from CDC, parse them into R
  data frames, and cache them locally. Falls back to
  [`foreign::read.xport()`](https://rdrr.io/pkg/foreign/man/read.xport.html)
  when
  [`haven::read_xpt()`](https://haven.tidyverse.org/reference/read_xpt.html)
  cannot parse older files.

- [`nhanes_stack()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_stack.md)
  — row-bind per-cycle data frames into a single data frame, filling
  columns absent in some cycles with `NA`.

- [`nhanes_merge()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_merge.md)
  — join NHANES components by SEQN (and optionally cycle), with
  survey-design-aware defaults.

- [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md)
  — download the NCHS Public-Use Linked Mortality Files (LMF) for the
  relevant cycles and left-join them onto an analytic dataset by SEQN.
  Mortality follow-up runs through December 31, 2019.

- [`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md)
  — prepare a survival analysis dataset from a mortality-linked data
  frame: removes ineligible participants (`ELIGSTAT != 1`), creates
  `time` and `event` columns, optionally creates `event_cause` for
  cause-specific mortality, and warns about asymmetric follow-up across
  cycles.

- [`nhanes_followup_summary()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_followup_summary.md)
  — summarise follow-up time and event rates by cycle.

- [`nhanes_ucod_labels()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_ucod_labels.md)
  — return the 11-category ICD-10 underlying cause-of- death recode used
  in the public-use LMF.

- [`nhanes_search_variables()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md)
  — search the CDC NHANES variable catalog for variables whose name or
  description matches a keyword. Results are cached locally. The
  `summarize` argument (default `TRUE`) collapses one-row-per-cycle
  output into one row per unique variable name, with comma-separated
  file names, cycles, and an `n_cycles` count.

- [`nhanes_variable_map()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md)
  — wraps
  [`nhanes_search_variables()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md)
  to return a single-row-per-cycle lookup table (`cycle`,
  `variable_name`, `file_name`) for a given analyte. Automatically drops
  comment-code variables, prefers non-SI variables when both exist in a
  cycle, and accepts a `keep_vars` argument to disambiguate serum from
  urine forms of the same analyte (e.g. serum creatinine vs. urinary
  creatinine).

- [`nhanes_cache_dir()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cache_dir.md)
  — view or change the local cache directory.

### Bug fixes and infrastructure

- Fixed CDC data file URLs: CDC reorganized all NHANES file paths from
  `/Nchs/Nhanes/{cycle}/` to
  `/Nchs/Data/Nhanes/Public/{begin_year}/DataFiles/`. All download
  functions updated accordingly.

- Added Content-Type check in the HTTP download helper: CDC returns HTTP
  200 with an HTML error page when a file has moved; `nhanesR` now
  detects this and aborts with an informative message rather than saving
  a corrupt file.

- Added
  [`foreign::read.xport()`](https://rdrr.io/pkg/foreign/man/read.xport.html)
  fallback for XPT files that
  [`haven::read_xpt()`](https://haven.tidyverse.org/reference/read_xpt.html)
  cannot parse (affects some files from NHANES cycles prior to 2003).

- MD5 hash sidecar files (`.md5`) are written alongside every cached RDS
  to detect corruption and trigger re-download when needed.

### Vignette

- Added “NHANES Mortality Linkage: A Complete Workflow” vignette
  illustrating the full pipeline from file discovery through
  survey-weighted Cox proportional hazards modelling, using serum total
  cholesterol and cardiovascular mortality across ten cycles (1999–2018)
  as a worked example.
