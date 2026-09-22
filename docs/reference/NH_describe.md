# NHANES-annotated variable descriptions

Attaches CDC plain-language descriptions as column labels via
[`NH_label`](https://dwinsemius.github.io/nhanesR/reference/NH_label.md),
then calls [`describe`](https://rdrr.io/pkg/Hmisc/man/describe.html).
This is a convenience wrapper; for repeated use prefer
[`NH_label()`](https://dwinsemius.github.io/nhanesR/reference/NH_label.md)
once so that labels persist across all subsequent Hmisc operations.

## Usage

``` r
NH_describe(x, descriptions = NULL, all_weights = FALSE, ...)
```

## Arguments

- x:

  A data frame of NHANES data, typically from
  [`nhanes_download_analyte`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md).

- descriptions:

  Optional lookup passed through to
  [`NH_label`](https://dwinsemius.github.io/nhanesR/reference/NH_label.md).
  See that function for accepted forms.

- all_weights:

  Logical. If `FALSE` (default), columns whose names match `REP[0-9]+$`
  (balanced repeated replication weights such as `WTMREP01`–`WTMREP52`)
  are excluded from the output. Set to `TRUE` to include all weight
  columns.

- ...:

  Additional arguments passed to
  [`describe`](https://rdrr.io/pkg/Hmisc/man/describe.html).

## Value

An object of class `"describe"` with CDC descriptions embedded as
variable labels.

## Details

Replicate weights (variables matching `REP[0-9]+$`, e.g.
`WTMREP01`–`WTMREP52` and `WTIREP01`–`WTIREP52`) are suppressed by
default because they appear in NHANES DEMO files but are not needed for
Taylor-series linearization variance estimation, which is the standard
approach for NHANES analysis. Set `all_weights = TRUE` to include them.

## See also

[`NH_label`](https://dwinsemius.github.io/nhanesR/reference/NH_label.md)
to attach labels to a data frame for persistent use;
[`describe`](https://rdrr.io/pkg/Hmisc/man/describe.html) for the
underlying engine.

## Examples

``` r
# \donttest{
tc <- nhanes_download_analyte("total cholesterol", "2015-2016")
#> Created nhanesR cache directory:
#> /var/folders/68/vh2f8kzn09j8954r6q9100yh0000gn/T//Rtmpu1Rx20/nhanesR
#> Fetching variable catalog for Laboratory from CDC...
#> Found 6 unique variables matching "total cholesterol".
#> Warning: Both "2017-2018" and "2017-2020" are present. The 2017-2018 participants are
#> included in the 2017-2020 pandemic-adjusted file -- use one or the other in
#> pooled analyses to avoid double-counting.
#> ℹ Downloading TCHOL_I 2015-2016
#> ✔ Downloading TCHOL_I 2015-2016 [357ms]
#> 
invisible(NH_describe(tc))

# Include replicate weights in the output
demo_list <- nhanes_download("DEMO", nhanes_cycles()[1:10, "cycle"])
#> Downloading DEMO for 1999-2000
#> ℹ Downloading DEMO 1999-2000
#> ✔ Downloading DEMO 1999-2000 [1.7s]
#> 
#> Downloading DEMO for 2001-2002
#> ℹ Downloading DEMO 2001-2002
#> ✔ Downloading DEMO 2001-2002 [630ms]
#> 
#> Downloading DEMO for 2003-2004
#> ℹ Downloading DEMO 2003-2004
#> ✔ Downloading DEMO 2003-2004 [1.2s]
#> 
#> Downloading DEMO for 2005-2006
#> ℹ Downloading DEMO 2005-2006
#> ✔ Downloading DEMO 2005-2006 [517ms]
#> 
#> Downloading DEMO for 2007-2008
#> ℹ Downloading DEMO 2007-2008
#> ✔ Downloading DEMO 2007-2008 [417ms]
#> 
#> Downloading DEMO for 2009-2010
#> ℹ Downloading DEMO 2009-2010
#> ✔ Downloading DEMO 2009-2010 [723ms]
#> 
#> Downloading DEMO for 2011-2012
#> ℹ Downloading DEMO 2011-2012
#> ✔ Downloading DEMO 2011-2012 [881ms]
#> 
#> Downloading DEMO for 2013-2014
#> ℹ Downloading DEMO 2013-2014
#> ✔ Downloading DEMO 2013-2014 [800ms]
#> 
#> Downloading DEMO for 2015-2016
#> ℹ Downloading DEMO 2015-2016
#> ✔ Downloading DEMO 2015-2016 [815ms]
#> 
#> Downloading DEMO for 2017-2018
#> ℹ Downloading DEMO 2017-2018
#> ✔ Downloading DEMO 2017-2018 [1.1s]
#> 
demo <- nhanes_stack(demo_list)
#> Stacked 101316 rows across 10 cycles: "1999-2000", "2001-2002", "2003-2004",
#> "2005-2006", "2007-2008", "2009-2010", "2011-2012", "2013-2014", "2015-2016",
#> and "2017-2018"
invisible(NH_describe(demo, all_weights = TRUE))

# Supply descriptions from a prior nhanes_search_variables() call
vars <- nhanes_search_variables("cholesterol")
#> Fetching variable catalog for Demographics from CDC...
#> Fetching variable catalog for Dietary from CDC...
#> Fetching variable catalog for Examination from CDC...
#> Fetching variable catalog for Questionnaire from CDC...
#> Found 74 unique variables matching "cholesterol".
invisible(NH_describe(tc, descriptions = vars))
# }
```
