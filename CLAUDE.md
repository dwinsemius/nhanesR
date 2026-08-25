# nhanesR — Claude Code guidance

## Project location
`~/Documents/R.code/nhanesR` · GitHub: `dwinsemius/nhanesR` · CRAN target

---

## Common commands

```r
# Check (use this before every commit touching R/ or man/)
devtools::check(run_dont_test = TRUE)   # must pass 0 errors, 0 warnings

# Rebuild documentation after editing roxygen
devtools::document()

# Rebuild internal sysdata (after editing data-raw/build_registries.R)
source("data-raw/build_registries.R")

# Rebuild pkgdown site (required before every release push)
pkgdown::build_site()

# Install locally for testing
remotes::install_github("dwinsemius/nhanesR", build_vignettes = TRUE, force = TRUE)
```

---

## Release checklist

See the `release` skill for the full pre-release checklist and CRAN submission steps.

---

## Key package behaviors

**`nhanes_download()` return type**
- Single cycle → returns a **data frame**
- Multiple cycles → returns a **named list** of data frames

Many functions (`nhanes_mortality_link`, `nhanes_merge`, etc.) expect a data frame, not a list. Use `nhanes_stack()` to combine a multi-cycle list before passing downstream.

**Cache default**
The default cache is `file.path(tempdir(), "nhanesR")` — session-only, CRAN policy compliant. Users who want a persistent cache must set `nhanesR.cache_dir` in `~/.Rprofile`. Do not change this default.

**LMF registry (`sysdata.rda`)**
The internal `.lmf_registry` maps NHANES cycles to CDC FTP filenames for the Public-Use Linked Mortality Files. Key facts:
- 2017-2020 is **not** in the registry — CDC never published `NHANES_2017_2020_MORT_2019_PUBLIC.dat`; only 2017-2018 exists
- `has_lmf_public = FALSE` for the 2017-2020 cycle in `.nhanes_cycles`
- Before adding any new URL entry to `.lmf_registry`, verify with `curl -sI <url>` that it returns HTTP 200

After editing `data-raw/build_registries.R`, always `source()` it to regenerate `R/sysdata.rda`, then rebuild docs.

---

## Documentation conventions

**No `\d` in Rd files** — Windows Rd parser treats `\d` as an unknown macro. Use `[0-9]` in regex patterns shown in documentation.

**Examples** — use `\donttest{}` for any example that requires network access to CDC. Do not use `\dontrun{}` (CRAN policy: `\dontrun` implies the example literally cannot be run). All examples in `\donttest{}` must be syntactically correct and would succeed if the network were available.

**`_pkgdown.yml`** — every exported function must appear in the `reference:` section, and every vignette in `vignettes/` must be listed under `articles:`. `pkgdown::build_site()` will abort with an error if either is missing.

---

## Windows-specific gotchas

- Regex `\d` in documentation (see above)
- DLL locking: testers may see `Permission denied` copying `curl.dll` if another R session is open — this is a Windows file-lock issue unrelated to nhanesR; tell them to close all R sessions and retry

---

## CRAN submission

See the `release` skill.
