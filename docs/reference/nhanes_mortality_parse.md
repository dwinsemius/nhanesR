# Parse NHANES Linked Mortality Files into data frames

Reads the fixed-width `.dat` files (downloading them first if needed)
and returns a named list of data frames, one per cycle.

## Usage

``` r
nhanes_mortality_parse(cycles = NULL, refresh = FALSE, download = TRUE)
```

## Arguments

- cycles:

  Character vector of cycle labels. Defaults to all available.

- refresh:

  Logical. Re-parse even if a cached RDS exists? Default `FALSE`.

- download:

  Logical. Auto-download missing `.dat` files? Default `TRUE`.

## Value

A named list of data frames. Each data frame contains:

- SEQN:

  Respondent sequence number (join key to NHANES data).

- ELIGSTAT:

  Eligibility: 1=eligible; 2=under 18; 3=insufficient data.

- MORTSTAT:

  Vital status: 0=assumed alive; 1=assumed deceased.

- UCOD_LEADING:

  Underlying cause of death (11-category ICD-10 recode).

- DIABETES:

  Diabetes mentioned on death certificate (1=yes).

- HYPERTEN:

  Hypertension mentioned on death certificate (1=yes).

- PERMTH_INT:

  Months of follow-up from interview date.

- PERMTH_EXM:

  Months of follow-up from examination date.

## Details

Variable labels are attached as the `"label"` attribute on each column,
following the `haven`/`labelled` convention.

## Note

For select records, `PERMTH_INT`, `PERMTH_EXM`, and `UCOD_LEADING`
contain **synthetic (perturbed) values** introduced by CDC to reduce
re-identification risk. `MORTSTAT` and `ELIGSTAT` are not perturbed.

## See also

[`nhanes_mortality_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_download.md)
to download the raw `.dat` files;
[`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md)
to join parsed mortality data onto an analytic dataset.

## Examples

``` r
# \donttest{
lmf <- nhanes_mortality_parse(c("2015-2016", "2017-2018"))
lmf[["2015-2016"]]
#> # A tibble: 9,971 × 11
#>     SEQN ELIGSTAT MORTSTAT UCOD_LEADING DIABETES HYPERTEN PERMTH_INT PERMTH_EXM
#>    <int>    <int>    <int> <chr>           <int>    <int>      <dbl>      <dbl>
#>  1 83732        1        0 NA                 NA       NA         43         42
#>  2 83733        1        0 NA                 NA       NA         41         41
#>  3 83734        1        0 NA                 NA       NA         49         48
#>  4 83735        1        0 NA                 NA       NA         49         48
#>  5 83736        1        0 NA                 NA       NA         56         56
#>  6 83737        1        0 NA                 NA       NA         49         47
#>  7 83738        2       NA NA                 NA       NA         NA         NA
#>  8 83739        2       NA NA                 NA       NA         NA         NA
#>  9 83740        2       NA NA                 NA       NA         NA         NA
#> 10 83741        1        0 NA                 NA       NA         49         48
#> # ℹ 9,961 more rows
#> # ℹ 3 more variables: WAGEGRP <int>, EDUCAT <int>, cycle <chr>
# }
```
