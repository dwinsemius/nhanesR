# List available NHANES cycles

Returns a data frame of all NHANES cycles known to nhanesR, including
metadata about survey weights, pandemic adjustment status, and mortality
linkage availability.

## Usage

``` r
nhanes_cycles(include_iii = FALSE)
```

## Arguments

- include_iii:

  Logical. Include NHANES III (1988-1994)? Default `FALSE` because its
  file naming conventions differ from continuous NHANES.

## Value

A tibble with one row per cycle and columns:

- cycle:

  Character. Cycle label (e.g. `"2015-2016"`).

- begin_year, end_year:

  Integer. Survey years.

- suffix:

  Character. Letter suffix appended to file codes.

- wt_mec_2yr:

  Character. 2-year MEC exam weight variable name.

- wt_int_2yr:

  Character. 2-year interview weight variable name.

- wt_mec_4yr:

  Character. 4-year combined weight, where available.

- wt_prepan:

  Character. Pre-pandemic weight for 2017-2020 cycle.

- pandemic_adj:

  Logical. Was this cycle pandemic-adjusted?

- has_lmf_public:

  Logical. Is a public-use LMF available?

- censor_date:

  Character. Mortality follow-up censor date.

## Examples

``` r
nhanes_cycles()
#>        cycle begin_year end_year  url_path suffix wt_mec_2yr wt_int_2yr
#> 1  1999-2000       1999     2000 1999-2000          WTMEC2YR   WTINT2YR
#> 2  2001-2002       2001     2002 2001-2002     _B   WTMEC2YR   WTINT2YR
#> 3  2003-2004       2003     2004 2003-2004     _C   WTMEC2YR   WTINT2YR
#> 4  2005-2006       2005     2006 2005-2006     _D   WTMEC2YR   WTINT2YR
#> 5  2007-2008       2007     2008 2007-2008     _E   WTMEC2YR   WTINT2YR
#> 6  2009-2010       2009     2010 2009-2010     _F   WTMEC2YR   WTINT2YR
#> 7  2011-2012       2011     2012 2011-2012     _G   WTMEC2YR   WTINT2YR
#> 8  2013-2014       2013     2014 2013-2014     _H   WTMEC2YR   WTINT2YR
#> 9  2015-2016       2015     2016 2015-2016     _I   WTMEC2YR   WTINT2YR
#> 10 2017-2018       2017     2018 2017-2018     _J   WTMEC2YR   WTINT2YR
#> 11 2017-2020       2017     2020 2017-2020     _P       <NA>       <NA>
#>    wt_mec_4yr wt_prepan pandemic_adj has_lmf_public lmf_vintage censor_date
#> 1        <NA>      <NA>        FALSE           TRUE        2019  2019-12-31
#> 2    WTMEC4YR      <NA>        FALSE           TRUE        2019  2019-12-31
#> 3        <NA>      <NA>        FALSE           TRUE        2019  2019-12-31
#> 4    WTMEC4YR      <NA>        FALSE           TRUE        2019  2019-12-31
#> 5        <NA>      <NA>        FALSE           TRUE        2019  2019-12-31
#> 6    WTMEC4YR      <NA>        FALSE           TRUE        2019  2019-12-31
#> 7        <NA>      <NA>        FALSE           TRUE        2019  2019-12-31
#> 8    WTMEC4YR      <NA>        FALSE           TRUE        2019  2019-12-31
#> 9        <NA>      <NA>        FALSE           TRUE        2019  2019-12-31
#> 10       <NA>      <NA>        FALSE           TRUE        2019  2019-12-31
#> 11       <NA>  WTMECPRP         TRUE           TRUE        2019  2019-12-31
nhanes_cycles(include_iii = TRUE)
#>        cycle begin_year end_year  url_path suffix wt_mec_2yr wt_int_2yr
#> 1  1988-1994       1988     1994   nhanes3              <NA>       <NA>
#> 2  1999-2000       1999     2000 1999-2000          WTMEC2YR   WTINT2YR
#> 3  2001-2002       2001     2002 2001-2002     _B   WTMEC2YR   WTINT2YR
#> 4  2003-2004       2003     2004 2003-2004     _C   WTMEC2YR   WTINT2YR
#> 5  2005-2006       2005     2006 2005-2006     _D   WTMEC2YR   WTINT2YR
#> 6  2007-2008       2007     2008 2007-2008     _E   WTMEC2YR   WTINT2YR
#> 7  2009-2010       2009     2010 2009-2010     _F   WTMEC2YR   WTINT2YR
#> 8  2011-2012       2011     2012 2011-2012     _G   WTMEC2YR   WTINT2YR
#> 9  2013-2014       2013     2014 2013-2014     _H   WTMEC2YR   WTINT2YR
#> 10 2015-2016       2015     2016 2015-2016     _I   WTMEC2YR   WTINT2YR
#> 11 2017-2018       2017     2018 2017-2018     _J   WTMEC2YR   WTINT2YR
#> 12 2017-2020       2017     2020 2017-2020     _P       <NA>       <NA>
#>    wt_mec_4yr wt_prepan pandemic_adj has_lmf_public lmf_vintage censor_date
#> 1        <NA>      <NA>        FALSE           TRUE        2019  2019-12-31
#> 2        <NA>      <NA>        FALSE           TRUE        2019  2019-12-31
#> 3    WTMEC4YR      <NA>        FALSE           TRUE        2019  2019-12-31
#> 4        <NA>      <NA>        FALSE           TRUE        2019  2019-12-31
#> 5    WTMEC4YR      <NA>        FALSE           TRUE        2019  2019-12-31
#> 6        <NA>      <NA>        FALSE           TRUE        2019  2019-12-31
#> 7    WTMEC4YR      <NA>        FALSE           TRUE        2019  2019-12-31
#> 8        <NA>      <NA>        FALSE           TRUE        2019  2019-12-31
#> 9    WTMEC4YR      <NA>        FALSE           TRUE        2019  2019-12-31
#> 10       <NA>      <NA>        FALSE           TRUE        2019  2019-12-31
#> 11       <NA>      <NA>        FALSE           TRUE        2019  2019-12-31
#> 12       <NA>  WTMECPRP         TRUE           TRUE        2019  2019-12-31
```
