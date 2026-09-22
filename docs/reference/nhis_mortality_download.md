# Download NHIS Public-Use Linked Mortality Files

Downloads the fixed-width `.dat` mortality files from the CDC FTP server
for one or more NHIS survey years. Files are cached locally;
re-downloading is skipped unless `refresh = TRUE`.

## Usage

``` r
nhis_mortality_download(
  years = NULL,
  refresh = FALSE,
  quiet = !getOption("nhanesR.verbose", TRUE)
)
```

## Arguments

- years:

  Character or numeric vector of NHIS survey years (e.g. `"1997"` or
  `1997`). Defaults to all years with a public-use LMF. See
  [`nhis_lmf_years()`](https://dwinsemius.github.io/nhanesR/reference/nhis_lmf_years.md).

- refresh:

  Logical. Re-download even if a cached file exists? Default `FALSE`.

- quiet:

  Logical. Suppress download messages? Default uses the
  `nhanesR.verbose` option.

## Value

Invisibly, a named character vector of local file paths (one per year).
The primary side-effect is writing files to the cache directory under
`mortality/dat/`.

## Details

NCHS distributes NHIS mortality linkage as one file per **survey year**
(unlike NHANES's one file per 2-year cycle). The public-use LMF provides
mortality follow-up through **December 31, 2019** for NHIS 1986-2018.

## See also

[`nhis_mortality_parse()`](https://dwinsemius.github.io/nhanesR/reference/nhis_mortality_parse.md),
[`nhis_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhis_mortality_link.md),
[`nhanes_mortality_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_download.md)
for the NHANES equivalent.

## Examples

``` r
# \donttest{
# Download specific years (downloading all 33 available years at once,
# via nhis_mortality_download() with no arguments, works the same way but
# is a much larger multi-file FTP batch -- prefer a specific year vector
# for routine use)
nhis_mortality_download(c("2015", "2016", "2017"))
# }
```
