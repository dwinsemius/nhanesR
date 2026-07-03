# Link mortality data onto an NHANES analytic dataset

Performs a left join of the parsed LMF onto a data frame containing
NHANES participants, matched on the participant sequence number.
Automatically handles multiple cycles by row-binding the appropriate LMF
files before joining.

## Usage

``` r
nhanes_mortality_link(
  nhanes_data,
  cycles = NULL,
  keep_vars = NULL,
  download = TRUE,
  seqn_col = "SEQN",
  cycle_col = "cycle"
)
```

## Arguments

- nhanes_data:

  A data frame containing NHANES participants.

- cycles:

  Character vector of `"YYYY-YYYY"` cycle labels present in
  `nhanes_data`. Inferred from `cycle_col` when omitted.

- keep_vars:

  Character vector of LMF variables to retain. Defaults to all:
  `c("ELIGSTAT", "MORTSTAT", "UCOD_LEADING", "DIABETES", "HYPERTEN", "PERMTH_INT", "PERMTH_EXM")`.

- download:

  Logical. Download missing LMF files automatically? Default `TRUE`.

- seqn_col:

  Character. Name of the participant sequence-number column in
  `nhanes_data`. Default `"SEQN"` (nhanesR / CDC standard). Use `"seqn"`
  for `nhanesdata` output.

- cycle_col:

  Character. Name of the cycle column in `nhanes_data`. Default
  `"cycle"` (`"YYYY-YYYY"` labels). Use `"year"` for `nhanesdata`
  output, where the column contains integer start years (e.g. 1999,
  2001).

## Value

`nhanes_data` with LMF columns appended. Rows with no mortality record
(SEQNs absent from the LMF) will have `NA` for all LMF columns; this
should not occur for continuous NHANES 1999-2018.

## Details

Data from any source –
[`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md),
`nhanesA`, or `nhanesdata` – can be linked by supplying the appropriate
column name arguments. For example, `nhanesdata` stores the sequence
number as `seqn` (integer) and the cycle as `year` (integer start year,
e.g. 1999); pass `seqn_col = "seqn", cycle_col = "year"` and both are
handled automatically.

## See also

[`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md)
to convert the linked data into a survival dataset;
[`nhanes_lmf_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_lmf_cycles.md)
for cycles with a public-use LMF;
[`nhanes_stack()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_stack.md)
to row-bind multi-cycle data before linking.

## Examples

``` r
# \donttest{
demo <- nhanes_download("DEMO", "2015-2016")
demo_mort <- nhanes_mortality_link(demo)
# }
```
