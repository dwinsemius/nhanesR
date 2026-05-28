# Download NHANES Public-Use Linked Mortality Files

Downloads the fixed-width `.dat` mortality files from the CDC FTP server
for one or more NHANES cycles. Files are cached locally; re-downloading
is skipped unless `refresh = TRUE`.

## Usage

``` r
nhanes_mortality_download(
  cycles = NULL,
  refresh = FALSE,
  quiet = !getOption("nhanesR.verbose", TRUE)
)
```

## Arguments

- cycles:

  Character vector of cycle labels. Defaults to all cycles with a
  public-use LMF. See
  [`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md)
  and
  [`nhanes_lmf_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_lmf_cycles.md).

- refresh:

  Logical. Re-download even if a cached file exists? Default `FALSE`.

- quiet:

  Logical. Suppress download messages? Default uses the
  `nhanesR.verbose` option.

## Value

Invisibly, a named character vector of local file paths (one per cycle).
The primary side-effect is writing files to the cache directory under
`mortality/dat/`.

## Details

The public-use LMF provides mortality follow-up through **December 31,
2019** for NHANES 1999-2018 and NHANES III. Files were released in April
2022 and will not be updated (the 2022-linked restricted-use files
require RDC access).

## See also

[`nhanes_mortality_parse()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_parse.md),
[`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md),
[`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Download all available cycles
nhanes_mortality_download()

# Download specific cycles
nhanes_mortality_download(c("2013-2014", "2015-2016", "2017-2018"))
} # }
```
