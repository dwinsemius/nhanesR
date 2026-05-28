# Merge NHANES component data frames by SEQN

Joins two or more NHANES data frames on the `SEQN` respondent sequence
number. Validates that survey design variables (PSU, strata, weights)
are present and warns when merging across components that use different
weight variables.

## Usage

``` r
nhanes_merge(..., by = "SEQN", type = c("inner", "left"), weight_var = NULL)
```

## Arguments

- ...:

  Two or more data frames from
  [`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md),
  each containing a `SEQN` column. For multi-cycle datasets, also a
  `cycle` column.

- by:

  Character vector of join key(s). Default `"SEQN"`. For multi-cycle
  data, use `c("SEQN", "cycle")`.

- type:

  Character. Join type: `"inner"` retains only participants present in
  all files; `"left"` retains all participants from the first file.
  Default `"inner"` (the standard NHANES analytic approach).

- weight_var:

  Character or `NULL`. If supplied, validates that this weight column
  exists in the merged result.

## Value

A merged data frame. Duplicate columns (present in more than one input)
are deduplicated, keeping the version from the first data frame where
the column appears, with a warning.

## Details

### Weight guidance

The appropriate weight depends on which components are merged:

- **Demographics only** → `WTINT2YR` (interview weight)

- **Any exam/lab component** → `WTMEC2YR` (MEC exam weight)

- **Dietary 24-hr recall** → `WTDRD1` or `WTDR2D`

- **Multi-cycle pooled** → divide the 2-year weight by the number of
  cycles, or use the 4-year combined weight where available

This function warns but does not enforce weight selection. Use
[`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md)
to look up available weight variable names per cycle.

## See also

[`nhanes_stack()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_stack.md)
to row-bind per-cycle lists before merging;
[`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md)
to obtain the component data frames;
[`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md)
to append mortality follow-up after merging.

## Examples

``` r
if (FALSE) { # \dontrun{
demo  <- nhanes_download("DEMO",  "2015-2016")
bpx   <- nhanes_download("BPX",   "2015-2016")
trigly <- nhanes_download("TRIGLY","2015-2016")

analytic <- nhanes_merge(demo, bpx, trigly)

# Multi-cycle
demo_13 <- nhanes_download("DEMO", "2013-2014")
demo_15 <- nhanes_download("DEMO", "2015-2016")
bpx_13  <- nhanes_download("BPX",  "2013-2014")
bpx_15  <- nhanes_download("BPX",  "2015-2016")

demo_pool <- rbind(demo_13, demo_15)
bpx_pool  <- rbind(bpx_13,  bpx_15)
analytic  <- nhanes_merge(demo_pool, bpx_pool, by = c("SEQN", "cycle"))
} # }
```
