# Getting Started with nhanesR

## What nhanesR does

nhanesR provides a structured workflow for downloading, caching,
harmonizing, and analyzing data from the National Health and Nutrition
Examination Survey (NHANES), including linkage to the NCHS Public-Use
Linked Mortality Files (LMF).

The package handles the main friction points in working with NHANES:

- File names change across cycles (e.g. total cholesterol: `LAB13` →
  `L13_B` → `L13_C` → `TCHOL_D` onward).
- Variable names change across cycles (e.g. HDL: `LBDHDL` → `LBXHDD` →
  `LBDHDD`).
- SI-unit duplicates appear in the same file alongside conventional-unit
  columns.
- Mortality linkage requires fixed-width file parsing and SEQN joining
  across cycles.

------------------------------------------------------------------------

## Installation

``` r
# Install from GitHub (includes vignettes)
remotes::install_github("dwinsemius/nhanesR",
                        build_vignettes = TRUE,
                        force           = TRUE)
library(nhanesR)
```

------------------------------------------------------------------------

## Setup and options

Three options control nhanesR behaviour. The package sets defaults at
load time, but any option already defined in your `.Rprofile` takes
precedence — nhanesR only sets an option if it is not already defined.

| Option | Default | Purpose |
|----|----|----|
| `nhanesR.cache_dir` | OS user-data directory (see below) | Root path for all cached RDS and `.dat` files |
| `nhanesR.verbose` | `TRUE` | Print progress messages during downloads |
| `nhanesR.timeout` | `120L` | HTTP request timeout in seconds |

### Default cache locations by platform

| Platform | Path                                                   |
|----------|--------------------------------------------------------|
| macOS    | `~/Library/Application Support/nhanesR`                |
| Linux    | `~/.local/share/nhanesR` (or `$XDG_DATA_HOME/nhanesR`) |
| Windows  | `%APPDATA%/nhanesR`                                    |

Downloaded files are parsed, stored as RDS, and verified with an MD5
hash sidecar on every subsequent load. Re-downloading is skipped unless
`refresh = TRUE` is passed.

### Permanent configuration via `.Rprofile`

Add any of these lines to `~/.Rprofile` to persist settings across
sessions:

``` r
options(
  nhanesR.cache_dir = "/data/nhanes_cache",  # e.g. a shared server path
  nhanesR.verbose   = FALSE,                  # suppress progress messages
  nhanesR.timeout   = 300L                    # 5-minute timeout
)
```

### Checking and changing settings interactively

``` r
nhanes_cache_dir()                   # view current cache path
nhanes_cache_dir("~/my_nhanes_cache") # change for this session
options(nhanesR.verbose = FALSE)     # suppress messages for this session
```

------------------------------------------------------------------------

## Function map

Functions are organized below by workflow stage. Each entry links to the
detailed help page (`?function_name`) and notes which functions it
typically calls or is called by.

### Stage 1 — Discovery

| Function | Purpose | Leads to |
|----|----|----|
| [`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md) | List all continuous NHANES cycles with metadata (years, weight variable names, LMF availability) | [`nhanes_manifest()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md), [`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md) |
| [`nhanes_manifest()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md) | List all data files available for a cycle and component; shows file codes, descriptions, and CDC URLs | [`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md) |

``` r
# All cycles with metadata
nhanes_cycles()

# Extract cycle labels for use downstream
cycles <- nhanes_cycles()[["cycle"]]

# See what Laboratory files exist for a cycle
nhanes_manifest("2015-2016", "Laboratory")
```

------------------------------------------------------------------------

### Stage 2 — Variable search

| Function | Purpose | Leads to |
|----|----|----|
| [`nhanes_search_variables()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md) | Search the CDC variable catalog by keyword; returns one row per unique variable name (default) or one row per cycle | [`nhanes_variable_map()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md) |
| [`nhanes_variable_map()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md) | Wraps [`nhanes_search_variables()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md) to produce a per-cycle lookup (`cycle`, `variable_name`, `file_name`) ready for download | [`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md) |

``` r
# Summarized view — which variable codes match, and in how many cycles?
nhanes_search_variables("total cholesterol", component = "Laboratory")

# Per-cycle lookup — which file holds the analyte in each cycle?
nhanes_variable_map("total cholesterol")

# Use keep_vars to exclude false positives (e.g. urine vs. serum creatinine)
nhanes_variable_map("creatinine",
                    keep_vars = c("LBXSCR", "LBDSCR", "LB2SCR"))
```

------------------------------------------------------------------------

### Stage 3 — Download

| Function | Purpose | Leads to |
|----|----|----|
| [`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md) | Download one or more files by exact CDC base code (e.g. `"DEMO"`, `"BPX"`). Use when file names are stable across cycles. | [`nhanes_harmonize()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_harmonize.md), [`nhanes_stack()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_stack.md), [`nhanes_merge()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_merge.md) |
| [`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md) | Download by analyte keyword; uses the variable catalog to resolve the correct CDC filename per cycle automatically. Use when file names changed across cycles. | [`nhanes_harmonize()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_harmonize.md) |

``` r
cycles <- nhanes_cycles()[1:10, "cycle"]   # 1999-2018

# Demographics — always "DEMO"; nhanes_download() works fine
demo_list <- nhanes_download("DEMO", cycles)

# Total cholesterol — file name changed in 1999-2004; use download_analyte()
tchol_list <- nhanes_download_analyte("total cholesterol", cycles)

# Questionnaire variable with keep_vars to filter false positives
mi_list <- nhanes_download_analyte(
  "heart attack", cycles,
  component = "Questionnaire",
  keep_vars = c("MCQ160E", "MCQ160e")
)
```

**Invalid file codes:** if an unrecognised code is passed to
[`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md),
CDC returns HTTP 200 with an HTML error page rather than a 404. nhanesR
detects this via the `Content-Type` header and aborts with a message
directing you to
[`nhanes_manifest()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md)
to confirm the correct name.

------------------------------------------------------------------------

### Stage 4 — Harmonize and stack

| Function | Purpose | Leads to |
|----|----|----|
| [`nhanes_harmonize()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_harmonize.md) | Rename per-cycle variable codes to a single common name and row-bind into one data frame. Supports unit-based matching (e.g. `"mg/dL"`) or an explicit name mapping. | [`nhanes_merge()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_merge.md), [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md) |
| [`nhanes_stack()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_stack.md) | Row-bind a named list of per-cycle data frames, filling absent columns with `NA`. Called internally by [`nhanes_harmonize()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_harmonize.md). | [`nhanes_merge()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_merge.md), [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md) |
| [`nhanes_merge()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_merge.md) | Join two or more NHANES components by `SEQN` (and optionally `cycle`), with weight-variable guidance. | [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md) |

``` r
# Unit-based: finds the mg/dL column by its label attribute
TC <- nhanes_harmonize(tchol_list,
                        unit          = "mg/dL",
                        name          = "TC_mgdl",
                        label_pattern = "total cholesterol")

# Mapping-based: explicit old-name → new-name translation
MI <- nhanes_harmonize(mi_list,
                        mapping = c(MCQ160E = "MI_history",
                                    MCQ160e = "MI_history"))

# Stack demographics (no renaming needed)
demo <- nhanes_stack(demo_list)

# Merge components
analytic <- nhanes_merge(demo, TC, MI, by = c("SEQN", "cycle"))
```

------------------------------------------------------------------------

### Stage 5 — Mortality linkage

| Function | Purpose | Leads to |
|----|----|----|
| [`nhanes_lmf_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_lmf_cycles.md) | Character vector of cycles that have a public-use LMF | [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md) |
| [`nhanes_mortality_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_download.md) | Download raw `.dat` LMF files from CDC FTP (called automatically by other mortality functions) | [`nhanes_mortality_parse()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_parse.md) |
| [`nhanes_mortality_parse()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_parse.md) | Parse `.dat` files into a named list of data frames | [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md) |
| [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md) | Left-join LMF columns onto an analytic dataset by SEQN; handles multiple cycles automatically | [`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md) |

``` r
# Cycles with a public-use LMF (NHANES 1999-2018 + NHANES III)
nhanes_lmf_cycles()

# Append mortality variables — download happens automatically
analytic_mort <- nhanes_mortality_link(analytic)
```

------------------------------------------------------------------------

### Stage 6 — Survival analysis preparation

| Function | Purpose | Leads to |
|----|----|----|
| [`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md) | Remove ineligible participants (`ELIGSTAT != 1`), create `time` and `event` columns, optionally create `event_cause` for cause-specific mortality | Downstream `survival`/`survey` modelling |
| [`nhanes_followup_summary()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_followup_summary.md) | Report median follow-up, event rate, and maximum follow-up by cycle — useful for assessing asymmetric censoring | (diagnostic) |
| [`nhanes_ucod_labels()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_ucod_labels.md) | Lookup table of ICD-10 recode codes and labels accepted by the `cause` argument of [`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md) | [`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md) |

``` r
# All-cause mortality, time from exam visit
surv_data <- nhanes_survival_prep(analytic_mort,
                                   origin     = "exam",
                                   time_unit  = "years",
                                   weight_var = "WTMEC2YR")

# Check follow-up by cycle (note shrinking window near 2017-2018)
nhanes_followup_summary(surv_data)

# Cause-specific: what cause codes are available?
nhanes_ucod_labels()

# Cardiovascular mortality (code "001")
surv_cvd <- nhanes_survival_prep(analytic_mort,
                                  origin = "exam",
                                  cause  = "001",
                                  weight_var = "WTMEC2YR")
```

------------------------------------------------------------------------

### Cache management

| Function | Purpose |
|----|----|
| [`nhanes_cache_dir()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cache_dir.md) | View or change the local cache directory; see the **Setup** section above for the options that govern caching behaviour |

------------------------------------------------------------------------

## Typical workflow

    nhanes_cycles()                    # 1. find available cycles
      └─ nhanes_manifest()             # 2. browse files in a cycle
      └─ nhanes_search_variables()     # 2. search variable catalog
           └─ nhanes_variable_map()    # 3. per-cycle file/variable lookup
                └─ nhanes_download_analyte()   # 4. download (resolves renames)
      └─ nhanes_download()             # 4. download stable-name files (e.g. DEMO)
           └─ nhanes_harmonize()       # 5. rename + stack
           └─ nhanes_stack()           # 5. stack without renaming
                └─ nhanes_merge()      # 6. join components by SEQN
                     └─ nhanes_mortality_link()    # 7. append LMF
                          └─ nhanes_survival_prep()  # 8. create time/event
                               └─ nhanes_followup_summary()  # 9. QC

------------------------------------------------------------------------

## Further reading

- [`vignette("nhanes-mortality-workflow", package = "nhanesR")`](https://dwinsemius.github.io/nhanesR/articles/nhanes-mortality-workflow.md)
  — complete worked example: serum total cholesterol, HDL, prior MI, and
  cholesterol medication across ten cycles (1999–2018), ending with a
  survey-weighted Cox proportional hazards model.

- NHANES analytic guidelines:
  <https://wwwn.cdc.gov/nchs/nhanes/analyticguidelines.aspx>

- CDC mortality linkage documentation:
  <https://www.cdc.gov/nchs/data-linkage/mortality-public.htm>
