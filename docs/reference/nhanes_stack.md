# Stack NHANES data across multiple cycles

Row-binds the same component across multiple cycles, enforcing that the
`cycle` column is present and handling variable name changes across
cycles.

## Usage

``` r
nhanes_stack(..., fill = TRUE)
```

## Arguments

- ...:

  Named or unnamed data frames, each representing one cycle's data for
  the same component.

- fill:

  Logical. If `TRUE` (default), columns present in some but not all
  cycles are filled with `NA` in cycles where they are absent. If
  `FALSE`, only columns common to all cycles are retained.

## Value

A single data frame with all cycles stacked. A `cycle` column is always
included.

## Examples

``` r
if (FALSE) { # \dontrun{
demos <- nhanes_download("DEMO", c("2013-2014", "2015-2016", "2017-2018"))
stacked <- nhanes_stack(demos)
} # }
```
