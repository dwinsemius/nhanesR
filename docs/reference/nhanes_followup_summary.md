# Summarise mortality follow-up by cycle

Diagnostic helper that reports median follow-up time, event rate, and
maximum possible follow-up per cycle. Useful for assessing the
asymmetric censoring problem when pooling cycles.

## Usage

``` r
nhanes_followup_summary(data)
```

## Arguments

- data:

  A data frame from
  [`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md).

## Value

A data frame with one row per cycle.

## See also

[`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md)
which produces the required input.

## Examples

``` r
if (FALSE) { # \dontrun{
surv_data <- nhanes_survival_prep(linked_data, origin = "exam")
nhanes_followup_summary(surv_data)
} # }
```
