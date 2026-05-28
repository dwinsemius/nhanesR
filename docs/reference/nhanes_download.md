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

## Details

### Finding valid file codes

File codes are the base names CDC assigns to each data file, without the
cycle-letter suffix or `.xpt` extension. For example, the Demographics
file is always `"DEMO"`, and the blood pressure examination file is
`"BPX"`.

Use
[`nhanes_manifest()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md)
to browse all files available for a given cycle and component. The
`file_name` column of the manifest shows the full CDC name including the
cycle suffix (e.g. `"TCHOL_I"`); strip the trailing underscore-letter to
get the base code for `nhanes_download()`:

    m <- nhanes_manifest("2015-2016", "Laboratory")
    m[, c("file_name", "description")]

    # Base codes ready for nhanes_download():
    sub("_[A-Z]$", "", m$file_name)

Note that some analyte file names changed across cycles (e.g. total
cholesterol: `LAB13` → `L13_B` → `TCHOL_D` onward). For those cases, use
[`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md)
instead, which looks up the correct CDC filename for each cycle
automatically via the variable catalog.

### Invalid file codes

File codes are not validated before the download attempt. If an unknown
code is supplied, CDC returns HTTP 200 with an HTML error page rather
than a 404. nhanesR detects this via the `Content-Type` header and
aborts with a message directing you to
[`nhanes_manifest()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md)
to confirm the correct name.

## See also

[`nhanes_manifest()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md)
to browse available file codes;
[`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md)
for analytes whose file name changed across cycles;
[`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md)
for valid cycle labels.

## Examples

``` r
if (FALSE) { # \dontrun{
# Browse available Laboratory files for a cycle, then download by base code
m <- nhanes_manifest("2015-2016", "Laboratory")
m[, c("file_name", "description")]   # see what's available
bpx <- nhanes_download("BPX", "2015-2016")

# Single file, single cycle
demo <- nhanes_download("DEMO", "2015-2016")

# Multiple cycles (returns list)
demos <- nhanes_download("DEMO", c("2013-2014", "2015-2016", "2017-2018"))

# Multiple files, single cycle
files <- nhanes_download(c("DEMO", "BPX", "TRIGLY"), "2015-2016")
} # }
```
