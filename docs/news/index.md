# Changelog

## nhanesR 0.1.7

### New features

- Added NHIS Household/Person raw-data download:
  [`nhis_download()`](https://dwinsemius.github.io/nhanesR/reference/nhis_download.md)
  and
  [`nhis_data_years()`](https://dwinsemius.github.io/nhanesR/reference/nhis_data_years.md)
  download the fixed-width `.zip` for either file (1986-2018), download
  the matching SAS input-syntax file NCHS publishes alongside it, and
  parse both together via
  [`SAScii::read.SAScii()`](https://rdrr.io/pkg/SAScii/man/read.SAScii.html)
  (`SAScii`, Suggests only, GPL-2\|GPL-3 – confirmed compatible with
  this package’s MIT license; gated behind
  [`.nhanes_check_pkg()`](https://dwinsemius.github.io/nhanesR/reference/dot-nhanes_check_pkg.md),
  same pattern as the `foreign` fallback XPT parser) – reusing NCHS’s
  own column- position specification rather than a hand-built one,
  verified directly against the real 1986 and 1997 files before relying
  on it. Deliberately scoped to just these two “core” files, not the
  full NHIS catalog (dozens of supplemental modules with heavy
  year-to-year schema churn – out of scope). Column names for 1986-1996
  are NCHS’s own placeholder scheme (`HH_22`, `PX_24`, …) as that’s what
  those years’ SAS syntax literally contains; no relabeling crosswalk
  yet (would need `NHISCORE.PDF`). One confirmed real data gap: 1989’s
  Household file is absent from the CDC server (404) despite that year’s
  own documentation listing it – Person is unaffected; see
  [`?nhis_data_years`](https://dwinsemius.github.io/nhanesR/reference/nhis_data_years.md)
  for the full account.
- Added NHIS mortality-linkage support:
  [`nhis_mortality_download()`](https://dwinsemius.github.io/nhanesR/reference/nhis_mortality_download.md),
  [`nhis_mortality_parse()`](https://dwinsemius.github.io/nhanesR/reference/nhis_mortality_parse.md),
  [`nhis_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhis_mortality_link.md),
  and
  [`nhis_lmf_years()`](https://dwinsemius.github.io/nhanesR/reference/nhis_lmf_years.md)
  download, parse, and join NCHS’s public-use NHIS Linked Mortality
  Files (1986-2018, one file per survey year), mirroring the existing
  `nhanes_mortality_*()` family. nhanesR does not download NHIS survey
  data itself (a much larger undertaking than NHANES’s stable catalog,
  out of scope for now) – these functions join onto NHIS data supplied
  from elsewhere (e.g. IPUMS NHIS or NCHS’s own NHIS microdata site).
  Unlike NHANES’s `SEQN`, NHIS’s `PUBLICID` is not confirmed unique
  across survey years, so
  [`nhis_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhis_mortality_link.md)
  matches on `(PUBLICID, year)` rather than the ID alone. There is no
  `nhis_survival_prep()`: the NHIS LMF has no
  `PERMTH_INT`/`PERMTH_EXM`-equivalent person-months variable, only
  `DODQTR`/`DODYEAR`, so follow-up time construction requires the NHIS
  interview date from the survey data itself.

### Bug fixes

- [`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md)
  now automatically applies CDC-compliant pooled multi-cycle weight
  scaling instead of only warning about it. If both `1999-2000` and
  `2001-2002` are present and the matching 4-year weight column exists
  (e.g. `WTMEC4YR`), those cycles are scaled as `4-year weight * (2/n)`;
  all other cycles are scaled as `2-year weight * (1/n)`. Falls back to
  `2-year weight * (1/n)` for all cycles if the matching 4-year column
  is unavailable. The original unscaled 2-year weight is preserved in a
  new `survey_weight_2yr_raw` column. Warns if `WTMEC4YR` is supplied
  with more than two pooled cycles.

### CRAN resubmission fixes

- Removed the `~/my_nhanes_cache` example path that CRAN flagged as a
  HOME-directory write during
  [`example()`](https://rdrr.io/r/utils/example.html);
  examples/vignettes now use
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html).
- Removed `Hmisc::html(Hmisc::describe(...))` examples that triggered an
  HTML viewer popup during checks.
- Updated GitHub Actions `actions/checkout` and
  `actions/upload-artifact` to v5 (Node.js 20 deprecation).

### Documentation

- [`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md)
  docs and the `nhanes-mortality-workflow.Rmd` /
  `survey-weighted-survival.Rmd` vignettes updated to describe the new
  automatic pooled-weight behavior and to stop demonstrating manual
  `survey_weight / n_cycles` division (which would now double-scale).

## nhanesR 0.1.4

### CRAN resubmission fixes

- Expanded all unexpanded acronyms in `DESCRIPTION`: “NCHS” → “National
  Center for Health Statistics (NCHS)” and “NDI” → “National Death Index
  (NDI)”.
- Added NHANES methodology URL reference to `DESCRIPTION`.
- Replaced all `\dontrun{}` with `\donttest{}` in examples; all examples
  require CDC network access so none were unwrapped.
- Fixed `\d` regex in `NH_describe` documentation (unknown Rd macro on
  Windows); replaced with `[0-9]`.

### Bug fixes

- Removed “2017-2020” from the internal LMF registry: CDC has not
  published `NHANES_2017_2020_MORT_2019_PUBLIC.dat`; `has_lmf_public`
  set to `FALSE` for that cycle.
- Fixed `cli` pluralization crash in
  [`nhanes_merge()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_merge.md)
  when duplicate columns are found (`{i}` and `{?s}` quantity conflict
  resolved with
  [`cli::qty()`](https://cli.r-lib.org/reference/pluralization-helpers.html)).
- Fixed several example bugs exposed by switching from `\dontrun` to
  `\donttest`: missing `cycles` argument in
  [`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md)
  calls; list passed to
  [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md)
  instead of a stacked data frame; undefined `linked_data` object in
  [`nhanes_followup_summary()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_followup_summary.md)
  example.

## nhanesR 0.1.3

### Bug fixes

- Default cache directory changed from a platform-specific path under
  `~` to `file.path(tempdir(), "nhanesR")`. This prevents nhanesR from
  writing to the user’s home filespace without explicit consent, in
  compliance with CRAN Policy. To retain a persistent cache across
  sessions, set `nhanesR.cache_dir` in `~/.Rprofile`.
- `nhanes_cache_dir("~/my_nhanes_cache")` example wrapped in
  `\dontrun{}` to prevent directory creation during `R CMD CHECK`.

## nhanesR 0.1.2

### Bug fixes

- Fixed broken CDC mortality linkage URL in three vignettes (CDC
  reorganised their site; updated to current NCHS Data Linkage landing
  page).
- Removed non-standard sentence from `DESCRIPTION`.
- Added `inst/WORDLIST` to suppress spell-check NOTEs for domain
  abbreviations (NHANES, NCHS, LMF, NDI) and “codebook”.

## nhanesR 0.1.1

### Breaking changes

- [`nhanes_harmonize()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_harmonize.md):
  the `prefer_mgdl` argument has been replaced by
  `units = c("conventional", "SI", "both")`. The default
  (`"conventional"`) preserves prior behaviour; set `units = "SI"` to
  retain SI columns and drop conventional duplicates instead.

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
  — summarize follow-up time and event rates by cycle.

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
  survey-weighted Cox proportional hazards modeling, using serum total
  cholesterol and cardiovascular mortality across ten cycles (1999–2018)
  as a worked example.
