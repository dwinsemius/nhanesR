# Survey-Weighted Survival Analysis: Fusing svycoxph and rms

## Background and Motivation

NHANES is a complex probability sample of the US civilian
non-institutionalized population. Valid inference from NHANES survival
data requires three things that standard Cox model implementations do
not provide jointly:

1.  **Survey-weighted partial likelihood** — accounts for unequal
    selection probabilities, stratification, and clustering within
    primary sampling units (PSUs). Ignoring these produces standard
    errors that are too small and confidence intervals that are too
    narrow.

2.  **Flexible nonlinear covariate effects** — biomarkers such as total
    cholesterol, GGT, and albumin have U-shaped or threshold
    relationships with mortality. Restricted cubic splines (RCS) capture
    these shapes without requiring a priori categorization.

3.  **A rich output environment** — the `rms`/`Hmisc` ecosystem provides
    nonlinearity tests (`anova.rms()`), effect displays
    ([`Predict()`](https://rdrr.io/pkg/rms/man/Predict.html),
    `plot.Predict()`), and survival curve plots
    ([`survplot()`](https://rdrr.io/pkg/rms/man/survplot.html)) that go
    far beyond what base `survival` offers.

The `survey` package provides
[`svycoxph()`](https://rdrr.io/pkg/survey/man/svycoxph.html) for (1);
the `rms` package provides
[`cph()`](https://rdrr.io/pkg/rms/man/cph.html) for (2) and (3). Neither
alone provides all three. The goal of this vignette is to describe and
implement a fusion approach that combines the survey-correct inference
of [`svycoxph()`](https://rdrr.io/pkg/survey/man/svycoxph.html) with the
output machinery of the `rms` ecosystem.

### Why not just use cph()?

[`cph()`](https://rdrr.io/pkg/rms/man/cph.html) uses the inverse
observed information matrix for variance estimation, which assumes
independent observations from a simple random sample. Applied to NHANES,
this underestimates standard errors because it ignores correlation among
participants sampled from the same PSU.

### Why not just use svycoxph()?

[`svycoxph()`](https://rdrr.io/pkg/survey/man/svycoxph.html) produces
correct point estimates and a sandwich variance-covariance matrix that
accounts for the survey design. However, its output class does not
support the `rms` generics: `anova.rms()`,
[`Predict()`](https://rdrr.io/pkg/rms/man/Predict.html),
[`nomogram()`](https://rdrr.io/pkg/rms/man/nomogram.html), and
[`survplot()`](https://rdrr.io/pkg/rms/man/survplot.html) do not
dispatch on `svycoxph` objects. Testing nonlinearity of an RCS term
requires manual use of
[`survey::regTermTest()`](https://rdrr.io/pkg/survey/man/regTermTest.html),
and plotting smooth effects requires manual construction.

### The fusion approach

The key insight is that `anova.rms()` and
[`Predict()`](https://rdrr.io/pkg/rms/man/Predict.html) depend only on:

- The coefficient vector `$coefficients`
- The variance-covariance matrix `$var`
- The `$Design` object that `rms` attaches during
  [`cph()`](https://rdrr.io/pkg/rms/man/cph.html) fitting, which maps
  coefficients to predictors and identifies spline structure

These components can be sourced from two separate fits and combined into
a single object:

- **Coefficients and vcov** from
  [`svycoxph()`](https://rdrr.io/pkg/survey/man/svycoxph.html) —
  survey-correct
- **Design and structural metadata** from
  [`cph()`](https://rdrr.io/pkg/rms/man/cph.html) — provides rms
  dispatch

Survival curve generation additionally requires a baseline hazard
estimate. For this,
[`survival::basehaz()`](https://rdrr.io/pkg/survival/man/basehaz.html)
applied to a [`cph()`](https://rdrr.io/pkg/rms/man/cph.html) object uses
an unweighted Breslow estimator. We implement a survey-weighted
alternative following Lin (2000).

### Key references

- Binder, D.A. (1992). Fitting Cox’s proportional hazards models from
  survey data. *Biometrika*, 79(1), 139–147.
- Lin, D.Y. (2000). On fitting Cox’s proportional hazards models to
  survey data. *Biometrika*, 87(1), 37–47.
- Lumley, T. (2004). Analysis of complex survey samples. *Journal of
  Statistical Software*, 9(1), 1–19.
- Harrell, F.E. (2015). *Regression Modeling Strategies*, 2nd ed.
  Springer. \[`rms` package\]

------------------------------------------------------------------------

## Step 1: Examine object structures

Before implementing the fusion, we need to understand exactly which
slots in a [`cph()`](https://rdrr.io/pkg/rms/man/cph.html) object are
used by each `rms` generic, and which corresponding components are
available in a
[`svycoxph()`](https://rdrr.io/pkg/survey/man/svycoxph.html) object.

We fit both models on the nhanesR analytic dataset using the same
formula and compare structures.

``` r

library(nhanesR)
library(rms)
library(survey)
library(survival)
library(flextable)

dat <- readRDS("~/Documents/R.code/nhanesR/analytic_survival.rds")

# Analysis population: non-statin users, adults >= 20, landmark > 2yr,
# complete GGT / albumin / TC / BMI / PIR
dat2 <- subset(dat,
  ELIGSTAT == 1 & !is.na(time) & time > 2 & statin == FALSE &
  !is.na(GGT) & !is.na(LBXSAL) & !is.na(TC) &
  !is.na(BMI) & !is.na(INDFMPIR) & RIDAGEYR >= 20
)
# N = 34,456  events = 3,975
```

``` r

# NHANES design: create on the FULL dataset, then subset the design object.
# Creating the design on the already-subsetted data can leave some strata with
# a single PSU, causing svycoxph() to fail at variance estimation.
full_design <- svydesign(
  ids     = ~SDMVPSU,
  strata  = ~SDMVSTRA,
  weights = ~WTMEC2YR,
  nest    = TRUE,
  data    = dat
)
sub_design <- subset(full_design,
  ELIGSTAT == 1 & !is.na(time) & time > 2 & statin == FALSE &
  !is.na(GGT) & !is.na(LBXSAL) & !is.na(TC) &
  !is.na(BMI) & !is.na(INDFMPIR) & RIDAGEYR >= 20
)
```

``` r

# Shared formula: RCS(4 knots) on GGT and albumin; linear adjusters
f <- Surv(time, event) ~ rcs(GGT, 4) + rcs(LBXSAL, 4) +
       RIDAGEYR + RIAGENDR + RIDRETH1 + log(BMI)

# cph() fit — x=TRUE, y=TRUE, surv=TRUE needed for Predict() and survplot()
# Inference from this fit is NOT survey-correct; used only for $Design structure
dd <- datadist(dat2)
options(datadist = "dd")
fit_cph <- cph(f, data = dat2, x = TRUE, y = TRUE, surv = TRUE)

# svycoxph() fit — survey-correct coefficients and sandwich vcov
fit_svy <- svycoxph(f, design = sub_design)
```

``` r

names(fit_cph)
```

``` r

names(fit_svy)
```

### Comparing weighted and unweighted estimates

Both point estimates and standard errors differ between the two fits,
and both differences matter. The coefficient differences (up to ~0.18
log-HR units for spline terms) mean that the unweighted
[`cph()`](https://rdrr.io/pkg/rms/man/cph.html) estimates represent the
sample, not the US population. The SE ratios (1.15–1.61) confirm that
ignoring the cluster design produces standard errors that are too small,
with the largest design effect on race/ethnicity (`RIDRETH1` ratio =
1.61), reflecting its strong geographic clustering.

``` r

tbl_coef <- data.frame(
  Term    = names(coef(fit_cph)),
  cph     = round(coef(fit_cph), 4),
  svy     = round(coef(fit_svy), 4),
  diff    = round(coef(fit_svy) - coef(fit_cph), 4),
  SE_cph  = round(sqrt(diag(vcov(fit_cph))), 4),
  SE_svy  = round(sqrt(diag(vcov(fit_svy))), 4),
  SE_ratio = round(sqrt(diag(vcov(fit_svy))) / sqrt(diag(vcov(fit_cph))), 3),
  row.names = NULL
)

flextable(tbl_coef) |>
  set_header_labels(
    Term     = "Term",
    cph      = "β (cph)",
    svy      = "β (svycoxph)",
    diff     = "Δβ",
    SE_cph   = "SE (cph)",
    SE_svy   = "SE (svycoxph)",
    SE_ratio = "SE ratio"
  ) |>
  colformat_double(digits = 4) |>
  bold(j = "SE_ratio", bold = TRUE) |>
  add_footer_lines("SE ratio > 1 indicates design effect from cluster sampling. Both β and SE differ materially, requiring substitution of both from svycoxph.") |>
  autofit()
```

------------------------------------------------------------------------

## Step 2: Identify Design slot dependencies

The `rms` generics dispatch based on the `Design` attribute attached to
`cph` objects during fitting. Inspection reveals that `cph` and
`svycoxph` share a common core of slots but diverge in the metadata
needed by each ecosystem.

Slots present in `cph` but **not** `svycoxph` — the structural
components we must preserve from `cph`:

| Slot | Purpose |
|----|----|
| `$Design` | Maps coefficients to terms; identifies spline nonlinear components |
| `$surv` | Baseline survival S_0(t) as numeric vector (not a list) |
| `$time` | Time points corresponding to `$surv` |
| `$std.err` | SEs of baseline survival (used by [`survplot()`](https://rdrr.io/pkg/rms/man/survplot.html) for confidence bands) |
| `$maxtime` | Maximum observed time |
| `$time.inc` | Time axis increment for [`survplot()`](https://rdrr.io/pkg/rms/man/survplot.html) |
| `$center`, `$scale.pred` | Centering constants for [`Predict()`](https://rdrr.io/pkg/rms/man/Predict.html) |
| `$x`, `$y` | Design matrix and survival outcome (needed for [`Predict()`](https://rdrr.io/pkg/rms/man/Predict.html)) |

Slots present in `svycoxph` but **not** `cph` — the survey-correct
inference components we substitute in:

| Slot | Purpose |
|----|----|
| `$var` | Sandwich vcov (replaces naive information-matrix vcov) |
| `$naive.var` | Naive vcov, stored separately |
| `$degf.resid` | Survey df = n_PSU − n_strata (138 for this analysis population) |
| `$survey.design` | The `svydesign` object used for fitting |
| `$weights` | Participant sampling weights |

**Coefficient naming** differs between the two fits. `rms` shortens
`rcs(GGT, 4)GGT` to `GGT` and `log(BMI)` to `BMI`; `svycoxph` preserves
the full formula terms. The positional order is identical (same
formula), so
[`svycph_fuse()`](https://dwinsemius.github.io/nhanesR/reference/svycph_fuse.md)
copies values by position and applies `cph` names.

``` r

str(fit_cph$Design, max.level = 2)
```

``` r

# Confirm positional correspondence; names will differ
length(coef(fit_cph)) == length(coef(fit_svy))  # TRUE
names(coef(fit_cph))   # rms short names
names(coef(fit_svy))   # full formula names
```

------------------------------------------------------------------------

## Step 3: Implement the fusion

The
[`svycph_fuse()`](https://dwinsemius.github.io/nhanesR/reference/svycph_fuse.md)
function takes a fitted `cph` object and a fitted `svycoxph` object with
the same formula, and returns a modified `cph`-class object with
survey-correct coefficients and vcov.

``` r

# Source the implementation (see R/svycph_fuse.R)
# devtools::load_all("~/Documents/R.code/nhanesR")
```

``` r

fit_fused <- svycph_fuse(fit_cph, fit_svy)
```

A note on coefficient naming: `rms` shortens `rcs(GGT, 4)GGT` to `GGT`
and `log(BMI)` to `BMI`, while `svycoxph` preserves the full term names.
[`svycph_fuse()`](https://dwinsemius.github.io/nhanesR/reference/svycph_fuse.md)
copies values by position (same formula guarantees same order) and
applies `cph` names so that downstream `rms` generics resolve terms
correctly.

### Comparing anova.rms() output: survey-correct vs naive

The survey-correct Wald statistics are uniformly smaller because the
sandwich vcov is larger. The magnitude of the difference reflects the
design effect for each predictor. Race/ethnicity (`RIDRETH1`) shows the
largest discrepancy (chi-square 8.60 vs 34.59, ratio ~4×), consistent
with its strong geographic clustering within NHANES PSUs.

``` r

anova(fit_fused)   # survey-correct
anova(fit_cph)     # naive — overstates significance
```

``` r

# Predict() works: survey-correct CIs on the GGT smooth effect
p <- Predict(fit_fused, GGT = seq(5, 150, by = 5), fun = exp)
plot(p, ylab = "Hazard Ratio (vs median GGT)",
     xlab = "GGT (U/L)")
```

------------------------------------------------------------------------

## Step 4: Survey-weighted baseline hazard

[`survplot()`](https://rdrr.io/pkg/rms/man/survplot.html) requires a
baseline hazard estimate. The standard
[`survival::basehaz()`](https://rdrr.io/pkg/survival/man/basehaz.html)
uses the unweighted Breslow estimator; we implement the survey-weighted
version following Lin (2000).

The weighted cumulative baseline hazard at event time $`t_i`$ is:

``` math
\hat{H}_0^w(t) = \sum_{t_i \leq t} \frac{w_i}{\sum_{j \in \mathcal{R}(t_i)} w_j \exp(\mathbf{X}_j^\top \hat{\boldsymbol{\beta}})}
```

where $`w_i`$ is the survey weight and $`\hat{\boldsymbol{\beta}}`$
comes from [`svycoxph()`](https://rdrr.io/pkg/survey/man/svycoxph.html).

The
[`weighted_basehaz()`](https://dwinsemius.github.io/nhanesR/reference/weighted_basehaz.md)
function computes both the weighted Breslow point estimate and its
standard error. The `se_type` argument controls the variance estimator:

**`se_type = "lin"` (default)** implements Lin (2000) eq. 2.4 — the
linearization variance via PSU-level totals of the influence function
$`\Phi_i(t) = \sum_{t_k \leq t} \phi_i(t_k)`$. This is the design-based
variance: it measures how much $`\hat{H}_0^w(t)`$ would change if
different PSUs had been selected. For NHANES-scale populations with rare
events, this is very small (~$`10^{-6}`$ on the log scale) because event
rates are similar across PSUs.

**`se_type = "greenwood"`** uses the survey-weighted Greenwood formula:
$`\sum_{t_k \leq t} n^w(t_k) / [Y^w(t_k)]^2`$. This measures statistical
precision from the weighted event count — the population-scale analog of
the Nelson-Aalen variance. For
[`survplot()`](https://rdrr.io/pkg/rms/man/survplot.html) confidence
bands this gives widths proportional to population-scale uncertainty
(~$`2 \times 10^{-4}`$ on the log scale).

The unweighted [`cph()`](https://rdrr.io/pkg/rms/man/cph.html)
`$std.err` (~$`5 \times 10^{-3}`$) reflects sample-scale precision from
$`n \approx 34{,}000`$ observations and $`\sim 4{,}000`$ events, treated
as if they were a simple random sample.

For visualization, `se_type = "greenwood"` produces the most
interpretable confidence bands; `se_type = "lin"` is appropriate for
formal design-based inference.

``` r

# Lin design variance (default) — correct for population inference
h0_lin <- weighted_basehaz(fit_svy, design = sub_design, se_type = "lin")

# Greenwood-weighted — interpretable survplot() confidence bands
h0_gw  <- weighted_basehaz(fit_svy, design = sub_design, se_type = "greenwood")

head(h0_gw)
```

``` r

# SE scale comparison (log H0 scale, late follow-up):
# cph unweighted std.err  ~ 0.005  (sample-scale statistical precision)
# Greenwood-weighted      ~ 0.0002 (population-scale statistical precision)
# Lin design              ~ 1e-6   (PSU-selection uncertainty)
data.frame(
  method    = c("cph unweighted", "Greenwood-weighted", "Lin design"),
  std.err   = c(
    mean(tail(fit_cph$std.err, 5), na.rm = TRUE),
    mean(tail(h0_gw$std.err, 5)),
    mean(tail(h0_lin$std.err, 5))
  )
)
```

``` r

h0_naive <- basehaz(fit_cph, centered = TRUE)

plot(h0_naive$time, h0_naive$hazard, type = "s",
     xlab = "Time (years)", ylab = "Cumulative baseline hazard",
     main = "Weighted vs. unweighted baseline hazard")
lines(h0_gw$time, h0_gw$hazard, type = "s", col = "steelblue")
legend("topleft", c("Unweighted (cph)", "Weighted (svycoxph)"),
       col = c("black", "steelblue"), lty = 1)
```

``` r

# Substitute Greenwood-weighted hazard for survplot() with visible bands
fit_fused <- svycph_set_basehaz(fit_fused, h0_gw)
```

``` r

survplot(fit_fused, GGT = c(20, 50, 100), conf = "bands",
         xlab = "Follow-up (years)", ylab = "Survival",
         label.curves = list(keys = "lines"))
```

------------------------------------------------------------------------

## Step 5: Degrees of freedom correction

`anova.rms()` uses the rank of the contrast matrix for degrees of
freedom. For proper survey inference, F-test df should be based on the
number of PSUs minus the number of strata. This section documents the
correction.

``` r

# svycoxph stores degf.resid = n_PSU - n_strata directly; no manual computation needed
fit_svy$degf.resid   # e.g. 138 for the NHANES 1999-2018 analysis population
fit_fused$svycph_vcov_df  # same value, copied into fused object by svycph_fuse()
```

`anova.rms()` reports chi-square statistics (df = rank of contrast
matrix), not F-statistics. The survey df (138) therefore affects
interpretation rather than the test statistic itself: very large
chi-squares remain informative, but for borderline results
[`regTermTest()`](https://rdrr.io/pkg/survey/man/regTermTest.html)
should be used as a check, as it denominates using survey df and returns
an F-statistic with correct finite- population correction.

``` r

# regTermTest() as a check on borderline spline nonlinearity results
regTermTest(fit_svy, ~ rcs(GGT, 4))    # overall GGT association
regTermTest(fit_svy, ~ rcs(LBXSAL, 4)) # overall albumin association
```

------------------------------------------------------------------------

## Conclusions and current limitations

### What works

The fusion approach is validated end to end on NHANES 1999–2018 data (N
= 34,456 non-statin adults, 3,975 deaths). All three target outputs
function correctly on the fused object:

| Function | Status | Notes |
|----|----|----|
| `anova.rms()` | **Working** | Survey-correct Wald tests with nonlinearity decomposition |
| [`Predict()`](https://rdrr.io/pkg/rms/man/Predict.html) | **Working** | Survey-correct effect displays with CIs |
| `plot.Predict()` / `ggplot.Predict()` | **Working** | Inherits from [`Predict()`](https://rdrr.io/pkg/rms/man/Predict.html) |
| `summary.rms()` | **Working** | Inherits from correct `$var` and `$Design` |
| [`survplot()`](https://rdrr.io/pkg/rms/man/survplot.html) | **Working** | Requires [`svycph_set_basehaz()`](https://dwinsemius.github.io/nhanesR/reference/svycph_set_basehaz.md) first |

### Empirical demonstration of design effects

The NHANES cluster design inflates all Wald statistics in
[`cph()`](https://rdrr.io/pkg/rms/man/cph.html). The magnitude of
over-statement differs by predictor, reflecting how strongly each
variable is geographically clustered within PSUs:

| Predictor           | χ² (fused) | χ² (cph) | Ratio    |
|---------------------|------------|----------|----------|
| GGT (overall)       | 144.2      | 227.9    | 1.58     |
| GGT (nonlinear)     | 58.7       | 90.9     | 1.55     |
| Albumin (overall)   | 162.3      | 251.2    | 1.55     |
| Albumin (nonlinear) | 25.6       | 36.8     | 1.44     |
| Age                 | 3407.7     | 5609.4   | 1.65     |
| Sex                 | 106.0      | 123.1    | 1.16     |
| Race/ethnicity      | **8.6**    | **34.6** | **4.02** |
| BMI                 | 6.6        | 25.8     | 3.90     |

Race/ethnicity and BMI show the largest design effects (~4×), consistent
with their strong geographic clustering. Sex shows the smallest (1.16×),
as it is nearly uniformly distributed across PSUs. Ignoring survey
design would lead to substantial over-confidence for these predictors.

Both GGT and albumin exhibit statistically robust nonlinearity under the
survey-correct tests (GGT nonlinear χ² = 58.7, albumin nonlinear χ² =
25.6, both p \< 0.0001), confirming that linear or categorical treatment
of these biomarkers would misrepresent their mortality relationships.

### When survey weighting is and is not necessary

The empirical design effects in the table above point toward a general
principle with practical consequences for NHANES analysts.

**The intraclass correlation coefficient (ICC)** measures the proportion
of a variable’s total variance that lies *between* PSUs rather than
within them. It is the structural property that determines how much the
cluster design inflates standard errors. The design effect is
approximately $`\text{DEFF} \approx 1 + (m - 1) \cdot \text{ICC}`$,
where $`m`$ is mean PSU size, and is directly estimable as the square of
the observed SE ratio.

Race/ethnicity has a high ICC because people of the same race
predominantly live in the same neighbourhoods and therefore the same
PSUs. When race is the predictor of interest — as in studies of outcome
disparities by race — the cluster design creates substantial
extra-binomial variance in the score contributions, and unweighted
standard errors are materially too small. Survey weighting is not
optional in that setting.

Biochemical analytes measured in blood or urine occupy a different
position. Their values are determined by individual physiology, not
geography. The NHANES sampling probabilities are set by demographic
strata, not by lab values, so conditional on the demographic adjusters
included in the model, the correlation between survey weight and analyte
value is near zero. This is the condition Harrell (2015) identifies for
model-based (unweighted) estimates to be consistent: the sampling
mechanism must be *non-informative* with respect to the variable of
interest, given the covariates in the model. When that condition holds,
the weighted and unweighted coefficient estimates converge and the
design correction provides little benefit for coefficient inference.

The Lin (2000) design variance for the baseline hazard illustrates this
directly: it is negligibly small precisely *because* the model has
absorbed the major sources of geographic clustering through its
covariates. A large Lin variance would indicate residual geographic
heterogeneity not explained by the model — a signal of model
misspecification, not just a reason to weight.

**Efficient screening.** Whether a given analyte warrants the full
fusion machinery can be assessed cheaply before fitting the Cox model:

``` r

library(lme4)
library(performance)

# ICC for each analyte across PSUs — low ICC suggests non-informative sampling
analytes <- c("GGT", "LBXSAL", "TC", "BMI", "RIDAGEYR")
icc_tbl  <- lapply(analytes, function(v) {
  m   <- lmer(as.formula(paste(v, "~ 1 + (1|SDMVPSU)")), data = dat2, REML = TRUE)
  icc <- performance::icc(m)$ICC_adjusted
  data.frame(analyte = v, ICC = round(icc, 4))
})
do.call(rbind, icc_tbl)
```

``` r

# DEFF from design: (design SE / naive SE)^2 for each analyte mean
deff_tbl <- lapply(analytes, function(v) {
  se_design <- SE(svymean(reformulate(v), sub_design))
  se_naive  <- sd(dat2[[v]], na.rm = TRUE) / sqrt(sum(!is.na(dat2[[v]])))
  data.frame(analyte = v, DEFF = round((se_design / se_naive)^2, 3))
})
do.call(rbind, deff_tbl)
```

Analytes with ICC \< 0.02 or DEFF \< 1.1 are unlikely to require survey
weighting for coefficient inference. Those with ICC \> 0.05 or DEFF \>
1.3 should use the full fusion approach. Race/ethnicity and other
demographic variables used in the NHANES sampling design will always
fall in the latter category and should never be analysed with unweighted
standard errors when disparities are the focus.

This screening step — applied across all analytes of interest before
modelling — is itself a useful contribution to NHANES analysis practice,
as it allows analysts to apply the full
[`svycph_fuse()`](https://dwinsemius.github.io/nhanesR/reference/svycph_fuse.md)
workflow selectively where it matters rather than uniformly across all
predictors.

**Implications for prior literature.** The ICC framework offers a more
precise account of where prior NHANES survival analyses are
methodologically vulnerable than a blanket criticism of survey weight
omission. Biochemical analytes measured in blood or urine — including
lipids (TC, LDL-C, HDL-C, triglycerides), liver enzymes (GGT, ALT, AST,
alkaline phosphatase), renal markers (creatinine, albumin), and
nutritional biomarkers — are determined by individual physiology rather
than geography. Their ICC values are expected to be low, making
non-survey-weighted coefficient estimates defensible for these
predictors when demographic adjusters are included in the model. Prior
analyses that omitted survey weighting while studying these analytes may
therefore have produced valid conditional associations despite the
omission.

The more consequential methodological limitations in that literature are
elsewhere: the use of logistic regression on a binary mortality outcome
when follow-up time and censoring information were available, discarding
the entire time dimension of the data; and the discretization of
continuous biomarkers into quantile or tertile categories. The latter is
not merely an aesthetic limitation. For biomarkers with U-shaped
mortality relationships — as observed here for GGT and albumin, and
widely reported for TC — quantile categorization systematically biases
toward the null: observations on the ascending and descending arms of
the relationship fall within the same category and their opposing risk
contributions cancel, attenuating the estimated effect and obscuring the
shape entirely. This bias operates whether or not survey weights are
applied, making the choice of continuous spline modelling the more
consequential methodological decision. These criticisms are
unconditional — they apply regardless of analyte type, sampling design,
or weighting strategy, and they bear directly on the biological
interpretability of reported findings.

### Current limitations

**Confidence band scale.**
[`weighted_basehaz()`](https://dwinsemius.github.io/nhanesR/reference/weighted_basehaz.md)
provides two variance options. The Lin (2000) design variance
(`se_type = "lin"`) is theoretically correct for population inference
but produces nearly invisible bands for NHANES-scale data (~$`10^{-6}`$
on the log scale) because PSU-selection uncertainty is negligible for
rare events. The Greenwood-weighted option (`se_type = "greenwood"`)
gives interpretable band widths (~$`2 \times 10^{-4}`$) at the cost of
reflecting population-scale rather than sample-scale precision. Neither
exactly matches the sample-scale `$std.err` from
[`cph()`](https://rdrr.io/pkg/rms/man/cph.html) (~$`5 \times
10^{-3}`$), which treats the data as a simple random sample. The
three-regime structure — design variance, population-scale statistical
variance, and sample-scale statistical variance — reflects a genuine
open question in the survival analysis literature: no unified variance
estimator simultaneously captures PSU-selection uncertainty and
finite-sample event-count uncertainty for weighted Cox models. Deriving
such an estimator, likely via a joint influence function that propagates
both sources of randomness, represents a natural extension of Lin (2000)
and a direction for future methodological work.

**Bootstrap validation and calibration.**
[`validate()`](https://rdrr.io/pkg/rms/man/validate.html) and
[`calibrate()`](https://rdrr.io/pkg/rms/man/calibrate.html) from `rms`
internally refit the model using
[`cph()`](https://rdrr.io/pkg/rms/man/cph.html), not
[`svycoxph()`](https://rdrr.io/pkg/survey/man/svycoxph.html), so the
survey correction is lost silently during resampling. These functions
should not be used on fused objects without a custom resampling wrapper.

**Singleton PSU strata.** Subsetting NHANES data before creating the
[`svydesign()`](https://rdrr.io/pkg/survey/man/svydesign.html) object
can produce strata with a single PSU, causing
[`svycoxph()`](https://rdrr.io/pkg/survey/man/svycoxph.html) to fail.
The correct approach is to create the design on the full dataset and
subset the design object, as demonstrated in Step 1.

### The nhanesR package

The functions described in this vignette —
[`svycph_fuse()`](https://dwinsemius.github.io/nhanesR/reference/svycph_fuse.md),
[`weighted_basehaz()`](https://dwinsemius.github.io/nhanesR/reference/weighted_basehaz.md),
[`svycph_set_basehaz()`](https://dwinsemius.github.io/nhanesR/reference/svycph_set_basehaz.md),
and the ICC and DEFF screening utilities — are exported components of
the `nhanesR` package. Together with the data infrastructure functions
([`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md),
[`nhanes_harmonize()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_harmonize.md),
[`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md),
[`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md)),
they constitute a complete pipeline from raw NHANES data download
through survey-correct survival analysis within a single R package.

The design intention is that an analyst wishing to study the mortality
relationship of any biochemical analyte measured across NHANES cycles
can: (1) retrieve and harmonize the analyte across cycles using
[`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md)
with automatic CDC-catalog resolution of per-cycle filename changes; (2)
link to NCHS public-use mortality data via
[`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md);
(3) screen the analyte’s ICC to determine whether the full
survey-correction machinery is warranted; and (4) fit a
[`svycph_fuse()`](https://dwinsemius.github.io/nhanesR/reference/svycph_fuse.md)
object that brings both the inferential correctness of
[`svycoxph()`](https://rdrr.io/pkg/survey/man/svycoxph.html) and the
display richness of the `rms` ecosystem to bear on the analysis,
including spline nonlinearity tests, smooth effect plots, and
survey-weighted survival curves.

The complete workflow demonstrated in this vignette — from NHANES
download to [`survplot()`](https://rdrr.io/pkg/rms/man/survplot.html)
with confidence bands — is fully reproducible using only functions in
`nhanesR` and its declared dependencies.

### A broader methodological agenda

The current implementation is presented as a practically useful
approximation: it provides design-correct point estimates and
coefficient inference via the fused object, and interpretable survival
curves via the Greenwood-weighted baseline hazard, but it does not yet
resolve the unified variance problem identified above. The JSS paper
accompanying `nhanesR` documents this approximation honestly and
provides the ICC/DEFF screening framework to guide analysts in deciding
when the approximation is adequate.

A companion paper targeting *Biostatistics* would address the deeper
unsolved problems. The central contribution would be a design-aware REML
(dREML) criterion for penalized Cox regression: modifying the
[`mgcv::gam()`](https://rdrr.io/pkg/mgcv/man/gam.html) smoothing
parameter selection with `family = cox.ph()` to use the survey-corrected
sandwich variance rather than the observed information matrix. This is
the analogue of what @lumley2004 did for
[`svyglm()`](https://rdrr.io/pkg/survey/man/svyglm.html) — adapting the
estimating equations to the cluster design — but extended to the
penalized regression setting where the smoothing parameter governs the
shape of the estimated effect. A dREML-selected 2D tensor product smooth
via `te()` would produce joint hazard ratio surfaces whose confidence
regions properly account for the NHANES cluster design rather than
treating PSU-clustered observations as independent; for race-stratified
surface analyses, this distinction is material. The theory would be
validated against the three-regime SE structure identified here, with a
simulation study varying ICC from 0 to 0.15 to establish the empirical
threshold below which the design correction leaves spline shape
estimates unchanged.

The primary NHANES application — TC × HDL and GGT × albumin joint
mortality surfaces — would showcase a visualization approach not yet
standard in the biomarker-mortality literature. Each figure would
combine three layers: (1) a smooth 2D hazard ratio surface from the
design-correct GAM-Cox; (2) an empirical support envelope from
`Hmisc::perimeter()`, which computes the convex-hull boundary of the
joint observed predictor distribution and, when passed to
`bplot(perim = ...)`, restricts the displayed surface to the region
where the model is not extrapolating; and (3) the observed mortality
events plotted as points within that envelope. This three-layer
construction — smooth surface, bounded by empirical support, annotated
with actual deaths — immediately answers the question of whether the
high-risk regions of the estimated surface correspond to where deaths
actually occurred, and whether those deaths fall within clinically
recognizable covariate ranges. The `mgcv` analogue is
`vis.gam(..., too.far = 0.1)`, which achieves the same masking
automatically from the prediction grid. The event overlay is the novel
element: to our knowledge no published 2D risk surface in the biomarker
literature has overlaid the event locations within the perimeter-bounded
surface, though the information is trivially available from the model’s
response variable. It is a presentation innovation made
straightforwardly available by the
[`perimeter()`](https://rdrr.io/pkg/rms/man/bplot.html) function already
present in `Hmisc`.

------------------------------------------------------------------------

## Session information

``` r

sessionInfo()
```
