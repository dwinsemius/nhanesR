# Attach CDC variable descriptions as Hmisc-style labels

Looks up the plain-language CDC description for each column in a NHANES
data frame and stores it as an `"label"` attribute on the column. Hmisc
reads these attributes automatically in
[`describe`](https://rdrr.io/pkg/Hmisc/man/describe.html),
`Hmisc::summary()`,
[`Hmisc::html()`](https://rdrr.io/pkg/Hmisc/man/html.html), and other
label-aware functions, so labelling once makes descriptions available
everywhere.

## Usage

``` r
NH_label(x, descriptions = NULL)
```

## Arguments

- x:

  A data frame of NHANES data, typically from
  [`nhanes_download_analyte`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md).

- descriptions:

  Optional lookup for variable descriptions. May be:

  - `NULL` (default): descriptions are loaded from the locally cached
    variable catalog. Run any
    [`nhanes_search_variables`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md)
    call first to populate the cache.

  - A `data.frame` with columns `variable_name` and `variable_desc`,
    such as the output of
    [`nhanes_search_variables`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md).

  - A named character vector mapping variable names to descriptions.

## Value

`x` with `"label"` attributes set on each column that could be matched
to a CDC description. Columns with no catalog match are returned
unchanged.

## See also

[`NH_describe`](https://dwinsemius.github.io/nhanesR/reference/NH_describe.md)
for a one-step labelled describe;
[`nhanes_search_variables`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md)
to browse the variable catalog;
[`label`](https://rdrr.io/pkg/Hmisc/man/label.html) for the Hmisc label
convention.

## Examples

``` r
# \donttest{
tc <- nhanes_download_analyte("total cholesterol", "2015-2016")
#> Found 6 unique variables matching "total cholesterol".
#> Warning: Both "2017-2018" and "2017-2020" are present. The 2017-2018 participants are
#> included in the 2017-2020 pandemic-adjusted file -- use one or the other in
#> pooled analyses to avoid double-counting.
#> Loading cached TCHOL_I for 2015-2016
tc <- NH_label(tc)

# CDC descriptions now appear in all Hmisc label-aware output
invisible(Hmisc::describe(tc))
# }
```
