# Parse NHANES Linked Mortality Files into data frames

Reads the fixed-width `.dat` files (downloading them first if needed)
and returns a named list of data frames, one per cycle.

## Usage

``` r
nhanes_mortality_parse(cycles = NULL, refresh = FALSE, download = TRUE)
```

## Arguments

- cycles:

  Character vector of cycle labels. Defaults to all available.

- refresh:

  Logical. Re-parse even if a cached RDS exists? Default `FALSE`.

- download:

  Logical. Auto-download missing `.dat` files? Default `TRUE`.

## Value

A named list of data frames. Each data frame contains:

- SEQN:

  Respondent sequence number (join key to NHANES data).

- ELIGSTAT:

  Eligibility: 1=eligible; 2=under 18; 3=insufficient data.

- MORTSTAT:

  Vital status: 0=assumed alive; 1=assumed deceased.

- UCOD_LEADING:

  Underlying cause of death (11-category ICD-10 recode).

- DIABETES:

  Diabetes mentioned on death certificate (1=yes).

- HYPERTEN:

  Hypertension mentioned on death certificate (1=yes).

- PERMTH_INT:

  Months of follow-up from interview date.

- PERMTH_EXM:

  Months of follow-up from examination date.

## Details

Variable labels are attached as the `"label"` attribute on each column,
following the `haven`/`labelled` convention.

## Note

For select records, `PERMTH_INT`, `PERMTH_EXM`, and `UCOD_LEADING`
contain **synthetic (perturbed) values** introduced by CDC to reduce
re-identification risk. `MORTSTAT` and `ELIGSTAT` are not perturbed.

## Examples

``` r
if (FALSE) { # \dontrun{
lmf <- nhanes_mortality_parse(c("2015-2016", "2017-2018"))
lmf[["2015-2016"]]
} # }
```
