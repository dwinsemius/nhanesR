# Harmonize variable names across NHANES cycles and stack into one data frame

NHANES analytes are sometimes stored under different variable names in
different cycles (e.g. HDL cholesterol: `LBDHDL` in 1999-2002, `LBXHDD`
in 2003-2004, `LBDHDD` from 2005 onward). `nhanes_harmonize()` offers
two ways to resolve this:

## Usage

``` r
nhanes_harmonize(
  data_list,
  mapping = NULL,
  unit = NULL,
  name = NULL,
  label_pattern = NULL,
  prefer_mgdl = TRUE,
  trim = TRUE,
  stack = TRUE
)
```

## Arguments

- data_list:

  A named list of per-cycle data frames, as returned by
  [`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md)
  or
  [`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md).

- mapping:

  A named character vector where **names** are the old (per-cycle)
  variable names and **values** are the single common name to use across
  all cycles. Multiple old names may map to the same new name. Example:
  `c(LBDHDL = "HDL_mgdl", LBXHDD = "HDL_mgdl", LBDHDD = "HDL_mgdl")`.
  Ignored when `unit` is provided.

- unit:

  Character or `NULL`. A unit string to match against column label
  attributes (case-insensitive). Common values: `"mg/dL"`, `"g/dL"`,
  `"U/L"`, `"umol/L"`. When supplied, `name` must also be provided.

- name:

  Character or `NULL`. The output column name to use when `unit` is
  supplied (e.g. `"HDL_mgdl"`).

- label_pattern:

  Character or `NULL`. An additional regex matched against column labels
  when `unit` is used. Use this to disambiguate when a file contains
  multiple columns in the same unit (e.g. `"HDL"` to select only the HDL
  column from a file that also contains total cholesterol in mg/dL).

- prefer_mgdl:

  Logical. If `TRUE` (default), drop SI-unit columns (mmol/L, g/L, etc.)
  when a conventional-unit counterpart (mg/dL, g/dL, U/L) exists in the
  same data frame. Detection uses label attributes: the unit token is
  stripped from each label and SI columns whose base description matches
  a conventional-unit column are removed. Applied before any renaming
  step.

- trim:

  Logical. Only applies when `unit` is used. If `TRUE` (default), the
  returned data frame contains only `SEQN`, `cycle`, and the column
  named by `name`. Set to `FALSE` to retain all columns (useful when the
  source file contains other variables you want to keep).

- stack:

  Logical. If `TRUE` (default), row-bind the renamed data frames into a
  single data frame using
  [`nhanes_stack()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_stack.md).
  Set to `FALSE` to return the renamed list without stacking.

## Value

If `stack = TRUE` (default), a single stacked data frame. When `unit` is
used with `trim = TRUE` (the default), only `SEQN`, `cycle`, and the
harmonized column are returned — ready for merging. If `stack = FALSE`,
a named list of data frames.

## Details

- **Unit-based** (`unit` + `name`): scans column label attributes for
  the specified unit string (e.g. `"mg/dL"`) and renames the matching
  column. No need to know the CDC variable codes in advance. Use
  `label_pattern` to disambiguate when a file contains multiple columns
  in the same unit (e.g. early cycles that bundled total cholesterol and
  HDL together).

- **Explicit mapping** (`mapping`): a named character vector of old -\>
  new variable names. More verbose but unambiguous.

## See also

[`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md)
which produces the per-cycle list consumed by this function;
[`nhanes_stack()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_stack.md)
for row-binding without renaming;
[`nhanes_variable_map()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md)
to inspect variable names per cycle before choosing a mapping.

## Examples

``` r
if (FALSE) { # \dontrun{
cycles <- nhanes_cycles()[1:10, "cycle"]

# Unit-based: trim = TRUE (default) returns SEQN + cycle + HDL_mgdl only
hdl_list <- nhanes_download_analyte("HDL", cycles)
hdl <- nhanes_harmonize(hdl_list, unit = "mg/dL", name = "HDL_mgdl",
                         label_pattern = "HDL")

# Merge two analytes cleanly
tchol_list <- nhanes_download_analyte("total cholesterol", cycles)
TC  <- nhanes_harmonize(tchol_list, unit = "mg/dL", name = "TC_mgdl",
                         label_pattern = "total cholesterol")
lipids <- merge(hdl, TC, by = c("SEQN", "cycle"))

# Explicit mapping (trim does not apply)
hdl <- nhanes_harmonize(
  hdl_list,
  mapping = c(LBDHDL = "HDL_mgdl", LBXHDD = "HDL_mgdl",
              LBDHDD = "HDL_mgdl")
)
} # }
```
