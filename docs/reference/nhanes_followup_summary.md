# Summarize mortality follow-up by cycle

Diagnostic helper that reports median follow-up time, event rate, and
maximum possible follow-up per cycle. Useful for assessing the
asymmetric censoring problem when pooling cycles.

## Usage

``` r
nhanes_followup_summary(data, cycle_col = "cycle")
```

## Arguments

- data:

  A data frame from
  [`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md).

- cycle_col:

  Character. Name of the cycle column. Default `"cycle"`. Use `"year"`
  for data originating from `nhanesdata`.

## Value

A data frame with one row per cycle.

## See also

[`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md)
which produces the required input.

## Examples

``` r
# \donttest{
demo <- nhanes_download("DEMO", "2015-2016")
linked <- nhanes_mortality_link(demo)
surv_data <- nhanes_survival_prep(linked, origin = "exam")
#> Warning: ! Removed 3997 ineligible participants (3979 under 18; 18 insufficient
#>   identifying data).
#> ℹ These records cannot be used in survival analyses with the public-use LMF.
#>   5974 eligible participants remain.
#> ℹ See the LMF documentation for eligibility criteria:
#>   <https://www.cdc.gov/nchs/data/datalinkage/public-use-linked-mortality-file-description.pdf>
#> 1 record has follow-up time < 0.5 months (same-month exam and death). Time
#> floored at 0.5 months.
#> Warning: 254 records have non-missing MORTSTAT but missing PERMTH_EXM. These will
#> produce NA in the "time" column.
nhanes_followup_summary(surv_data)
#>       cycle    n n_events event_rate_pct median_followup max_followup time_unit
#> 1 2015-2016 5974      276           4.62              47           61    months
# }
```
