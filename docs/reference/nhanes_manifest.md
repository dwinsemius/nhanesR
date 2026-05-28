# List available files for a NHANES cycle and component

Queries the CDC NHANES data page for a given cycle and component,
returning a data frame of available files with their download URLs and
documentation links.

## Usage

``` r
nhanes_manifest(cycle, component, refresh = FALSE)
```

## Arguments

- cycle:

  Character. A cycle string, e.g. `"2015-2016"`. See
  [`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md)
  for valid values.

- component:

  Character. One of `"Demographics"`, `"Dietary"`, `"Examination"`,
  `"Laboratory"`, `"Questionnaire"`. Case-insensitive.

- refresh:

  Logical. Force re-query of CDC website even if cached? Default
  `FALSE`.

## Value

A tibble with columns:

- cycle:

  Cycle label.

- component:

  Component name.

- file_name:

  File code (e.g. `"DEMO_I"`).

- description:

  Plain-text description from CDC.

- xpt_url:

  Direct URL to the XPT data file.

- doc_url:

  URL to the HTML documentation/codebook page.

- date_published:

  Date published, if available.

## Details

Results are cached locally for the session to avoid repeated HTTP
requests. Use `refresh = TRUE` to force re-query.

## Examples

``` r
if (FALSE) { # \dontrun{
nhanes_manifest("2015-2016", "Laboratory")
nhanes_manifest("2015-2016", "Demographics")
} # }
```
