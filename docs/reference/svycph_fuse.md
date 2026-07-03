# Fuse svycoxph and cph objects for rms ecosystem compatibility

Takes a fitted `cph` object and a fitted `svycoxph` object with the same
formula, and returns a modified `cph`-class object with survey-correct
coefficients and variance-covariance matrix while preserving the `rms`
`$Design` structure needed for `anova.rms()`, `Predict()`,
`summary.rms()`, and related generics.

## Usage

``` r
svycph_fuse(fit_cph, fit_svy)
```

## Arguments

- fit_cph:

  A `cph` object fitted with `x=TRUE, y=TRUE, surv=TRUE`.

- fit_svy:

  A `svycoxph` object fitted with the same formula and data.

## Value

A modified `cph` object with survey-correct inference. The `$var` slot
contains the sandwich variance-covariance matrix from `fit_svy`;
`$coefficients` contains the weighted partial likelihood estimates. The
`$Design` and all structural slots are preserved from `fit_cph`.

## Details

`anova.rms()` constructs Wald tests as \\(L\beta)^\top (LVL^\top)^{-1}
(L\beta)\\ where \\L\\ is a contrast matrix derived from `$Design` and
\\V\\ is `$var`. Substituting the survey-corrected \\V\\ from `svycoxph`
yields design-correct Wald statistics while preserving the rms
term-identification machinery.

Degrees of freedom in `anova.rms()` are based on contrast matrix rank,
not survey PSU count. For fully correct F-test df, use
[`survey::regTermTest()`](https://rdrr.io/pkg/survey/man/regTermTest.html)
directly on `fit_svy`.

## References

Binder, D.A. (1992). Fitting Cox's proportional hazards models from
survey data. *Biometrika*, 79(1), 139–147.

Lin, D.Y. (2000). On fitting Cox's proportional hazards models to survey
data. *Biometrika*, 87(1), 37–47.

## See also

[`weighted_basehaz`](https://dwinsemius.github.io/nhanesR/reference/weighted_basehaz.md),
[`svycph_set_basehaz`](https://dwinsemius.github.io/nhanesR/reference/svycph_set_basehaz.md)
