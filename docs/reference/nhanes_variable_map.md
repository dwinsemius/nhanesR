# Build a per-cycle variable map for an analyte

Wraps
[`nhanes_search_variables()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md)
to return a single-row-per-cycle lookup table showing which variable
name and file to use for a given analyte across NHANES cycles. Useful
for analytes whose variable names changed between cycles (e.g. HDL
cholesterol: `LBDHDL` → `LBXHDD` → `LBDHDD`).

## Usage

``` r
nhanes_variable_map(
  term,
  component = "Laboratory",
  keep_vars = NULL,
  refresh = FALSE
)
```

## Arguments

- term:

  Character. Search term passed to
  [`nhanes_search_variables()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md).

- component:

  Character or `NULL`. NHANES component to search. Default
  `"Laboratory"`.

- keep_vars:

  Character vector or `NULL`. If provided, only variables whose names
  appear in this vector are retained before the per-cycle deduplication
  step. Useful for disambiguating serum vs. urine forms of the same
  analyte (e.g. serum vs. urinary creatinine).

- refresh:

  Logical. Re-fetch the variable catalog? Default `FALSE`.

## Value

A data frame with columns `cycle`, `variable_name`, and `file_name`, one
row per cycle in which the analyte was measured. Returns zero rows if
nothing matches.

## Details

When multiple variables match within a cycle (e.g. mg/dL and mmol/L
versions), the function prefers the non-SI variable. Comment-code
variables (suffix `LC`/`LCN` or "comment" in description) are always
dropped.

## See also

[`nhanes_search_variables()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md)
for the underlying keyword search;
[`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md)
which uses this map to resolve filenames automatically.

## Examples

``` r
if (FALSE) { # \dontrun{
# HDL cholesterol across all cycles
nhanes_variable_map("HDL")

# Serum creatinine only (exclude urine variables)
nhanes_variable_map("creatinine", keep_vars = c("LBXSCR", "LBDSCR", "LB2SCR"))

# Urinary albumin only
nhanes_variable_map("albumin", keep_vars = c("URXUMA", "UR2UMA", "UR1MA"))
} # }
```
