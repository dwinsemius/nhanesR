# Get or set the nhanesR local cache directory

nhanesR stores downloaded and parsed NHANES files in a local cache to
avoid redundant downloads. By default the cache is placed in the
standard user data directory for your operating system (see below). Use
this function to view or change the location for the current session, or
set it permanently in your `.Rprofile`.

## Usage

``` r
nhanes_cache_dir(path = NULL, create = TRUE)
```

## Arguments

- path:

  Optional character. New path to use as the cache directory for the
  current session. If `NULL`, returns the current setting without
  changing it.

- create:

  Logical. If `TRUE` (default), create the directory if it does not
  exist.

## Value

The current (or newly set) cache directory path, invisibly.

## Details

### Package options

Three options control nhanesR behaviour. Set any of them in your
`.Rprofile` to make the change permanent across sessions; changes made
during a session (via `nhanes_cache_dir()` or
[`options()`](https://rdrr.io/r/base/options.html) directly) last only
until the session ends.

|  |  |  |
|----|----|----|
| Option | Default | Purpose |
| `nhanesR.cache_dir` | OS user-data dir (see below) | Root directory for all cached files |
| `nhanesR.verbose` | `TRUE` | Print progress messages during downloads |
| `nhanesR.timeout` | `120L` | HTTP request timeout in seconds |

#### Default cache locations by platform

|          |                                                        |
|----------|--------------------------------------------------------|
| Platform | Default path                                           |
| macOS    | `~/Library/Application Support/nhanesR`                |
| Linux    | `~/.local/share/nhanesR` (or `$XDG_DATA_HOME/nhanesR`) |
| Windows  | `%APPDATA%/nhanesR`                                    |

#### Setting options permanently

Add lines like these to your `~/.Rprofile`:

    options(
      nhanesR.cache_dir = "/data/nhanes_cache",  # shared lab server path
      nhanesR.verbose   = FALSE,                  # suppress progress messages
      nhanesR.timeout   = 300L                    # 5-minute timeout for slow connections
    )

Options set in `.Rprofile` take precedence over package defaults:
nhanesR only sets an option at load time if it is not already defined.

## See also

[`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md)
and
[`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md),
whose caching behaviour is controlled by the options described above.

## Examples

``` r
# View current cache location
nhanes_cache_dir()
#> [1] "/Users/dwinsemius/Library/Application Support/nhanesR"

# Change for this session only
nhanes_cache_dir("~/my_nhanes_cache")
#> [1] "/Users/dwinsemius/my_nhanes_cache"

# Suppress download messages for this session
options(nhanesR.verbose = FALSE)

# View all current nhanesR option values
Filter(function(x) startsWith(x, "nhanesR."), names(options()))
#> [1] "nhanesR.cache_dir" "nhanesR.timeout"   "nhanesR.verbose"  
```
