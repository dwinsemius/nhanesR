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
# \donttest{
# Find total cholesterol across all cycles (summarized)
nhanes_search_variables("total cholesterol")
#> Found 6 unique variables matching "total cholesterol".
#>   variable_name                                  variable_desc
#> 1       LBDTCSI                     Total cholesterol (mmol/L)
#> 2         LBXTC                      Total cholesterol (mg/dL)
#> 3      LBDSCHSI Total Cholesterol, refrigerated serum (mmol/L)
#> 4        LBXSCH  Total Cholesterol, refrigerated serum (mg/dL)
#> 5         LB2TC                      Total cholesterol (mg/dL)
#> 6       LB2TCSI                     Total cholesterol (mmol/L)
#>                                                                                             file_names
#> 1 Lab13, l13_b, l13_c, TCHOL_D, TCHOL_E, TCHOL_F, TCHOL_G, TCHOL_H, TCHOL_I, TCHOL_J, P_TCHOL, TCHOL_L
#> 2 Lab13, l13_b, l13_c, TCHOL_D, TCHOL_E, TCHOL_F, TCHOL_G, TCHOL_H, TCHOL_I, TCHOL_J, P_TCHOL, TCHOL_L
#> 3                                                                         BIOPRO_J, P_BIOPRO, BIOPRO_L
#> 4                                                                         BIOPRO_J, P_BIOPRO, BIOPRO_L
#> 5                                                                                     l13_2_r, l13_2_b
#> 6                                                                                     l13_2_r, l13_2_b
#>                                                                                                                               cycles
#> 1 1999-2000, 2001-2002, 2003-2004, 2005-2006, 2007-2008, 2009-2010, 2011-2012, 2013-2014, 2015-2016, 2017-2018, 2017-2020, 2021-2023
#> 2 1999-2000, 2001-2002, 2003-2004, 2005-2006, 2007-2008, 2009-2010, 2011-2012, 2013-2014, 2015-2016, 2017-2018, 2017-2020, 2021-2023
#> 3                                                                                                    2017-2018, 2017-2020, 2021-2023
#> 4                                                                                                    2017-2018, 2017-2020, 2021-2023
#> 5                                                                                                               2000-2000, 2001-2002
#> 6                                                                                                               2000-2000, 2001-2002
#>   n_cycles
#> 1       12
#> 2       12
#> 3        3
#> 4        3
#> 5        2
#> 6        2

# Raw one-row-per-cycle output
nhanes_search_variables("total cholesterol", summarize = FALSE)
#> Found 6 unique variables matching "total cholesterol".
#> # A tibble: 34 × 6
#>    variable_name variable_desc              file_name file_desc  cycle component
#>    <chr>         <chr>                      <chr>     <chr>      <chr> <chr>    
#>  1 LBDTCSI       Total Cholesterol( mmol/L) TCHOL_E   Cholester… 2007… Laborato…
#>  2 LBXTC         Total Cholesterol (mg/dL)  TCHOL_E   Cholester… 2007… Laborato…
#>  3 LBDTCSI       Total cholesterol (mmol/L) Lab13     Cholester… 1999… Laborato…
#>  4 LBXTC         Total cholesterol (mg/dL)  Lab13     Cholester… 1999… Laborato…
#>  5 LBDTCSI       Total cholesterol (mmol/L) l13_b     Cholester… 2001… Laborato…
#>  6 LBXTC         Total cholesterol (mg/dL)  l13_b     Cholester… 2001… Laborato…
#>  7 LBDTCSI       Total Cholesterol (mmol/L) l13_c     Cholester… 2003… Laborato…
#>  8 LBXTC         Total Cholesterol (mg/dL)  l13_c     Cholester… 2003… Laborato…
#>  9 LBDTCSI       Total Cholesterol( mmol/L) TCHOL_D   Cholester… 2005… Laborato…
#> 10 LBXTC         Total cholesterol (mg/dL)  TCHOL_D   Cholester… 2005… Laborato…
#> # ℹ 24 more rows

# Restrict to laboratory component
nhanes_search_variables("alanine", component = "Laboratory")
#> Found 3 unique variables matching "alanine".
#>   variable_name                               variable_desc
#> 1      LBXSATSI               Alanine aminotransferase(U/L)
#> 2      LB2SATSI              Alanine aminotransferase (U/L)
#> 3      LBDSATLC Alanine Aminotransferase (ALT) Comment Code
#>                                                                                        file_names
#> 1 L40_C, BIOPRO_D, BIOPRO_E, BIOPRO_F, BIOPRO_G, BIOPRO_H, BIOPRO_I, BIOPRO_J, P_BIOPRO, BIOPRO_L
#> 2                                                                               l18_2_00, L40_2_B
#> 3                                                                              BIOPRO_J, P_BIOPRO
#>                                                                                                         cycles
#> 1 2003-2004, 2005-2006, 2007-2008, 2009-2010, 2011-2012, 2013-2014, 2015-2016, 2017-2018, 2017-2020, 2021-2023
#> 2                                                                                         2000-2000, 2001-2002
#> 3                                                                                         2017-2018, 2017-2020
#>   n_cycles
#> 1       10
#> 2        2
#> 3        2

# Search for HDL cholesterol
nhanes_search_variables("HDL")
#> Found 11 unique variables matching "HDL".
#>    variable_name
#> 1       LBDHDDSI
#> 2         LBDHDD
#> 3       URDDHDLC
#> 4         LBDLDL
#> 5        LBDLDLM
#> 6        LBDLDLN
#> 7         LB2HDL
#> 8       LB2HDLSI
#> 9         LBDHDL
#> 10      LBDHDLSI
#> 11        LBXHDD
#>                                                                                                                                                                                                                                                                                   variable_desc
#> 1                                                                                                                                                                                                                                                               Direct HDL-Cholesterol (mmol/L)
#> 2                                                                                                                                                                                                                                                                Direct HDL-Cholesterol (mg/dL)
#> 3                                                                                                                                                                                                                                                                              DHD comment code
#> 4                                                         LDL-Cholesterol, Friedewald equation (mg/dL).\n\nLBDLDL = (LBXTC-(LBDHDD + LBXTR/5), round to 0 decimal places) for LBXTR less than 400 mg/dL, and missing for LBXTR greater than 400 mg/dL.\n\nLBDHDD from public release file HDL_J
#> 5                                    LDL-Cholesterol, Martin-Hopkins equation (mg/dL).\n\nLBDLDLM = (LBXTC-(LBDHDD + LBXTR/Adjustable Factor), round to 0 decimal places) for LBXTR less than 400 mg/dL, and missing for LBXTR greater than 400 mg/dL.\n\nLBDHDD from public release file HDL_J
#> 6  LBDLDLN = \n (LBXTC/0.948  – LBDHDD/0.971 – (LBXTR/8.56 + (LBXTR * (LBXTC – LBDHDD))/2140 – LBXTR^2/16100) – 9.44), round 0 decimal places) for LBXTR less than 800 mg/dL, and missing for LBXTR GE 800 mg/dL.\n\n^2 stands for power=2, or squared. \nLBDHDD from public release file HDL_J
#> 7                                                                                                                                                                                                                                                                       HDL-cholesterol (mg/dL)
#> 8                                                                                                                                                                                                                                                                      HDL-cholesterol (mmol/L)
#> 9                                                                                                                                                                                                                                                                       HDL-cholesterol (mg/dL)
#> 10                                                                                                                                                                                                                                                                     HDL-cholesterol (mmol/L)
#> 11                                                                                                                                                                                                                                                               Direct HDL-Cholesterol (mg/dL)
#>                                                              file_names
#> 1  l13_c, HDL_D, HDL_E, HDL_F, HDL_G, HDL_H, HDL_I, HDL_J, P_HDL, HDL_L
#> 2         HDL_D, HDL_E, HDL_F, HDL_G, HDL_H, HDL_I, HDL_J, P_HDL, HDL_L
#> 3                                        DEET_E, DEET_F, DEET_G, DEET_H
#> 4                                          TRIGLY_J, P_TRIGLY, TRIGLY_L
#> 5                                          TRIGLY_J, P_TRIGLY, TRIGLY_L
#> 6                                          TRIGLY_J, P_TRIGLY, TRIGLY_L
#> 7                                                      l13_2_r, l13_2_b
#> 8                                                      l13_2_r, l13_2_b
#> 9                                                          Lab13, l13_b
#> 10                                                         Lab13, l13_b
#> 11                                                                l13_c
#>                                                                                                          cycles
#> 1  2003-2004, 2005-2006, 2007-2008, 2009-2010, 2011-2012, 2013-2014, 2015-2016, 2017-2018, 2017-2020, 2021-2023
#> 2             2005-2006, 2007-2008, 2009-2010, 2011-2012, 2013-2014, 2015-2016, 2017-2018, 2017-2020, 2021-2023
#> 3                                                                    2007-2008, 2009-2010, 2011-2012, 2013-2014
#> 4                                                                               2017-2018, 2017-2020, 2021-2023
#> 5                                                                               2017-2018, 2017-2020, 2021-2023
#> 6                                                                               2017-2018, 2017-2020, 2021-2023
#> 7                                                                                          2000-2000, 2001-2002
#> 8                                                                                          2000-2000, 2001-2002
#> 9                                                                                          1999-2000, 2001-2002
#> 10                                                                                         1999-2000, 2001-2002
#> 11                                                                                                    2003-2004
#>    n_cycles
#> 1        10
#> 2         9
#> 3         4
#> 4         3
#> 5         3
#> 6         3
#> 7         2
#> 8         2
#> 9         2
#> 10        2
#> 11        1
# }
```
