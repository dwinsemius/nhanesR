# Attach CDC variable descriptions as Hmisc-style labels

Looks up the plain-language CDC description for each column in a NHANES
data frame and stores it as an `"label"` attribute on the column. Hmisc
reads these attributes automatically in
[`describe`](https://rdrr.io/pkg/Hmisc/man/describe.html),
`Hmisc::summary()`,
[`Hmisc::html()`](https://rdrr.io/pkg/Hmisc/man/html.html), and other
label-aware functions, so labelling once makes descriptions available
everywhere.

## Usage

``` r
NH_label(x, descriptions = NULL)
```

## Arguments

- x:

  A data frame of NHANES data, typically from
  [`nhanes_download_analyte`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md).

- descriptions:

  Optional lookup for variable descriptions. May be:

  - `NULL` (default): descriptions are loaded from the locally cached
    variable catalog. Run any
    [`nhanes_search_variables`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md)
    call first to populate the cache.

  - A `data.frame` with columns `variable_name` and `variable_desc`,
    such as the output of
    [`nhanes_search_variables`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md).

  - A named character vector mapping variable names to descriptions.

## Value

`x` with `"label"` attributes set on each column that could be matched
to a CDC description. Columns with no catalog match are returned
unchanged.

## See also

[`NH_describe`](https://dwinsemius.github.io/nhanesR/reference/NH_describe.md)
for a one-step labelled describe;
[`nhanes_search_variables`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md)
to browse the variable catalog;
[`label`](https://rdrr.io/pkg/Hmisc/man/label.html) for the Hmisc label
convention.

## Examples

``` r
# \donttest{
tc <- nhanes_download_analyte("total cholesterol", "2015-2016")
#> Found 6 unique variables matching "total cholesterol".
#> Warning: Both "2017-2018" and "2017-2020" are present. The 2017-2018 participants are
#> included in the 2017-2020 pandemic-adjusted file -- use one or the other in
#> pooled analyses to avoid double-counting.
#> Loading cached TCHOL_I for 2015-2016
tc <- NH_label(tc)

# CDC descriptions now appear in all Hmisc label-aware output
Hmisc::describe(tc)
#> tc 
#> 
#>  4  Variables      8021  Observations
#> --------------------------------------------------------------------------------
#> SEQN : Respondent sequence number 
#>        n  missing distinct 
#>     8021        0     8021 
#> 
#> lowest : 83732 83733 83734 83735 83736, highest: 93697 93699 93700 93701 93702
#> --------------------------------------------------------------------------------
#> LBXTC : Total Cholesterol (mg/dL) 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     7256      765      257        1    180.3      178    45.47      122 
#>      .10      .25      .50      .75      .90      .95 
#>      132      150      176      204      234      254 
#> 
#> lowest :  77  80  81  84  85, highest: 393 415 433 540 545
#> --------------------------------------------------------------------------------
#> LBDTCSI : Total Cholesterol( mmol/L) 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     7256      765      257        1    4.661      4.6    1.176     3.15 
#>      .10      .25      .50      .75      .90      .95 
#>     3.41     3.88     4.55     5.28     6.05     6.57 
#> 
#> lowest : 1.99  2.07  2.09  2.17  2.2  , highest: 10.16 10.73 11.2  13.96 14.09
#> --------------------------------------------------------------------------------
#> cycle 
#>         n   missing  distinct     value 
#>      8021         0         1 2015-2016 
#>                     
#> Value      2015-2016
#> Frequency       8021
#> Proportion         1
#> --------------------------------------------------------------------------------
Hmisc::html(Hmisc::describe(tc))
# }
```
