# Download and cache NHANES XPT data files

Downloads one or more NHANES component files in SAS transport (XPT)
format from the CDC website, parses them into R data frames, attaches
variable labels, and caches the results locally as RDS files.

## Usage

``` r
nhanes_download(file_code, cycles, refresh = FALSE, add_cycle_col = TRUE)
```

## Arguments

- file_code:

  Character. The NHANES file code(s), without suffix or extension (e.g.
  `"DEMO"`, `"BPX"`, `"TRIGLY"`). Case-insensitive. Can be a vector to
  download multiple files.

- cycles:

  Character. One or more cycle labels (e.g. `"2015-2016"`). See
  [`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md).
  If multiple cycles are given, the same file code is downloaded for
  each.

- refresh:

  Logical. Re-download and re-parse even if cached? Default `FALSE`.

- add_cycle_col:

  Logical. Add a `cycle` column to each returned data frame? Default
  `TRUE`. Required for
  [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md).

## Value

If a single file_code and single cycle are requested, a data frame. If
multiple file_codes or cycles are requested, a named list of data frames
with names of the form `"{file_code}_{cycle}"`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Single file, single cycle
demo <- nhanes_download("DEMO", "2015-2016")

# Multiple cycles (returns list)
demos <- nhanes_download("DEMO", c("2013-2014", "2015-2016", "2017-2018"))

# Multiple files, single cycle
files <- nhanes_download(c("DEMO", "BPX", "TRIGLY"), "2015-2016")
} # }
```
