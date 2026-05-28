# Build the CDC URL for an NHANES XPT data file

Build the CDC URL for an NHANES XPT data file

## Usage

``` r
.nhanes_xpt_url(file_code, cycle, suffix = NULL)
```

## Arguments

- file_code:

  Character. The NHANES file code without suffix or extension (e.g.
  "DEMO", "BPX", "TRIGLY").

- cycle:

  Character. A cycle string from
  [`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md)
  (e.g. "2015-2016").

- suffix:

  Character. Cycle letter suffix (e.g. "\_I"). If `NULL`, looked up
  automatically from the internal cycle registry.

## Value

A character URL.
