# Check whether a cached RDS file is present and hash-validated

Returns `TRUE` if the RDS exists and its MD5 matches the sidecar.
Returns `FALSE` if either file is missing or the hash does not match,
indicating the cache should be regenerated.

## Usage

``` r
.nhanes_cache_valid(rds_path)
```
