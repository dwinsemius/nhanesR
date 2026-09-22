# R/nhis_data.R
#
# Raw NHIS survey data download -- scoped deliberately to just two "core"
# files (Household, Person) per the user's explicit request (2026-09-21),
# not the full NHIS catalog. The full catalog (dozens of supplemental
# modules, heavy year-to-year schema churn, a redesign in 1997 and another
# in 2019) is a much larger undertaking than NHANES's stable file-code
# catalog -- deliberately out of scope here.
#
# Column layout comes from NCHS's own SAS input-syntax files, parsed at
# download time by the SAScii package (Suggests, not Imports -- GPL-2|GPL-3
# licensed, only needed for this one code path, gated by
# .nhanes_check_pkg(), same pattern already used for the "foreign" fallback
# XPT parser). Verified directly against the real 1986 and 1997 files before
# relying on it (not just read the DESCRIPTION): parse.SAScii() correctly
# recovers skip/gap columns from the pre-1997 SAS syntax (no explicit gap
# markers in the source -- inferred from position arithmetic) and the
# implied-decimal convention in the post-1997 syntax (a SAS "46-51 .1"
# column becomes a 0.1 divisor); read.SAScii() round-tripped the actual 1986
# HOUSEHLD.DAT to 24,698 records, matching that year's own documentation
# exactly.

.nhis_data_base_url <- "https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NHIS/"
.nhis_sas_base_url  <- "https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Program_Code/NHIS/"

# -- Registry lookups -------------------------------------------------------------

#' List NHIS survey years with Household/Person data available
#'
#' @param module Character. `"either"` (default, years where at least one of
#'   Household/Person is available), `"household"`, or `"person"`.
#'
#' @return Character vector of NHIS survey years.
#'
#' @section The 1989 Household gap:
#' 1989's Household `.zip` is confirmed absent from the CDC server (HTTP
#' 404), despite that year's own documentation (`readme.txt`) listing a
#' Household file in its file table (48,054 records, the same 335-byte
#' record length as every other core file that year). The matching
#' `HOUSEHLD.SAS` syntax file is still present -- only the data file itself
#' is missing. Every case/extension variant (`.EXE`/`.exe`/`.ZIP`/`.zip`,
#' upper/lower filename) was checked before concluding this is a genuine
#' absence on NCHS's end rather than a URL-pattern issue here. 1989's
#' Person file is unaffected.
#'
#' @seealso [nhis_download()]
#' @export
nhis_data_years <- function(module = c("either", "household", "person")) {
  module <- match.arg(module)
  reg <- .nhis_data_registry
  if (module == "either") {
    unique(reg$year[reg$available])
  } else {
    reg$year[reg$module == module & reg$available]
  }
}

#' @keywords internal
.nhis_data_registry_row <- function(year, module) {
  row <- .nhis_data_registry[.nhis_data_registry$year == year &
                               .nhis_data_registry$module == module, ]
  if (nrow(row) == 0L) {
    cli::cli_abort(
      "No {.val {module}} file registered for NHIS year {.val {year}}. \\
       Available years: {.val {nhis_data_years(module)}}"
    )
  }
  if (!row$available) {
    cli::cli_abort(
      "NHIS {.val {module}} for {.val {year}} is not available on the CDC \\
       server (confirmed HTTP 404, not a URL-pattern issue on nhanesR's \\
       side -- see {.fn nhis_data_years} for the full explanation)."
    )
  }
  row
}

# -- URL construction ---------------------------------------------------------------

#' @keywords internal
.nhis_data_url <- function(year, module, base, ext) {
  row  <- .nhis_data_registry_row(year, module)
  path <- if (!is.na(row$subdir)) paste0(year, "/", row$subdir, "/") else paste0(year, "/")
  paste0(base, path, row$file_base, ext)
}

#' @keywords internal
.nhis_data_zip_url <- function(year, module) {
  .nhis_data_url(year, module, .nhis_data_base_url, ".zip")
}

#' @keywords internal
.nhis_data_sas_url <- function(year, module) {
  .nhis_data_url(year, module, .nhis_sas_base_url, ".sas")
}

#' @keywords internal
.nhis_data_rds_path <- function(year, module) {
  dir <- .nhanes_cache_subdir("nhis_data", "parsed")
  file.path(dir, paste0(module, "_", year, ".rds"))
}

# -- Download + parse -----------------------------------------------------------------

#' Download and parse an NHIS Household or Person file
#'
#' Downloads the fixed-width `.zip`, unzips it, downloads the matching SAS
#' input-syntax file NCHS publishes alongside it, and parses both together
#' using [SAScii::read.SAScii()] -- reusing NCHS's own column-position
#' specification rather than a hand-built one. Results are cached locally as
#' RDS files, same convention as [nhanes_download()] and
#' [nhis_mortality_parse()].
#'
#' @section Column names differ by era:
#' 1997 onward uses NCHS's own descriptive variable names directly
#' (`SRVY_YR`, `HHX`, `WTFA_HH`, ...), taken straight from that era's SAS
#' syntax file -- no further relabeling needed. **1986-1996 uses NCHS's
#' original placeholder scheme** (e.g. `HH_22`, `PX_24`) because that's
#' literally what the SAS syntax files for those years contain -- there is
#' no `nhis_harmonize()`-equivalent yet to relabel these to their real
#' meanings, which requires a separate crosswalk built from `NHISCORE.PDF`
#' (not yet done; see this file's own development history for the scoping
#' discussion).
#'
#' @param module Character. `"household"` or `"person"`.
#' @param years Character or numeric vector of NHIS survey years. Defaults
#'   to all years available for `module` (see [nhis_data_years()]).
#' @param refresh Logical. Re-download/re-parse even if a cached RDS exists?
#'   Default `FALSE`.
#'
#' @return If a single year is requested, a data frame. If multiple years
#'   are requested, a named list of data frames keyed by year. Every
#'   returned data frame carries a `.nhis_data_year` integer column (the
#'   requested survey year, not to be confused with a native `YEAR`/
#'   `SRVY_YR` column the file itself may already contain).
#'
#' @seealso [nhis_data_years()] for years with data available;
#'   [nhis_mortality_link()] to join mortality follow-up onto the result.
#' @export
#' @examples
#' \donttest{
#' hh_2015 <- nhis_download("household", "2015")
#' }
nhis_download <- function(module, years = NULL, refresh = FALSE) {
  module <- match.arg(module, c("household", "person"))
  .nhanes_check_pkg("SAScii")

  if (is.null(years)) years <- nhis_data_years(module)
  years <- as.character(years)

  result <- vector("list", length(years))
  names(result) <- years

  for (yr in years) {
    rds_path <- .nhis_data_rds_path(yr, module)

    if (!refresh && .nhanes_cache_valid(rds_path)) {
      if (getOption("nhanesR.verbose")) {
        cli::cli_inform("Loading cached NHIS {module} for {yr}")
      }
      result[[yr]] <- readRDS(rds_path)
      next
    }

    row <- .nhis_data_registry_row(yr, module)

    zip_dest <- file.path(.nhanes_cache_subdir("nhis_data", "zip"),
                          paste0(module, "_", yr, ".zip"))
    if (refresh || !file.exists(zip_dest)) {
      .nhanes_download_file(.nhis_data_zip_url(yr, module), zip_dest,
                            desc = paste("NHIS", module, yr))
    }

    dat_dir   <- .nhanes_cache_subdir("nhis_data", "dat", paste0(module, "_", yr))
    dat_files <- utils::unzip(zip_dest, exdir = dat_dir, overwrite = TRUE)
    dat_path  <- dat_files[grepl("\\.dat$", dat_files, ignore.case = TRUE)][1L]
    if (is.na(dat_path)) {
      cli::cli_abort("No .DAT file found inside {.path {zip_dest}}")
    }

    sas_dest <- file.path(.nhanes_cache_subdir("nhis_data", "sas"),
                          paste0(row$file_base, "_", yr, ".sas"))
    if (refresh || !file.exists(sas_dest)) {
      .nhanes_download_file(.nhis_data_sas_url(yr, module), sas_dest,
                            desc = paste("NHIS", module, yr, "SAS syntax"))
    }

    if (getOption("nhanesR.verbose")) {
      cli::cli_progress_step("Parsing NHIS {module} {yr} via SAScii")
    }
    # SAScii::read.SAScii() cat()s per-1000-row and per-column progress with
    # no quiet argument -- captured and discarded rather than left to spam
    # the console; nhanesR emits its own progress message above instead.
    # Also throws a benign, cosmetic warning per column ("invalid 'scipen'
    # 1000000, used 9999", from its own internal options(scipen=) call
    # exceeding R's cap) -- confirmed harmless by cross-checking actual
    # parsed values (YEAR/QUARTER etc.) before suppressing it, not assumed.
    invisible(utils::capture.output(
      df <- suppressWarnings(SAScii::read.SAScii(dat_path, sas_dest, zipped = FALSE))
    ))

    df$.nhis_data_year <- as.integer(yr)
    df$.nhis_module     <- module

    dir.create(dirname(rds_path), recursive = TRUE, showWarnings = FALSE)
    saveRDS(df, rds_path)
    .nhanes_write_hash(rds_path)

    result[[yr]] <- df
  }

  if (length(result) == 1L) return(result[[1L]])
  result
}
