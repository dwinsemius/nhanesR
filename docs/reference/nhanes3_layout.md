# The variables in an NHANES III file: names, labels and column positions

Parses the SAS program that ships with each NHANES III file. This is the
stage where you can stop and choose which columns to read: the exam file
has more than 2,000 and the adult questionnaire more than 1,200, and
reading a handful by position is fast while reading them all is not.
Only the small `.sas` file is needed, not the large `.dat`.

## Usage

``` r
nhanes3_layout(
  file,
  pattern = NULL,
  ignore.case = TRUE,
  sas_file = NULL,
  refresh = FALSE
)
```

## Arguments

- file:

  A file name from
  [`nhanes3_files()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_files.md),
  or the path to a `.sas` program.

- pattern:

  Optional regular expression; keep the variables whose **name or
  label** matches it, for example `"height|weight|waist"`.

- ignore.case:

  Match `pattern` without regard to case (default `TRUE`).

- sas_file:

  Path to the `.sas` program, if you already have it; otherwise the
  cached copy is used, downloaded on first use.

- refresh:

  Download the `.sas` file again.

## Value

A data frame of class `nhanes3_layout` with one row per variable: `var`,
`label` (`NA` if the SAS program gives none), `start`, `end`, `width`
(the number of characters in the field) and `type` (`"numeric"` or
`"character"`). The record length is checked against the layout and
stored in `attr(, "lrecl")`.

## Details

Labels are the short descriptions from the SAS program (for example
`"How tall are you without shoes - inches"`). Value labels and the
missing-value codes of each variable are in the codebook PDF, and a
variable's own special codes (for example 666 for "varies") are not the
same as the all-8s/all-9s codes that
[`nhanes3_read()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_read.md)
can recode; check the codebook before recoding (see the `nhanes-iii`
vignette).

## See also

[`nhanes3_read()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_read.md),
[`nhanes3_files()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_files.md)

## Examples

``` r
if (FALSE) { # \dontrun{
nhanes3_layout("adult", pattern = "tall|weigh")   # heights and weights people reported
nhanes3_layout("exam", pattern = "^BMP")          # the body-measure variables
} # }
```
