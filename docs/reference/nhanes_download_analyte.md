# Download NHANES files for an analyte using the CDC variable catalog

A smarter alternative to
[`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md)
for analytes whose file name changed across cycles (e.g. total
cholesterol: `LAB13` → `L13_B` → `L13_C` → `TCHOL_D` onward). Uses
[`nhanes_variable_map()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md)
to look up the correct CDC file name for each cycle, then downloads
using the exact catalog name.

## Usage

``` r
nhanes_download_analyte(
  term,
  cycles,
  component = "Laboratory",
  keep_vars = NULL,
  refresh = FALSE,
  add_cycle_col = TRUE
)
```

## Arguments

- term:

  Character. Search term passed to
  [`nhanes_variable_map()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md).

- cycles:

  Character. One or more cycle labels (e.g. `"1999-2000"`). See
  [`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md).

- component:

  Character or `NULL`. NHANES component to search. Default
  `"Laboratory"`.

- keep_vars:

  Character vector or `NULL`. Passed to
  [`nhanes_variable_map()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md)
  to disambiguate serum from urine forms of the same analyte.

- refresh:

  Logical. Re-download even if cached? Default `FALSE`.

- add_cycle_col:

  Logical. Add a `cycle` column to each data frame? Default `TRUE`.

## Value

If a single cycle is requested, a data frame. If multiple cycles are
requested, a named list of data frames keyed by cycle label.

## Examples

``` r
if (FALSE) { # \dontrun{
cycles <- nhanes_cycles()[1:10, "cycle"]

# Total cholesterol — file name changed in 1999-2004; this handles it
tchol_list <- nhanes_download_analyte("total cholesterol", cycles)

# Serum creatinine (keep_vars excludes urine creatinine)
scr_list <- nhanes_download_analyte("creatinine", cycles,
                                    keep_vars = c("LBXSCR","LBDSCR","LB2SCR"))
} # }
```
