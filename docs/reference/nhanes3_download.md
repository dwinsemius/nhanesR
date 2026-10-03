# Download NHANES III files into the nhanesR cache

Fetches the data file, its SAS program (which holds the column positions
and variable labels) and the codebook PDF, and keeps them in the nhanesR
cache (see
[`nhanes_cache_dir()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cache_dir.md))
so they are downloaded once. The exam file is about 195 MB, so the
download timeout is raised to at least 15 minutes for these files.

## Usage

``` r
nhanes3_download(file, what = c("sas", "dat", "codebook"), refresh = FALSE)
```

## Arguments

- file:

  A file name from
  [`nhanes3_files()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_files.md):
  `"exam"`, `"adult"`, `"youth"`, `"lab"` or `"lab2"`.

- what:

  Which pieces to fetch: `"sas"`, `"dat"` and/or `"codebook"`. The
  default is all three.

- refresh:

  Download again even if the file is already cached.

## Value

Invisibly, a named character vector of the local paths.

## Details

The `.sas` file is small. It is enough for
[`nhanes3_layout()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_layout.md),
so you can look through the variables before deciding to download the
large `.dat`.

## See also

[`nhanes3_layout()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_layout.md),
[`nhanes3_read()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_read.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# the small SAS program only: enough to browse the variables
nhanes3_download("adult", what = "sas")
} # }
```
