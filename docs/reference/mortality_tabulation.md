# Tabulate deaths, person-years and crude mortality rates

Counts deaths and accumulates person-years of exposure in the cells of
one or more categorical covariates, and returns the crude mortality rate
in each cell together with **every marginal table** (one-way, two-way,
and so on) in the same long data frame.

## Usage

``` r
mortality_tabulation(
  data,
  time,
  event,
  by,
  time_units = c("years", "months", "days"),
  scale = 1000,
  weights = NULL,
  expected = NULL,
  margins = TRUE,
  breaks = NULL,
  age_col = NULL,
  age_breaks = NULL,
  conf_level = 0.95
)
```

## Arguments

- data:

  A data frame with one row per person.

- time:

  Name of the follow-up time column (time from entry to death or
  censoring), in `time_units`.

- event:

  Name of the event column: `1` or `TRUE` for a death, `0` or `FALSE`
  for censored.

- by:

  Character vector naming the categorical covariates that define the
  cells. Numeric covariates with more than 20 distinct values must be
  cut with `breaks`.

- time_units:

  Units of `time`: `"years"`, `"months"` or `"days"`. Person-years are
  always reported in years.

- scale:

  Rates are reported per `scale` person-years (default 1000).

- weights:

  Optional name of a survey-weight column. Cells then hold weighted
  deaths and weighted person-years (point estimates). The confidence
  intervals are **not valid** with weights and are returned as `NA`.

- expected:

  Optional name of a column holding each person's **expected number of
  deaths** over their follow-up (for example the fitted death
  probability from a model of age, sex and period). Cells then also
  report expected deaths and the observed/expected ratio (O/E) with
  exact intervals. Cannot be combined with `age_breaks`.

- margins:

  If `TRUE` (default) return all marginal tables and the grand total; if
  `FALSE` return only the finest cells.

- breaks:

  Optional named list of cut points used to categorise numeric
  covariates in `by`, for example `list(BMI = c(0, 18.5, 25, 30, Inf))`.
  Intervals are closed on the left.

- age_col, age_breaks:

  Optional. `age_col` names a column holding age at entry in years; with
  `age_breaks` each person's follow-up is split across the attained-age
  bands they pass through (using
  [`survival::pyears()`](https://rdrr.io/pkg/survival/man/pyears.html)),
  and attained age becomes one more tabulation covariate named
  `attained_age`. Requires the survival package.

- conf_level:

  Confidence level of the intervals (default 0.95).

## Value

A data frame of class `mortality_tabulation` with one column per
covariate in `by`, then `n` (people, or weighted people), `deaths`,
`pyears`, `rate`, `rate_lo`, `rate_hi`, and with `expected` also
`expected`, `oe`, `oe_lo`, `oe_hi`; the column `n_cov` counts how many
covariates define each row (`0` for the grand total). Rows are ordered
by `n_cov`, then by the factor levels of `by`. With `age_breaks`, `n`
counts the people who start follow-up in each cell.

## Details

This is a rate tabulation, **not a life table**. The exposure basis is
the follow-up time of everyone: decedents contribute time from entry to
death and censored people contribute time from entry to censoring, so a
rate is deaths divided by all person-years at risk, not only the
exposure of those who died.

Margins are exact aggregates of the finest cells, with the rate
recomputed from the margin's own deaths and person-years (rates are
never averaged). A covariate that has been collapsed is labelled
`"All"`; the grand total has every covariate set to `"All"`. Confidence
intervals are exact Poisson intervals on the death count, treating
person-years as fixed.

## See also

[`tabulation_grid()`](https://dwinsemius.github.io/nhanesR/reference/tabulation_grid.md)
to pivot two covariates into a grid;
[`survival::pyears()`](https://rdrr.io/pkg/survival/man/pyears.html),
which does the same counting for fixed cells.

## Examples

``` r
set.seed(1)
d <- data.frame(sex = sample(c("F", "M"), 500, TRUE),
                bmi = sample(c("<25", "25+"), 500, TRUE),
                t = rexp(500, 0.05))
d$dead <- as.integer(d$t < 12); d$t <- pmin(d$t, 12)
tab <- mortality_tabulation(d, time = "t", event = "dead", by = c("sex", "bmi"))
tab
#> Mortality tabulation: deaths and person-years of all follow-up (decedents + censored); rate per 1,000 person-years
#>  sex bmi   n deaths  pyears  rate rate_lo rate_hi
#>  All All 500    208 4610.12 45.12   39.19   51.68
#>    F All 256    107 2320.35 46.11   37.79   55.72
#>    M All 244    101 2289.77 44.11   35.93   53.60
#>  All 25+ 254    109 2318.41 47.01   38.60   56.71
#>  All <25 246     99 2291.70 43.20   35.11   52.59
#>    F 25+ 118     52 1049.29 49.56   37.01   64.99
#>    F <25 138     55 1271.06 43.27   32.60   56.32
#>    M 25+ 136     57 1269.12 44.91   34.02   58.19
#>    M <25 108     44 1020.64 43.11   31.32   57.87
tabulation_grid(tab, rows = "bmi", cols = "sex")
#>      sex
#> bmi          F        M      All
#>   25+ 49.55734 44.91290 47.01492
#>   <25 43.27095 43.11005 43.19929
#>   All 46.11373 44.10929 45.11816
```
