# Validate (and where possible, correct) a pre-1997 NHIS SAS layout

Returns `NULL` if the file's literal positions can't be extracted at all
(falls back to plain
[`SAScii::read.SAScii()`](https://rdrr.io/pkg/SAScii/man/read.SAScii.html)
unchanged), or a data frame of corrected (varname, start, end, char) if
extraction succeeded – whether or not any correction was actually
needed. Aborts with
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html) if
a defect is found that isn't one of the two known, handled patterns
(subset overlap; LENGTH-statement width mismatch).

## Usage

``` r
.nhis_sas_validate_and_fix(sas_path, year, module)
```
