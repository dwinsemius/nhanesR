# Link mortality data onto an NHANES analytic dataset

Performs a left join of the parsed LMF onto a data frame containing
NHANES participants, matched on `SEQN`. Automatically handles multiple
cycles by row-binding the appropriate LMF files before joining.

## Usage

``` r
nhanes_mortality_link(
  nhanes_data,
  cycles = NULL,
  keep_vars = NULL,
  download = TRUE
)
```

## Arguments

- nhanes_data:

  A data frame with at minimum a `SEQN` column and a `cycle` column
  (added automatically by
  [`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md)).
  If `cycle` is absent, `cycle` must be supplied.

- cycles:

  Character vector of cycle labels present in `nhanes_data`. Required if
  `nhanes_data` does not have a `cycle` column.

- keep_vars:

  Character vector of LMF variables to retain. Defaults to all:
  `c("ELIGSTAT", "MORTSTAT", "UCOD_LEADING", "DIABETES", "HYPERTEN", "PERMTH_INT", "PERMTH_EXM")`.

- download:

  Logical. Download missing LMF files automatically? Default `TRUE`.

## Value

`nhanes_data` with LMF columns appended. Rows with no mortality record
(i.e., SEQNs not present in the LMF) will have `NA` for all LMF columns
— this should not occur for continuous NHANES 1999-2018.

## See also

[`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md)
to convert the linked data into a survival dataset;
[`nhanes_lmf_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_lmf_cycles.md)
for the cycles with public-use LMF;
[`nhanes_stack()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_stack.md)
to row-bind multi-cycle data before linking.

## Examples

``` r
if (FALSE) { # \dontrun{
demo <- nhanes_download("DEMO", "2015-2016")
demo_mort <- nhanes_mortality_link(demo)
} # }
```
