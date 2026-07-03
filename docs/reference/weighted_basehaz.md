# Compute survey-weighted cumulative baseline hazard with variance

Implements the weighted Breslow estimator and its linearization-based
variance following Lin (2000). The point estimate weights each event's
contribution by its survey weight; the variance uses the influence
function of the weighted estimator combined with the survey design's
stratified cluster structure.

## Usage

``` r
weighted_basehaz(
  fit_svy,
  design,
  centered = TRUE,
  se_type = c("lin", "greenwood")
)
```

## Arguments

- fit_svy:

  A fitted `svycoxph` object.

- design:

  The `svydesign` object used to fit `fit_svy`.

- centered:

  Logical. If `TRUE` (default), the baseline hazard corresponds to a
  person at the weighted mean of each covariate, matching the
  `centered=TRUE` default of
  [`survival::basehaz()`](https://rdrr.io/pkg/survival/man/basehaz.html).

- se_type:

  Character. Which variance estimator to use for `std.err`:

  `"lin"`

  :   (default) Lin (2000) design-based linearization variance. Measures
      sensitivity to PSU selection; appropriate for population-level
      design inference. Produces very small SEs for large-population
      surveys like NHANES.

  `"greenwood"`

  :   Survey-weighted Greenwood formula: \\\sum\_{t_k \leq t} n^w(t_k) /
      \[Y^w(t_k)\]^2\\. Measures statistical precision from the weighted
      event count; gives confidence bands of interpretable width for
      `survplot()`.

## Value

A data frame with columns:

- time:

  Event times.

- hazard:

  Weighted cumulative baseline hazard H_0(t).

- surv:

  Baseline survival exp(-H_0(t)).

- se_H0:

  Standard error of H_0(t) on the hazard scale.

- std.err:

  Standard error of log(H_0(t)), for direct substitution into the
  `$std.err` slot of a fused `cph` object. Computed from `se_H0` via the
  delta method: SE(log H) = SE(H)/H.

## Details

The weighted Breslow increment at each event time \\t_k\\ is:
\$\$d\hat{H}\_0^w(t_k) = \frac{\sum\_{i: t_i = t_k, \delta_i=1} w_i}
{\sum\_{j \in \mathcal{R}(t_k)} w_j \exp(\mathbf{X}\_j^\top
\hat{\beta})}\$\$

The influence function of \\d\hat{H}\_0^w(t_k)\\ for observation \\i\\
is (Lin 2000, eq. 2.3): \$\$\phi_i(t_k) = \frac{I(t_i = t_k,\\ \delta_i
= 1)}{Y^w(t_k)} - \frac{n^w(t_k)}{\[Y^w(t_k)\]^2}\\ I(t_i \geq t_k)\\
\exp(\mathbf{X}\_i^\top\hat{\beta})\$\$

where \\Y^w(t_k) = \sum\_{j \in \mathcal{R}(t_k)} w_j
\exp(\mathbf{X}\_j^\top\hat{\beta})\\ and \\n^w(t_k) = \sum\_{i:
t_i=t_k, \delta_i=1} w_i\\.

The cumulative influence \\\Phi_i(t) = \sum\_{t_k \leq t} \phi_i(t_k)\\
is used to construct the linearization variance estimate (Lin 2000, eq.
2.4): \$\$\widehat{\mathrm{Var}}(\hat{H}\_0^w(t)) = \sum_h
\frac{n_h}{n_h - 1} \sum\_{\alpha \in h} \left(e\_{h\alpha}(t) -
\bar{e}\_h(t)\right)^2\$\$

where \\e\_{h\alpha}(t) = \sum\_{i \in \text{PSU}\\\alpha} \Phi_i(t)\\
is the PSU-level total of influence functions within stratum \\h\\.

Note: this variance conditions on \\\hat{\beta}\\ and does not propagate
uncertainty from coefficient estimation. For large samples this
contribution is negligible relative to the design variance.

## Choosing `se_type`

For NHANES-scale populations the Lin design variance is orders of
magnitude smaller than the Greenwood-weighted variance because the
former captures only PSU-selection uncertainty (very small for rare
events), while the latter captures statistical uncertainty from the
weighted event count. The ratio is approximately proportional to the
square root of the mean survey weight. Use `se_type = "greenwood"` when
the goal is `survplot()` confidence bands that convey statistical
reliability; use `"lin"` when the goal is design-consistent variance for
formal population inference.

## References

Lin, D.Y. (2000). On fitting Cox's proportional hazards models to survey
data. *Biometrika*, 87(1), 37–47.

## See also

[`svycph_fuse`](https://dwinsemius.github.io/nhanesR/reference/svycph_fuse.md),
[`svycph_set_basehaz`](https://dwinsemius.github.io/nhanesR/reference/svycph_set_basehaz.md)
