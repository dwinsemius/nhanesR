# Build a per-cycle variable map for an analyte

Wraps
[`nhanes_search_variables()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md)
to return a single-row-per-cycle lookup table showing which variable
name and file to use for a given analyte across NHANES cycles. Useful
for analytes whose variable names changed between cycles (e.g. HDL
cholesterol: `LBDHDL` -\> `LBXHDD` -\> `LBDHDD`).

## Usage

``` r
nhanes_variable_map(
  term,
  component = "Laboratory",
  keep_vars = NULL,
  include_reliability = FALSE,
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

- include_reliability:

  Logical. Include NHANES reliability substudy files, in which a random
  subset of participants had a second blood draw to measure
  within-subject variability? Default `FALSE`. Reliability files are
  identified by the `LB2` variable prefix and `_2_` file name pattern
  (e.g. `l13_2_b`, `l13_2_r`). These files should not be pooled with the
  main analytic dataset as they would duplicate participants.

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
# \donttest{
# HDL cholesterol across all cycles
nhanes_variable_map("HDL")
#> Found 11 unique variables matching "HDL".
#> Warning: Both "2017-2018" and "2017-2020" are present. The 2017-2018 participants are
#> included in the 2017-2020 pandemic-adjusted file -- use one or the other in
#> pooled analyses to avoid double-counting.
#> # A tibble: 11 × 3
#>    cycle     variable_name file_name
#>    <chr>     <chr>         <chr>    
#>  1 1999-2000 LBDHDL        Lab13    
#>  2 2001-2002 LBDHDL        l13_b    
#>  3 2003-2004 LBXHDD        l13_c    
#>  4 2005-2006 LBDHDD        HDL_D    
#>  5 2007-2008 LBDHDD        HDL_E    
#>  6 2009-2010 LBDHDD        HDL_F    
#>  7 2011-2012 LBDHDD        HDL_G    
#>  8 2013-2014 LBDHDD        HDL_H    
#>  9 2015-2016 LBDHDD        HDL_I    
#> 10 2017-2018 LBDHDD        HDL_J    
#> 11 2017-2020 LBDHDD        P_HDL    

# Serum creatinine only (exclude urine variables)
nhanes_variable_map("creatinine",
                    keep_vars = c("LBXSCR", "LBDSCR", "LB2SCR"))
#> Found 20 unique variables matching "creatinine".
#> Warning: Both "2017-2018" and "2017-2020" are present. The 2017-2018 participants are
#> included in the 2017-2020 pandemic-adjusted file -- use one or the other in
#> pooled analyses to avoid double-counting.
#> # A tibble: 11 × 3
#>    cycle     variable_name file_name
#>    <chr>     <chr>         <chr>    
#>  1 1999-2000 LBXSCR        LAB18    
#>  2 2001-2002 LBDSCR        L40_B    
#>  3 2003-2004 LBXSCR        L40_C    
#>  4 2005-2006 LBXSCR        BIOPRO_D 
#>  5 2007-2008 LBXSCR        BIOPRO_E 
#>  6 2009-2010 LBXSCR        BIOPRO_F 
#>  7 2011-2012 LBXSCR        BIOPRO_G 
#>  8 2013-2014 LBXSCR        BIOPRO_H 
#>  9 2015-2016 LBXSCR        BIOPRO_I 
#> 10 2017-2018 LBXSCR        BIOPRO_J 
#> 11 2017-2020 LBXSCR        P_BIOPRO 

# Urinary albumin only
nhanes_variable_map("albumin", keep_vars = c("URXUMA", "UR2UMA", "UR1MA"))
#> Found 26 unique variables matching "albumin".
#> Warning: Both "2017-2018" and "2017-2020" are present. The 2017-2018 participants are
#> included in the 2017-2020 pandemic-adjusted file -- use one or the other in
#> pooled analyses to avoid double-counting.
#> # A tibble: 11 × 3
#>    cycle     variable_name file_name
#>    <chr>     <chr>         <chr>    
#>  1 1999-2000 URXUMA        LAB16    
#>  2 2001-2002 URXUMA        L16_B    
#>  3 2003-2004 URXUMA        L16_C    
#>  4 2005-2006 URXUMA        ALB_CR_D 
#>  5 2007-2008 URXUMA        ALB_CR_E 
#>  6 2009-2010 URXUMA        ALB_CR_F 
#>  7 2011-2012 URXUMA        ALB_CR_G 
#>  8 2013-2014 URXUMA        ALB_CR_H 
#>  9 2015-2016 URXUMA        ALB_CR_I 
#> 10 2017-2018 URXUMA        ALB_CR_J 
#> 11 2017-2020 URXUMA        P_ALB_CR 
# }
```
