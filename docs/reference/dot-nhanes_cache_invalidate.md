# Invalidate a cached RDS and its hash sidecar

Removes both the RDS and its `.md5` sidecar if they exist. Called when a
source file is refreshed.

## Usage

``` r
.nhanes_cache_invalidate(rds_path)
```
