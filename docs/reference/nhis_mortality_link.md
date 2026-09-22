# Link NHIS mortality data onto an NHIS analytic dataset

Performs a left join of the parsed NHIS LMF onto a data frame containing
NHIS participants, matched on the participant public-use ID **and**
survey year.

## Usage

``` r
nhis_mortality_link(
  nhis_data,
  years = NULL,
  keep_vars = NULL,
  download = TRUE,
  publicid_col = "PUBLICID",
  year_col = "SRVY_YR"
)
```

## Arguments

- nhis_data:

  A data frame containing NHIS participants.

- years:

  Character or numeric vector of NHIS survey years present in
  `nhis_data`. Inferred from `year_col` when omitted.

- keep_vars:

  Character vector of LMF variables to retain. Defaults to all:
  `c("ELIGSTAT", "MORTSTAT", "UCOD_LEADING", "DIABETES", "HYPERTEN", "DODQTR", "DODYEAR", "WGT_NEW", "SA_WGT_NEW")`.

- download:

  Logical. Download missing LMF files automatically? Default `TRUE`.

- publicid_col:

  Character. Name of the participant public-use ID column in
  `nhis_data`. Default `"PUBLICID"` (NCHS standard).

- year_col:

  Character. Name of the survey-year column in `nhis_data`. Default
  `"SRVY_YR"` (the NHIS public-use file convention).

## Value

`nhis_data` with LMF columns appended. Rows with no mortality record
(PUBLICID/year combinations absent from the LMF) will have `NA` for all
LMF columns.

## Details

`nhis_data` must come from somewhere else – nhanesR does not download
NHIS survey data (see the package-level scoping note in this file's
source, or
[`?nhis_mortality_download`](https://dwinsemius.github.io/nhanesR/reference/nhis_mortality_download.md)).
Typical sources are NCHS's own NHIS public-use microdata site or IPUMS
Health Surveys (IPUMS NHIS).

## Why the join requires a year column, unlike [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md)

[`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md)
matches on `SEQN` alone, which is safe because NHANES's `SEQN` numbering
does not overlap across the 2-year cycles this package pools. NHIS's
`PUBLICID` construction is not documented clearly enough (see NCHS's
linkage-methods appendix, referenced in the LMF codebook) to assume the
same global uniqueness across survey years, so this function matches
conservatively on the `(PUBLICID, year)` pair rather than `PUBLICID`
alone.

## See also

[`nhis_lmf_years()`](https://dwinsemius.github.io/nhanesR/reference/nhis_lmf_years.md)
for years with a public-use LMF;
[`nhis_mortality_parse()`](https://dwinsemius.github.io/nhanesR/reference/nhis_mortality_parse.md)
which produces the input to this join;
[`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md)
for the NHANES equivalent.

## Examples

``` r
# \donttest{
# nhis_data must be supplied from elsewhere -- nhanesR does not download it
# nhis_data <- your_nhis_loading_function(...)
# nhis_data_mort <- nhis_mortality_link(nhis_data)
# }
```
