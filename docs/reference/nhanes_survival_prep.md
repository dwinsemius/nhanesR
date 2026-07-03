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
  weight_var = NULL,
  seqn_col = "SEQN",
  cycle_col = "cycle"
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

- seqn_col:

  Character. Name of the participant sequence-number column. Default
  `"SEQN"`. Use `"seqn"` for `nhanesdata` output.

- cycle_col:

  Character. Name of the cycle column. Default `"cycle"`. Use `"year"`
  for `nhanesdata` output.

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

## Survey weights

NHANES provides three families of survey weight, each correcting for a
different sampling stage. Choosing the wrong weight produces biased
point estimates and incorrect standard errors.

|  |  |
|----|----|
| Weight | When to use |
| `WTINT2YR` | Interview-only data (questionnaires, no lab/exam) |
| `WTMEC2YR` | Any examination or laboratory component |
| `WTSAF2YR` | Analytes from the **fasting subsample** (triglycerides, glucose, insulin, calculated LDL) |

The fasting subsample weight (`WTSAF2YR`) is a *statistical* probability
weight – not a body-weight measurement – that accounts for the
additional random subsampling of participants asked to fast before their
blood draw. Fasting participants are a minority of all MEC attendees;
using `WTMEC2YR` for fasting analytes ignores this extra subsampling
step and will give incorrect population estimates.

For pooled multi-cycle analyses divide the 2-year weight by the number
of cycles pooled, or use the pre-computed 4-year weight `WTMEC4YR` where
available. See the NHANES analytic guidelines for details.

## Perturbed variables

`PERMTH_INT`, `PERMTH_EXM`, and `UCOD_LEADING` contain synthetic values
for select records (CDC data perturbation to reduce re-identification
risk). `MORTSTAT` is not perturbed. Cause-specific analyses using
`UCOD_LEADING` should be interpreted with this in mind.

## See also

[`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md)
which produces the input for this function;
[`nhanes_followup_summary()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_followup_summary.md)
to check follow-up time by cycle;
[`nhanes_ucod_labels()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_ucod_labels.md)
for cause-of-death codes accepted by `cause`.

## Examples

``` r
# \donttest{
demo_list <- nhanes_download("DEMO", c("2013-2014", "2015-2016"))
demo <- nhanes_stack(demo_list)
demo_mort <- nhanes_mortality_link(demo)

# All-cause mortality, exam origin, MEC 2-year weight
surv_data <- nhanes_survival_prep(
  demo_mort,
  origin     = "exam",
  time_unit  = "years",
  weight_var = "WTMEC2YR"
)
#> Warning: ! Removed 8072 ineligible participants (8041 under 18; 31 insufficient
#>   identifying data).
#> ℹ These records cannot be used in survival analyses with the public-use LMF.
#>   12074 eligible participants remain.
#> ℹ See the LMF documentation for eligibility criteria:
#>   <https://www.cdc.gov/nchs/data/datalinkage/public-use-linked-mortality-file-description.pdf>
#> Warning: ! Data contains 2 NHANES cycles: "2013-2014" and "2015-2016".
#> ℹ All cycles censor at December 31, 2019. Participants enrolled in later cycles
#>   have shorter maximum follow-up. Consider this asymmetry in any pooled or
#>   stacked analysis.
#> 2 records have follow-up time < 0.5 months (same-month exam and death). Time
#> floored at 0.5 months.
#> Warning: 441 records have non-missing MORTSTAT but missing PERMTH_EXM. These will
#> produce NA in the "time" column.
#> Warning: ! Using 2-year weight "WTMEC2YR" with 2 pooled cycles.
#> ℹ Divide 2-year weights by the number of cycles pooled, or use a pre-computed
#>   4-year weight where available.
#> ℹ See NHANES analytic guidelines:
#>   <https://wwwn.cdc.gov/nchs/nhanes/analyticguidelines.aspx>

# Cause-specific: cardiovascular (code "001")
surv_data_cvd <- nhanes_survival_prep(
  demo_mort,
  origin = "exam",
  cause  = "001",
  weight_var = "WTMEC2YR"
)
#> Warning: ! Removed 8072 ineligible participants (8041 under 18; 31 insufficient
#>   identifying data).
#> ℹ These records cannot be used in survival analyses with the public-use LMF.
#>   12074 eligible participants remain.
#> ℹ See the LMF documentation for eligibility criteria:
#>   <https://www.cdc.gov/nchs/data/datalinkage/public-use-linked-mortality-file-description.pdf>
#> Warning: ! Data contains 2 NHANES cycles: "2013-2014" and "2015-2016".
#> ℹ All cycles censor at December 31, 2019. Participants enrolled in later cycles
#>   have shorter maximum follow-up. Consider this asymmetry in any pooled or
#>   stacked analysis.
#> 2 records have follow-up time < 0.5 months (same-month exam and death). Time
#> floored at 0.5 months.
#> Warning: 441 records have non-missing MORTSTAT but missing PERMTH_EXM. These will
#> produce NA in the "time" column.
#> Cause-specific event "event_cause": Diseases of heart (UCOD 001). 199 events
#> among eligible participants.
#> Warning: ! Using 2-year weight "WTMEC2YR" with 2 pooled cycles.
#> ℹ Divide 2-year weights by the number of cycles pooled, or use a pre-computed
#>   4-year weight where available.
#> ℹ See NHANES analytic guidelines:
#>   <https://wwwn.cdc.gov/nchs/nhanes/analyticguidelines.aspx>

# Use with survival package
library(survival)
library(survey)
#> Loading required package: grid
#> Loading required package: Matrix
#> 
#> Attaching package: ‘survey’
#> The following object is masked from ‘package:graphics’:
#> 
#>     dotchart
design <- svydesign(
  id      = ~SDMVPSU,
  strata  = ~SDMVSTRA,
  weights = ~survey_weight,
  nest    = TRUE,
  data    = surv_data
)
# }
```
