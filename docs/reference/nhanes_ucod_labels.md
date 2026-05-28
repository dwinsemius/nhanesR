# Lookup table for UCOD_LEADING cause-of-death codes

Returns the ICD-10 recode table used in the public-use LMF
`UCOD_LEADING` variable, including code, plain-language label, and
ICD-10 chapter ranges.

## Usage

``` r
nhanes_ucod_labels()
```

## Value

A data frame with columns `code`, `label`, `icd10_range`.

## Examples

``` r
nhanes_ucod_labels()
#>    code                                        label             icd10_range
#> 1   001                            Diseases of heart I00-I09,I11,I13,I20-I51
#> 2   002                          Malignant neoplasms                 C00-C97
#> 3   003            Chronic lower respiratory disease                 J40-J47
#> 4   004           Accidents (unintentional injuries)         V01-X59,Y85-Y86
#> 5   005                      Cerebrovascular disease                 I60-I69
#> 6   006                          Alzheimer's disease                     G30
#> 7   007                            Diabetes mellitus                 E10-E14
#> 8   008                      Influenza and pneumonia                 J09-J18
#> 9   009 Nephritis, nephrotic syndrome, and nephrosis N00-N07,N17-N19,N25-N27
#> 10  010                             All other causes               All other
#> 11  011                                      Suicide       U03,X60-X84,Y87.0
```
