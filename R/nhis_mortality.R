# R/nhis_mortality.R
#
# NHIS mortality-linkage support. nhanesR does not download NHIS survey data
# itself (NHIS's file distribution and per-year schema churn are a much larger,
# separate undertaking than NHANES's stable catalog -- out of scope here). This
# file adds only the mortality-LINKAGE half: downloading/parsing NCHS's
# public-use NHIS Linked Mortality Files and joining them onto NHIS data the
# user already has from elsewhere (e.g. IPUMS Health Surveys, or NCHS's own
# NHIS microdata site).

# -- Download -------------------------------------------------------------------

#' Download NHIS Public-Use Linked Mortality Files
#'
#' Downloads the fixed-width `.dat` mortality files from the CDC FTP server
#' for one or more NHIS survey years. Files are cached locally; re-downloading
#' is skipped unless `refresh = TRUE`.
#'
#' NCHS distributes NHIS mortality linkage as one file per **survey year**
#' (unlike NHANES's one file per 2-year cycle). The public-use LMF provides
#' mortality follow-up through **December 31, 2019** for NHIS 1986-2018.
#'
#' @param years Character or numeric vector of NHIS survey years (e.g.
#'   `"1997"` or `1997`). Defaults to all years with a public-use LMF. See
#'   [nhis_lmf_years()].
#' @param refresh Logical. Re-download even if a cached file exists? Default
#'   `FALSE`.
#' @param quiet Logical. Suppress download messages? Default uses the
#'   `nhanesR.verbose` option.
#'
#' @return Invisibly, a named character vector of local file paths (one per
#'   year). The primary side-effect is writing files to the cache directory
#'   under `mortality/dat/`.
#'
#' @seealso [nhis_mortality_parse()], [nhis_mortality_link()],
#'   [nhanes_mortality_download()] for the NHANES equivalent.
#'
#' @export
#' @examples
#' \donttest{
#' # Download specific years (downloading all 33 available years at once,
#' # via nhis_mortality_download() with no arguments, works the same way but
#' # is a much larger multi-file FTP batch -- prefer a specific year vector
#' # for routine use)
#' nhis_mortality_download(c("2015", "2016", "2017"))
#' }
nhis_mortality_download <- function(years = NULL,
                                    refresh = FALSE,
                                    quiet   = !getOption("nhanesR.verbose", TRUE)) {
  if (is.null(years)) {
    years <- nhis_lmf_years()
  }

  years <- .nhis_validate_lmf_years(years)
  dest_dir <- .nhanes_cache_subdir("mortality", "dat")

  paths <- character(length(years))
  names(paths) <- years

  for (yr in years) {
    url      <- .nhis_lmf_url(yr)
    filename <- basename(url)
    dest     <- file.path(dest_dir, filename)
    rds_path <- .nhis_lmf_rds_path(yr)

    if (!refresh && file.exists(dest)) {
      if (!quiet) cli::cli_inform("Using cached NHIS LMF for {yr}: {.path {dest}}")
      paths[[yr]] <- dest
      next
    }

    if (!quiet) cli::cli_inform("Downloading NHIS LMF for {yr}")
    .nhanes_download_file(url, dest, desc = paste("NHIS LMF", yr))
    paths[[yr]] <- dest

    # Invalidate any existing parsed RDS when raw file is refreshed
    if (file.exists(rds_path)) {
      file.remove(rds_path)
      hash_f <- paste0(rds_path, ".md5")
      if (file.exists(hash_f)) file.remove(hash_f)
    }
  }

  invisible(paths)
}

#' List NHIS survey years with a public-use LMF
#'
#' @return Character vector of NHIS survey years, `"1986"` through `"2018"`.
#' @seealso [nhis_mortality_link()], [nhis_mortality_download()]
#' @export
nhis_lmf_years <- function() {
  .nhis_lmf_registry$year
}

# -- Parse ----------------------------------------------------------------------

#' Parse NHIS Linked Mortality Files into data frames
#'
#' Reads the fixed-width `.dat` files (downloading them first if needed) and
#' returns a named list of data frames, one per survey year.
#'
#' Variable labels are attached as the `"label"` attribute on each column,
#' following the `haven`/`labelled` convention -- same as
#' [nhanes_mortality_parse()].
#'
#' @param years Character or numeric vector of NHIS survey years. Defaults to
#'   all available. See [nhis_lmf_years()].
#' @param refresh Logical. Re-parse even if a cached RDS exists? Default
#'   `FALSE`.
#' @param download Logical. Auto-download missing `.dat` files? Default
#'   `TRUE`.
#'
#' @return A named list of data frames. Each data frame contains:
#'   \describe{
#'     \item{PUBLICID}{NHIS public-use identifier (join key -- character, not
#'       numeric; NHIS does not use NHANES's `SEQN`).}
#'     \item{ELIGSTAT}{Eligibility: 1=eligible; 2=under 18; 3=insufficient data.}
#'     \item{MORTSTAT}{Vital status: 0=assumed alive; 1=assumed deceased.}
#'     \item{UCOD_LEADING}{Underlying cause of death (ICD-10 recode).}
#'     \item{DIABETES}{Diabetes mentioned on death certificate (1=yes).}
#'     \item{HYPERTEN}{Hypertension mentioned on death certificate (1=yes).}
#'     \item{DODQTR}{Quarter of death (1-4).}
#'     \item{DODYEAR}{Year of death.}
#'     \item{WGT_NEW}{Person-level sample weight, adjusted for linkage
#'       ineligibility. Blank for 1986 (NCHS recommends `WTFA` from the
#'       NHIS public-use file that year instead).}
#'     \item{SA_WGT_NEW}{Sample Adult sample weight, adjusted for linkage
#'       ineligibility. Only populated 1997 onward (the Sample Adult File
#'       did not exist before the 1997 NHIS redesign).}
#'   }
#'
#' @note Unlike the NHANES LMF, **NHIS's public-use LMF has no
#'   `PERMTH_INT`/`PERMTH_EXM`-equivalent person-months variable.**
#'   Constructing follow-up time requires combining `DODQTR`/`DODYEAR` with
#'   the participant's own NHIS interview year/quarter, which comes from the
#'   NHIS survey data itself, not this file. There is no `nhis_survival_prep()`
#'   analogous to [nhanes_survival_prep()] for this reason -- see
#'   [nhis_mortality_link()]'s documentation for how far this package takes
#'   NHIS mortality linkage.
#'
#' @seealso [nhis_mortality_download()] to download the raw `.dat` files;
#'   [nhis_mortality_link()] to join parsed mortality data onto NHIS data.
#' @export
#' @examples
#' \donttest{
#' lmf <- nhis_mortality_parse(c("2015", "2016"))
#' lmf[["2015"]]
#' }
nhis_mortality_parse <- function(years   = NULL,
                                 refresh  = FALSE,
                                 download = TRUE) {
  if (is.null(years)) years <- nhis_lmf_years()
  years <- .nhis_validate_lmf_years(years)

  result <- vector("list", length(years))
  names(result) <- years

  for (yr in years) {
    rds_path <- .nhis_lmf_rds_path(yr)

    # Return from RDS cache if valid
    if (!refresh && .nhanes_cache_valid(rds_path)) {
      if (getOption("nhanesR.verbose")) {
        cli::cli_inform("Loading cached NHIS LMF for {yr}")
      }
      result[[yr]] <- readRDS(rds_path)
      next
    }

    # Ensure .dat file exists
    dat_path <- .nhis_lmf_dat_path(yr)
    if (!file.exists(dat_path)) {
      if (download) {
        nhis_mortality_download(yr, quiet = FALSE)
      } else {
        cli::cli_abort(
          "NHIS LMF .dat file not found for {yr}. \\
           Run {.fn nhis_mortality_download} first, or set {.arg download = TRUE}."
        )
      }
    }

    df <- .nhis_parse_lmf_dat(dat_path, year = yr)

    saveRDS(df, rds_path)
    .nhanes_write_hash(rds_path)

    result[[yr]] <- df
  }

  result
}

# -- Link -----------------------------------------------------------------------

#' Link NHIS mortality data onto an NHIS analytic dataset
#'
#' Performs a left join of the parsed NHIS LMF onto a data frame containing
#' NHIS participants, matched on the participant public-use ID **and** survey
#' year.
#'
#' `nhis_data` must come from somewhere else -- nhanesR does not download NHIS
#' survey data (see the package-level scoping note in this file's source, or
#' `?nhis_mortality_download`). Typical sources are NCHS's own NHIS public-use
#' microdata site or IPUMS Health Surveys (IPUMS NHIS).
#'
#' @section Why the join requires a year column, unlike [nhanes_mortality_link()]:
#' [nhanes_mortality_link()] matches on `SEQN` alone, which is safe because
#' NHANES's `SEQN` numbering does not overlap across the 2-year cycles this
#' package pools. NHIS's `PUBLICID` construction is not documented clearly
#' enough (see NCHS's linkage-methods appendix, referenced in the LMF
#' codebook) to assume the same global uniqueness across survey years, so
#' this function matches conservatively on the `(PUBLICID, year)` pair rather
#' than `PUBLICID` alone.
#'
#' @param nhis_data A data frame containing NHIS participants.
#' @param years Character or numeric vector of NHIS survey years present in
#'   `nhis_data`. Inferred from `year_col` when omitted.
#' @param keep_vars Character vector of LMF variables to retain. Defaults to
#'   all: `c("ELIGSTAT", "MORTSTAT", "UCOD_LEADING", "DIABETES", "HYPERTEN",
#'   "DODQTR", "DODYEAR", "WGT_NEW", "SA_WGT_NEW")`.
#' @param download Logical. Download missing LMF files automatically? Default
#'   `TRUE`.
#' @param publicid_col Character. Name of the participant public-use ID
#'   column in `nhis_data`. Default `"PUBLICID"` (NCHS standard).
#' @param year_col Character. Name of the survey-year column in `nhis_data`.
#'   Default `"SRVY_YR"` (the NHIS public-use file convention).
#'
#' @return `nhis_data` with LMF columns appended. Rows with no mortality
#'   record (PUBLICID/year combinations absent from the LMF) will have `NA`
#'   for all LMF columns.
#'
#' @seealso [nhis_lmf_years()] for years with a public-use LMF;
#'   [nhis_mortality_parse()] which produces the input to this join;
#'   [nhanes_mortality_link()] for the NHANES equivalent.
#' @export
#' @examples
#' \donttest{
#' # nhis_data must be supplied from elsewhere -- nhanesR does not download it
#' # nhis_data <- your_nhis_loading_function(...)
#' # nhis_data_mort <- nhis_mortality_link(nhis_data)
#' }
nhis_mortality_link <- function(nhis_data,
                                years        = NULL,
                                keep_vars    = NULL,
                                download     = TRUE,
                                publicid_col = "PUBLICID",
                                year_col     = "SRVY_YR") {
  if (!(publicid_col %in% names(nhis_data))) {
    cli::cli_abort(
      "{.arg nhis_data} must contain a public-use ID column. \\
       Looking for {.val {publicid_col}}; set {.arg publicid_col} if named differently."
    )
  }

  if (is.null(years)) {
    if (year_col %in% names(nhis_data)) {
      years <- as.character(unique(nhis_data[[year_col]]))
    } else {
      cli::cli_abort(
        "Supply {.arg years} or ensure {.arg nhis_data} has a survey-year \\
         column (set {.arg year_col} if it is not named {.val SRVY_YR})."
      )
    }
  }

  years <- .nhis_validate_lmf_years(years)

  default_keep <- c("PUBLICID", "ELIGSTAT", "MORTSTAT", "UCOD_LEADING",
                    "DIABETES", "HYPERTEN", "DODQTR", "DODYEAR",
                    "WGT_NEW", "SA_WGT_NEW")
  keep_vars <- keep_vars %||% default_keep[-1L]

  # Parse and row-bind LMFs for all requested years
  lmf_list <- nhis_mortality_parse(years, download = download)
  lmf_all  <- do.call(rbind, lapply(names(lmf_list), function(yr) {
    df <- lmf_list[[yr]]
    df$.nhis_lmf_year <- yr
    df
  }))

  avail    <- intersect(keep_vars, names(lmf_all))
  lmf_join <- lmf_all[, unique(c("PUBLICID", ".nhis_lmf_year", avail)), drop = FALSE]

  # Match on (PUBLICID, year) pair -- see roxygen section above for why year
  # is required here but not in nhanes_mortality_link().
  key_data <- paste(nhis_data[[publicid_col]],
                    as.character(nhis_data[[year_col]]), sep = "\r")
  key_lmf  <- paste(lmf_join$PUBLICID, lmf_join$.nhis_lmf_year, sep = "\r")
  idx <- match(key_data, key_lmf)

  lmf_cols <- setdiff(names(lmf_join), c("PUBLICID", ".nhis_lmf_year"))
  for (col in lmf_cols) {
    nhis_data[[col]] <- lmf_join[[col]][idx]
  }

  n_unmatched <- sum(is.na(idx))
  if (n_unmatched > 0L) {
    cli::cli_warn(
      "{n_unmatched} NHIS participant{?s} had no matching LMF record for \\
       the requested year{?s}. Check that {.arg publicid_col}/{.arg year_col} \\
       are correct and that all needed years are included in {.arg years}."
    )
  }

  nhis_data
}

# -- Internal helpers -------------------------------------------------------------

.nhis_lmf_url <- function(year) {
  reg <- .nhis_lmf_registry[.nhis_lmf_registry$year == year, ]
  if (nrow(reg) == 0L) {
    cli::cli_abort(
      "No public-use NHIS LMF found for year {.val {year}}. \\
       Available years: {.val {.nhis_lmf_registry$year}}"
    )
  }
  paste0(reg$ftp_base, reg$filename)
}

.nhis_lmf_rds_path <- function(year) {
  dir  <- .nhanes_cache_subdir("mortality", "parsed")
  file.path(dir, paste0("nhis_lmf_", year, ".rds"))
}

.nhis_lmf_dat_path <- function(year) {
  reg      <- .nhis_lmf_registry[.nhis_lmf_registry$year == year, ]
  dest_dir <- .nhanes_cache_subdir("mortality", "dat")
  file.path(dest_dir, reg$filename)
}

.nhis_validate_lmf_years <- function(years) {
  years <- as.character(years)
  valid <- nhis_lmf_years()
  bad   <- setdiff(years, valid)
  if (length(bad) > 0L) {
    cli::cli_abort(
      "{cli::qty(length(bad))}Year{?s} not available in the public-use NHIS LMF: {.val {bad}}.\\n
       Valid years: {.val {valid}}"
    )
  }
  years
}

#' Parse a single NHIS LMF .dat file using the internal column specification
#' @keywords internal
.nhis_parse_lmf_dat <- function(dat_path, year) {
  spec <- .nhis_lmf_colspec

  col_pos <- readr::fwf_positions(
    start = spec$col_start,
    end   = spec$col_end,
    col_names = spec$variable
  )

  col_types <- paste(spec$col_type, collapse = "")

  df <- readr::read_fwf(
    dat_path,
    col_positions = col_pos,
    col_types     = col_types,
    na            = c(".", " ", ""),
    show_col_types = FALSE
  )

  for (i in seq_len(nrow(spec))) {
    v <- spec$variable[i]
    if (v %in% names(df)) {
      attr(df[[v]], "label") <- spec$label[i]
      if (spec$perturbed[i]) {
        attr(df[[v]], "perturbed") <- TRUE
      }
    }
  }

  df$.nhis_lmf_year         <- year
  attr(df, "lmf_vintage")   <- "2019"
  attr(df, "censor_date")   <- "2019-12-31"
  attr(df, "source_file")   <- basename(dat_path)

  df
}
