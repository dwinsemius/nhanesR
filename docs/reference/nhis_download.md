# Download and parse an NHIS Household or Person file

Downloads the fixed-width `.zip`, unzips it, downloads the matching SAS
input-syntax file NCHS publishes alongside it, and parses both together
using
[`SAScii::read.SAScii()`](https://rdrr.io/pkg/SAScii/man/read.SAScii.html)
– reusing NCHS's own column-position specification rather than a
hand-built one. Results are cached locally as RDS files, same convention
as
[`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md)
and
[`nhis_mortality_parse()`](https://dwinsemius.github.io/nhanesR/reference/nhis_mortality_parse.md).

## Usage

``` r
nhis_download(module, years = NULL, refresh = FALSE)
```

## Arguments

- module:

  Character. `"household"` or `"person"`.

- years:

  Character or numeric vector of NHIS survey years. Defaults to all
  years available for `module` (see
  [`nhis_data_years()`](https://dwinsemius.github.io/nhanesR/reference/nhis_data_years.md)).

- refresh:

  Logical. Re-download/re-parse even if a cached RDS exists? Default
  `FALSE`.

## Value

If a single year is requested, a data frame. If multiple years are
requested, a named list of data frames keyed by year. Every returned
data frame carries a `.nhis_data_year` integer column (the requested
survey year, not to be confused with a native `YEAR`/ `SRVY_YR` column
the file itself may already contain).

## Column names differ by era

1997 onward uses NCHS's own descriptive variable names directly
(`SRVY_YR`, `HHX`, `WTFA_HH`, ...), taken straight from that era's SAS
syntax file – no further relabeling needed. **1986-1996 uses NCHS's
original placeholder scheme** (e.g. `HH_22`, `PX_24`) because that's
literally what the SAS syntax files for those years contain – there is
no `nhis_harmonize()`-equivalent yet to relabel these to their real
meanings, which requires a separate crosswalk built from `NHISCORE.PDF`
(not yet done; see this file's own development history for the scoping
discussion).

## See also

[`nhis_data_years()`](https://dwinsemius.github.io/nhanesR/reference/nhis_data_years.md)
for years with data available;
[`nhis_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhis_mortality_link.md)
to join mortality follow-up onto the result.

## Examples

``` r
# \donttest{
hh_2015 <- nhis_download("household", "2015")
# }
```
