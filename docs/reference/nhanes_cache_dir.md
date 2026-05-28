# Get or set the nhanesR local cache directory

nhanesR stores downloaded and parsed NHANES files in a local cache to
avoid redundant downloads. By default the cache is placed in the
standard user data directory for your operating system. Use this
function to view or change the location.

## Usage

``` r
nhanes_cache_dir(path = NULL, create = TRUE)
```

## Arguments

- path:

  Optional character. New path to use as the cache directory. If `NULL`,
  returns the current setting without changing it.

- create:

  Logical. If `TRUE` (default), create the directory if it does not
  exist.

## Value

The current (or newly set) cache directory path, invisibly.

## Examples

``` r
# View current cache location
nhanes_cache_dir()
#> [1] "/Users/dwinsemius/Library/Application Support/nhanesR"

# Change to a custom location
nhanes_cache_dir("~/my_nhanes_cache")
#> [1] "/Users/dwinsemius/my_nhanes_cache"
```
