# Substitute weighted baseline hazard into a fused cph object

Replaces the baseline hazard estimate in a fused `cph` object with the
survey-weighted version from
[`weighted_basehaz()`](https://dwinsemius.github.io/nhanesR/reference/weighted_basehaz.md),
enabling `survplot()` to produce design-correct survival curves.

## Usage

``` r
svycph_set_basehaz(fit_fused, h0)
```

## Arguments

- fit_fused:

  A `svycph_fused` object from
  [`svycph_fuse()`](https://dwinsemius.github.io/nhanesR/reference/svycph_fuse.md).

- h0:

  A data frame returned by
  [`weighted_basehaz()`](https://dwinsemius.github.io/nhanesR/reference/weighted_basehaz.md).

## Value

The modified fused object with weighted baseline hazard.

## See also

[`svycph_fuse`](https://dwinsemius.github.io/nhanesR/reference/svycph_fuse.md),
[`weighted_basehaz`](https://dwinsemius.github.io/nhanesR/reference/weighted_basehaz.md)
