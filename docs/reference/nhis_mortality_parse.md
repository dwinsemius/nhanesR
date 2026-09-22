# Parse NHIS Linked Mortality Files into data frames

Reads the fixed-width `.dat` files (downloading them first if needed)
and returns a named list of data frames, one per survey year.

## Usage

``` r
nhis_mortality_parse(years = NULL, refresh = FALSE, download = TRUE)
```

## Arguments

- years:

  Character or numeric vector of NHIS survey years. Defaults to all
  available. See
  [`nhis_lmf_years()`](https://dwinsemius.github.io/nhanesR/reference/nhis_lmf_years.md).

- refresh:

  Logical. Re-parse even if a cached RDS exists? Default `FALSE`.

- download:

  Logical. Auto-download missing `.dat` files? Default `TRUE`.

## Value

A named list of data frames. Each data frame contains:

- PUBLICID:

  NHIS public-use identifier (join key – character, not numeric; NHIS
  does not use NHANES's `SEQN`).

- ELIGSTAT:

  Eligibility: 1=eligible; 2=under 18; 3=insufficient data.

- MORTSTAT:

  Vital status: 0=assumed alive; 1=assumed deceased.

- UCOD_LEADING:

  Underlying cause of death (ICD-10 recode).

- DIABETES:

  Diabetes mentioned on death certificate (1=yes).

- HYPERTEN:

  Hypertension mentioned on death certificate (1=yes).

- DODQTR:

  Quarter of death (1-4).

- DODYEAR:

  Year of death.

- WGT_NEW:

  Person-level sample weight, adjusted for linkage ineligibility. Blank
  for 1986 (NCHS recommends `WTFA` from the NHIS public-use file that
  year instead).

- SA_WGT_NEW:

  Sample Adult sample weight, adjusted for linkage ineligibility. Only
  populated 1997 onward (the Sample Adult File did not exist before the
  1997 NHIS redesign).

## Details

Variable labels are attached as the `"label"` attribute on each column,
following the `haven`/`labelled` convention – same as
[`nhanes_mortality_parse()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_parse.md).

## Note

Unlike the NHANES LMF, **NHIS's public-use LMF has no
`PERMTH_INT`/`PERMTH_EXM`-equivalent person-months variable.**
Constructing follow-up time requires combining `DODQTR`/`DODYEAR` with
the participant's own NHIS interview year/quarter, which comes from the
NHIS survey data itself, not this file. There is no
`nhis_survival_prep()` analogous to
[`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md)
for this reason – see
[`nhis_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhis_mortality_link.md)'s
documentation for how far this package takes NHIS mortality linkage.

## See also

[`nhis_mortality_download()`](https://dwinsemius.github.io/nhanesR/reference/nhis_mortality_download.md)
to download the raw `.dat` files;
[`nhis_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhis_mortality_link.md)
to join parsed mortality data onto NHIS data.

## Examples

``` r
# \donttest{
lmf <- nhis_mortality_parse(c("2015", "2016"))
lmf[["2015"]]
#> # A tibble: 45,963 × 11
#>    PUBLICID      ELIGSTAT MORTSTAT UCOD_LEADING DIABETES HYPERTEN DODQTR DODYEAR
#>    <chr>            <int>    <int> <chr>           <int>    <int>  <int>   <int>
#>  1 201500000401…        1        0 NA                 NA       NA     NA      NA
#>  2 201500000501…        2       NA NA                 NA       NA     NA      NA
#>  3 201500001101…        1        0 NA                 NA       NA     NA      NA
#>  4 201500001601…        1        0 NA                 NA       NA     NA      NA
#>  5 201500001901…        1        0 NA                 NA       NA     NA      NA
#>  6 201500002101…        1        0 NA                 NA       NA     NA      NA
#>  7 201500002301…        1        0 NA                 NA       NA     NA      NA
#>  8 201500002401…        1        0 NA                 NA       NA     NA      NA
#>  9 201500002801…        1        0 NA                 NA       NA     NA      NA
#> 10 201500002801…        2       NA NA                 NA       NA     NA      NA
#> # ℹ 45,953 more rows
#> # ℹ 3 more variables: WGT_NEW <dbl>, SA_WGT_NEW <dbl>, .nhis_lmf_year <chr>
# }
```
