# Attach descriptive labels to a pre-1997 Household/Person data frame

Looks up `.nhis_pre1997_crosswalk` (built by
`data-raw/build_nhis_pre1997_crosswalk.R`, covering 1986-1991 only – see
that script's own header for why the scope stops there) and attaches a
`"label"` attribute (haven/labelled convention, same as every other
labelled column in this package) to each matching placeholder-named
column. Years/modules with no crosswalk entry (1992 onward, and any
column the crosswalk itself couldn't resolve to a label) are left
untouched – this never errors or warns for missing coverage, since most
of nhis_download()'s callers will be asking for years this doesn't
cover.

## Usage

``` r
.nhis_apply_pre1997_labels(df, year, module)
```
