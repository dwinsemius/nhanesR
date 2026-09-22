# List NHIS survey years with Household/Person data available

List NHIS survey years with Household/Person data available

## Usage

``` r
nhis_data_years(module = c("either", "household", "person"))
```

## Arguments

- module:

  Character. `"either"` (default, years where at least one of
  Household/Person is available), `"household"`, or `"person"`.

## Value

Character vector of NHIS survey years.

## The 1989 Household gap

1989's Household `.zip` is confirmed absent from the CDC server (HTTP
404), despite that year's own documentation (`readme.txt`) listing a
Household file in its file table (48,054 records, the same 335-byte
record length as every other core file that year). The matching
`HOUSEHLD.SAS` syntax file is still present – only the data file itself
is missing. Every case/extension variant (`.EXE`/`.exe`/`.ZIP`/`.zip`,
upper/lower filename) was checked before concluding this is a genuine
absence on NCHS's end rather than a URL-pattern issue here. 1989's
Person file is unaffected.

## See also

[`nhis_download()`](https://dwinsemius.github.io/nhanesR/reference/nhis_download.md)
