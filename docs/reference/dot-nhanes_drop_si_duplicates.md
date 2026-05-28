# Drop SI-unit columns when a conventional-unit counterpart exists

Uses label attributes rather than variable name patterns because CDC
naming is inconsistent (e.g. LBXTC / LBDTCSI, LBXHDD / LBDHDDSI). Strips
the unit token from each label and drops SI columns whose base
description matches any conventional-unit column in the same data frame.

## Usage

``` r
.nhanes_drop_si_duplicates(df)
```
