# Resolve duplicate unit columns, keeping the preferred unit system

Uses label attributes rather than variable name patterns because CDC
naming is inconsistent (e.g. LBXTC/LBDTCSI, LBXHDD/LBDHDDSI). Strips the
unit token from each label and drops the unwanted system's columns when
both systems are present for the same measurement.

## Usage

``` r
.nhanes_resolve_unit_duplicates(df, units = "conventional")
```
