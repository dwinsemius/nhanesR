# List the NHANES III data files and their CDC addresses

NHANES III (1988-1994) predates the per-cycle XPT files of continuous
NHANES. Its public-use data are a few large fixed-width `.dat` files,
each with a SAS program (`.sas`) that gives the column positions and
variable labels, and a codebook PDF. This lists the files
[`nhanes3_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_download.md),
[`nhanes3_layout()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_layout.md)
and
[`nhanes3_read()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_read.md)
know by name.

## Usage

``` r
nhanes3_files()
```

## Value

A data frame with `file` (the name to pass to the other functions),
`folder` on the CDC server, a `description`, and the `dat_url`,
`sas_url` and `codebook_url` of each file.

## See also

[`nhanes3_layout()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_layout.md)
to see what is in a file,
[`nhanes3_read()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_read.md)
to read chosen columns. The `nhanes-iii` vignette walks through the
whole workflow.

## Examples

``` r
nhanes3_files()
#>    file folder
#> 1  exam     1a
#> 2 adult     1a
#> 3 youth     1a
#> 4   lab     1a
#> 5  lab2     2a
#>                                                                                    description
#> 1 Examination file (body measures such as height, weight and waist, and other exam components)
#> 2                                                       Adult questionnaire (ages 17 and over)
#> 3                                                                          Youth questionnaire
#> 4              First laboratory file (its COP serum cotinine column is blank for every record)
#> 5                                                 Second laboratory file (serum cotinine, COP)
#>                                               dat_url
#> 1  https://wwwn.cdc.gov/nchs/data/nhanes3/1a/exam.dat
#> 2 https://wwwn.cdc.gov/nchs/data/nhanes3/1a/adult.dat
#> 3 https://wwwn.cdc.gov/nchs/data/nhanes3/1a/youth.dat
#> 4   https://wwwn.cdc.gov/nchs/data/nhanes3/1a/lab.dat
#> 5  https://wwwn.cdc.gov/nchs/data/nhanes3/2a/lab2.dat
#>                                               sas_url
#> 1  https://wwwn.cdc.gov/nchs/data/nhanes3/1a/exam.sas
#> 2 https://wwwn.cdc.gov/nchs/data/nhanes3/1a/adult.sas
#> 3 https://wwwn.cdc.gov/nchs/data/nhanes3/1a/youth.sas
#> 4   https://wwwn.cdc.gov/nchs/data/nhanes3/1a/lab.sas
#> 5  https://wwwn.cdc.gov/nchs/data/nhanes3/2a/lab2.sas
#>                                              codebook_url
#> 1  https://wwwn.cdc.gov/nchs/data/nhanes3/1a/exam-acc.pdf
#> 2 https://wwwn.cdc.gov/nchs/data/nhanes3/1a/adult-acc.pdf
#> 3 https://wwwn.cdc.gov/nchs/data/nhanes3/1a/youth-acc.pdf
#> 4   https://wwwn.cdc.gov/nchs/data/nhanes3/1a/lab-acc.pdf
#> 5  https://wwwn.cdc.gov/nchs/data/nhanes3/2a/lab2-acc.pdf
```
