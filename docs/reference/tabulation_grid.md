# Pivot a mortality tabulation into a two-way grid

Extracts one statistic from a
[`mortality_tabulation()`](https://dwinsemius.github.io/nhanesR/reference/mortality_tabulation.md)
result as a matrix with one covariate down the rows and another across
the columns. The margins (`"All"`) are included as the last row and
column.

## Usage

``` r
tabulation_grid(tab, rows, cols, value = "rate", fixed = NULL)
```

## Arguments

- tab:

  Output of
  [`mortality_tabulation()`](https://dwinsemius.github.io/nhanesR/reference/mortality_tabulation.md)
  with margins.

- rows, cols:

  Names of the covariates for the rows and columns.

- value:

  The column to tabulate: `"rate"` (default), `"deaths"`, `"pyears"`,
  `"n"`, `"oe"`, and so on.

- fixed:

  Optional named list pinning any further covariates to one level (they
  default to `"All"`), for example `list(sex = "F")` to tabulate within
  women when `tab` has three covariates.

## Value

A matrix with `rows` levels (plus `"All"`) by `cols` levels (plus
`"All"`).

## See also

[`mortality_tabulation()`](https://dwinsemius.github.io/nhanesR/reference/mortality_tabulation.md)
