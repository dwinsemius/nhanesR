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
  units = c("conventional", "SI", "both"),
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

- units:

  Character. Controls which unit system to retain when both conventional
  and SI versions of the same measurement exist in a data frame (e.g.
  `LBXTC` in mg/dL and `LBDTCSI` in mmol/L). One of:

  `"conventional"`

  :   (default) Keep mg/dL, g/dL, U/L, etc.; drop SI duplicates.
      Appropriate for US-centric analyses.

  `"SI"`

  :   Keep mmol/L, g/L, umol/L, etc.; drop conventional duplicates.
      Appropriate for international use or journals that require SI
      units.

  `"both"`

  :   Retain all columns; no duplicates are removed.

  Detection uses label attributes rather than variable names because CDC
  naming is inconsistent (e.g. `LBXTC`/`LBDTCSI`). Applied before any
  renaming step.

- trim:

  Logical. If `TRUE` (default), the returned data frame contains only
  `SEQN`, `cycle`, and the harmonized column(s). Set to `FALSE` to
  retain all columns (useful when the source file contains other
  variables you want to keep).

- stack:

  Logical. If `TRUE` (default), row-bind the renamed data frames into a
  single data frame using
  [`nhanes_stack()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_stack.md).
  Set to `FALSE` to return the renamed list without stacking.

## Value

If `stack = TRUE` (default), a single stacked data frame. When `unit` is
used with `trim = TRUE` (the default), only `SEQN`, `cycle`, and the
harmonized column are returned – ready for merging. If `stack = FALSE`,
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
# \donttest{
cycles <- nhanes_cycles()[1:10, "cycle"]

# Conventional units (default): returns SEQN + cycle + HDL_mgdl
hdl_list <- nhanes_download_analyte("HDL", cycles)
#> Found 11 unique variables matching "HDL".
#> Warning: Both "2017-2018" and "2017-2020" are present. The 2017-2018 participants are
#> included in the 2017-2020 pandemic-adjusted file -- use one or the other in
#> pooled analyses to avoid double-counting.
hdl <- nhanes_harmonize(hdl_list, unit = "mg/dL", name = "HDL_mgdl",
                         label_pattern = "HDL")

# SI units: retain mmol/L columns, drop conventional duplicates
hdl_si <- nhanes_harmonize(hdl_list, unit = "mmol/L", name = "HDL_mmol",
                            label_pattern = "HDL", units = "SI")

# Merge two analytes cleanly
tchol_list <- nhanes_download_analyte("total cholesterol", cycles)
#> Found 6 unique variables matching "total cholesterol".
#> Warning: Both "2017-2018" and "2017-2020" are present. The 2017-2018 participants are
#> included in the 2017-2020 pandemic-adjusted file -- use one or the other in
#> pooled analyses to avoid double-counting.
TC  <- nhanes_harmonize(tchol_list, unit = "mg/dL", name = "TC_mgdl",
                         label_pattern = "total cholesterol")
lipids <- merge(hdl, TC, by = c("SEQN", "cycle"))

# Explicit mapping
hdl <- nhanes_harmonize(
  hdl_list,
  mapping = c(LBDHDL = "HDL_mgdl", LBXHDD = "HDL_mgdl",
              LBDHDD = "HDL_mgdl")
)
# }
```
