# Read chosen columns of an NHANES III file

Reads only the columns you ask for from the large fixed-width `.dat`
file, using the positions in its SAS program
([`nhanes3_layout()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_layout.md)).
Choose the columns by name with `vars`, or, in an interactive session,
leave `vars` out to pick them from a list (use `pattern` to shorten the
list first). `SEQN`, the respondent ID used to link files and mortality,
is always included when the file has it.

## Usage

``` r
nhanes3_read(
  file,
  vars = NULL,
  pattern = NULL,
  recode = NULL,
  id = "SEQN",
  dat_file = NULL,
  sas_file = NULL,
  n_max = Inf
)
```

## Arguments

- file:

  A file name from
  [`nhanes3_files()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_files.md),
  or the path to a `.sas` program (then give `dat_file` too).

- vars:

  Character vector of variable names to read. If `NULL` in an
  interactive session, you choose from a list; otherwise an error asks
  you to supply them.

- pattern:

  Optional regular expression that narrows the interactive list (name or
  label), as in
  [`nhanes3_layout()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_layout.md).

- recode:

  Names of numeric variables (among `vars`) whose all-8s and all-9s
  codes become `NA`. Default none.

- id:

  Name of the ID column to always include, or `NULL` for none.

- dat_file:

  Path to the `.dat` file, if you already have it; otherwise the cached
  copy is used, downloaded on first use (about 195 MB for the exam
  file).

- sas_file:

  Path to the `.sas` program, if you already have it.

- n_max:

  Maximum number of rows to read (default all), useful for a quick look.

## Value

A tibble with the requested columns (numeric, except any `$` character
columns). It carries `attr(, "width")`, the width of each field, and
`attr(, "var_labels")`, the SAS labels.

## Details

NHANES III stores "blank but applicable" as all 8s and "don't know" as
all 9s, sized to the field (`8`/`9` for a one-character item,
`88888`/`99999` for a five-character measurement). Left in place they
look like real values. `recode` turns these into `NA` for the variables
you name. It is **not** applied to everything: IDs, weights and age have
no such codes, and many items have special codes of their own (666 for
"varies", 777 for "less than 1 per day"), so check the codebook
([`nhanes3_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_download.md)
with `what = "codebook"`) first.

## See also

[`nhanes3_layout()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_layout.md),
[`nhanes3_files()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_files.md),
[`nhanes_mortality_parse()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_parse.md)
for the NHANES III linked mortality file.

## Examples

``` r
if (FALSE) { # \dontrun{
exam <- nhanes3_read("exam", c("HSSEX", "HSAGEIR", "BMPHT", "BMPWT", "WTPFEX6"),
                     recode = c("BMPHT", "BMPWT"))
} # }
```
