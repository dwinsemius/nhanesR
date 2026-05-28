# Search NHANES variables by keyword

Searches the CDC NHANES variable catalog for variables whose name or
description matches a keyword or phrase. Results are drawn from the CDC
variable list pages and cached locally to avoid repeated HTTP requests.

## Usage

``` r
nhanes_search_variables(
  term,
  component = NULL,
  refresh = FALSE,
  summarize = TRUE
)
```

## Arguments

- term:

  Character. A keyword or phrase to search for. Matched
  case-insensitively against variable names and descriptions.

- component:

  Character or `NULL`. Restrict search to one NHANES component:
  `"Demographics"`, `"Dietary"`, `"Examination"`, `"Laboratory"`, or
  `"Questionnaire"`. If `NULL` (default), searches all components.

- refresh:

  Logical. Re-fetch the variable catalog from CDC even if cached?
  Default `FALSE`.

- summarize:

  Logical. If `TRUE` (default), collapse results to one row per unique
  variable name, with cycles and file names shown as comma-separated
  lists. Set to `FALSE` to return one row per variable-per-cycle.

## Value

When `summarize = TRUE` (default), a data frame with columns:

- variable_name:

  CDC variable code (e.g. `LBXTC`).

- variable_desc:

  Plain-language description.

- file_names:

  Comma-separated file codes across cycles.

- cycles:

  Comma-separated cycle labels.

- n_cycles:

  Number of cycles in which this variable appears.

When `summarize = FALSE`, one row per variable per cycle with an
additional `file_name` and `component` column.

## Details

This is the recommended way to find the correct file code and variable
name for an analyte across NHANES cycles. For example, total cholesterol
was stored in `LAB13` (1999-2000), `L13_B` (2001-2002), `L13_C`
(2003-2004), and `TCHOL` (2005 onwards), always in variable `LBXTC`.

## See also

[`nhanes_variable_map()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md)
for a per-cycle file/variable lookup table ready for use with
[`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md);
[`nhanes_manifest()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md)
to browse files rather than variables.

## Examples

``` r
if (FALSE) { # \dontrun{
# Find total cholesterol across all cycles (summarized)
nhanes_search_variables("total cholesterol")

# Raw one-row-per-cycle output
nhanes_search_variables("total cholesterol", summarize = FALSE)

# Restrict to laboratory component
nhanes_search_variables("alanine", component = "Laboratory")

# Search for HDL cholesterol
nhanes_search_variables("HDL")
} # }
```
