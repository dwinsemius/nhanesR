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
syntax file. **1986-1996 uses NCHS's original placeholder scheme**
instead (e.g. `HH_22`, `PX_24`) – that's literally what those years' SAS
syntax files contain. Column NAMES are never changed (a placeholder
stays a placeholder), but for **1986-1991** each placeholder column gets
a `"label"` attribute (haven/labelled convention, same as every other
labelled column in this package) with its real meaning, built from that
year's own `NHISCORE.PDF` codebook
(`data-raw/build_nhis_pre1997_crosswalk.R`). Check with
`attr(df$HH_22, "label")`, or
[`NH_describe()`](https://dwinsemius.github.io/nhanesR/reference/NH_describe.md)
to see all of them at once. **1992-1996 do not get labels** – checked
directly, not just left undone: the source PDF's own page layout changes
enough starting in 1992 (its `NHISCORE.PDF` roughly triples in page
count that year) that the crosswalk-building parser's match rate drops
hard, and unlike 1986-1991, a meaningful share of what doesn't match
already has a descriptive native variable name anyway (e.g. `REGION`,
`HEIGHT`, `WEIGHT` for 1993), so the gap matters less than the raw
match-rate drop suggests. Extending the crosswalk past 1991 is possible
future work, not done here.

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
