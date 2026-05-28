# Package index

## Discovery

Find available cycles and files

- [`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md)
  : List available NHANES cycles
- [`nhanes_manifest()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md)
  : List available files for a NHANES cycle and component

## Variable search

Search the CDC variable catalog by keyword

- [`nhanes_search_variables()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md)
  : Search NHANES variables by keyword
- [`nhanes_variable_map()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_variable_map.md)
  : Build a per-cycle variable map for an analyte

## Download

Download and cache NHANES XPT files

- [`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md)
  : Download and cache NHANES XPT data files
- [`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md)
  : Download NHANES files for an analyte using the CDC variable catalog

## Harmonize, stack, and merge

Combine data across cycles and components

- [`nhanes_harmonize()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_harmonize.md)
  : Harmonize variable names across NHANES cycles and stack into one
  data frame
- [`nhanes_stack()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_stack.md)
  : Stack NHANES data across multiple cycles
- [`nhanes_merge()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_merge.md)
  : Merge NHANES component data frames by SEQN

## Mortality linkage

Link NCHS Public-Use Linked Mortality Files

- [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md)
  : Link mortality data onto an NHANES analytic dataset
- [`nhanes_mortality_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_download.md)
  : Download NHANES Public-Use Linked Mortality Files
- [`nhanes_mortality_parse()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_parse.md)
  : Parse NHANES Linked Mortality Files into data frames
- [`nhanes_lmf_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_lmf_cycles.md)
  : List NHANES cycles with a public-use LMF

## Survival analysis

Prepare and summarise survival datasets

- [`nhanes_survival_prep()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_survival_prep.md)
  : Prepare an NHANES-LMF dataset for survival analysis
- [`nhanes_followup_summary()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_followup_summary.md)
  : Summarise mortality follow-up by cycle
- [`nhanes_ucod_labels()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_ucod_labels.md)
  : Lookup table for UCOD_LEADING cause-of-death codes

## Cache management

- [`nhanes_cache_dir()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cache_dir.md)
  : Get or set the nhanesR local cache directory
