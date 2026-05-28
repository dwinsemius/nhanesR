# Prepare an NHANES-LMF dataset for survival analysis

Takes a linked NHANES-mortality data frame (from
[`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md))
and returns a dataset ready for use with
[`survival::Surv()`](https://rdrr.io/pkg/survival/man/Surv.html), with:

## Usage

``` r
nhanes_survival_prep(
  data,
  origin = c("exam", "interview"),
  time_unit = c("months", "years"),
  cause = NULL,
  weight_var = NULL
)
```

## Arguments

- data:

  A data frame from
  [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md).

- origin:

  Character. Follow-up origin: `"interview"` (uses `PERMTH_INT`) or
  `"exam"` (uses `PERMTH_EXM`). For analyses involving lab or
  examination data, use `"exam"`.

- time_unit:

  Character. `"months"` (default, as stored in LMF) or `"years"`
  (divides by 12).

- cause:

  Character or `NULL`. If supplied, creates a cause-specific event
  indicator `event_cause` that is 1 only when `UCOD_LEADING` matches
  this code and `MORTSTAT == 1`. See
  [`nhanes_ucod_labels()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_ucod_labels.md)
  for valid codes. For all-cause mortality, leave `NULL`.

- weight_var:

  Character. Name of the survey weight column to carry through. The
  column is renamed to `survey_weight` in the output. If `NULL`, no
  weight is attached.

## Value

A data frame with additional columns:

- time:

  Follow-up time in specified units.

- event:

  All-cause mortality indicator (0/1).

- event_cause:

  Cause-specific indicator, if `cause` supplied.

- survey_weight:

  Survey weight, renamed from `weight_var`.

- .eligstat_dropped:

  Attribute recording how many rows were removed.

## Details

- Ineligible participants (`ELIGSTAT != 1`) removed with a warning

- A `time` column (in months or years) from the specified follow-up
  origin

- An `event` column (0/1) from `MORTSTAT`

- Optional cause-specific event indicator based on `UCOD_LEADING`

- Survey weight column renamed and validated

## Eligibility filtering

Participants with `ELIGSTAT != 1` are **automatically removed** with a
warning. This includes those under 18 at time of survey
(`ELIGSTAT == 2`) and those with insufficient identifying data for
linkage (`ELIGSTAT == 3`). The number dropped is reported and attached
as an attribute.

## Asymmetric follow-up across cycles

All public-use LMF files censor at December 31, 2019. Participants
enrolled in later cycles (e.g. 2017-2018) have substantially shorter
maximum follow-up than those enrolled in 1999-2000. This function warns
when multiple cycles are detected, as this asymmetry must be accounted
for in any pooled analysis.

## Perturbed variables

`PERMTH_INT`, `PERMTH_EXM`, and `UCOD_LEADING` contain synthetic values
for select records (CDC data perturbation to reduce re-identification
risk). `MORTSTAT` is not perturbed. Cause-specific analyses using
`UCOD_LEADING` should be interpreted with this in mind.

## Examples

``` r
if (FALSE) { # \dontrun{
demo <- nhanes_download("DEMO", c("2013-2014", "2015-2016"))
demo_mort <- nhanes_mortality_link(demo)

# All-cause mortality, exam origin, MEC 2-year weight
surv_data <- nhanes_survival_prep(
  demo_mort,
  origin     = "exam",
  time_unit  = "years",
  weight_var = "WTMEC2YR"
)

# Cause-specific: cardiovascular (code "001")
surv_data_cvd <- nhanes_survival_prep(
  demo_mort,
  origin = "exam",
  cause  = "001",
  weight_var = "WTMEC2YR"
)

# Use with survival package
library(survival)
library(survey)
design <- svydesign(
  id      = ~SDMVPSU,
  strata  = ~SDMVSTRA,
  weights = ~survey_weight,
  nest    = TRUE,
  data    = surv_data
)
} # }
```
