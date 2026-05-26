# nhanesR

Download, parse, and analyze NHANES data with mortality linkage.

## Overview

`nhanesR` provides tools for working with [NHANES](https://www.cdc.gov/nchs/nhanes/) (National Health and Nutrition Examination Survey) public-use data files and the NCHS Public-Use Linked Mortality Files (LMF).

- Download and cache XPT component files by cycle
- Browse available files via the CDC data catalog
- Merge components by SEQN with survey-design guidance
- Stack data across multiple cycles
- Download, parse, and link mortality follow-up data (through December 31, 2019)
- Prepare datasets for survival analysis with `survey` and `survival`

## Installation

```r
# install.packages("remotes")
remotes::install_github("dwinsemius/nhanesR")
```

## Quick start

```r
library(nhanesR)

# Download DEMO and lab data for two cycles
demo  <- nhanes_download("DEMO",  c("2013-2014", "2015-2016"))
trigly <- nhanes_download("TRIGLY", c("2013-2014", "2015-2016"))

# Stack and merge
demo_stacked  <- nhanes_stack(demo)
trigly_stacked <- nhanes_stack(trigly)
analytic <- nhanes_merge(demo_stacked, trigly_stacked, by = c("SEQN", "cycle"))

# Link mortality
analytic_mort <- nhanes_mortality_link(analytic)

# Prep for survival analysis
surv_data <- nhanes_survival_prep(analytic_mort, origin = "exam",
                                  time_unit = "years", weight_var = "WTMEC2YR")
```

## Acknowledgements

Developed with assistance from [Claude Code](https://claude.ai/code) (Anthropic).
