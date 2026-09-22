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

# -- SAS INPUT-statement validation (overlapping/mistyped column ranges) --------
#
# SAScii::read.SAScii() -- and this package's own earlier position arithmetic
# in data-raw/build_nhis_pre1997_crosswalk.R -- both assume a SAS INPUT
# statement's declared columns are sequential and non-overlapping. Confirmed
# directly (2026-09-22, chasing a 6-position label mismatch found while
# extending the pre-1997 crosswalk) that this assumption is sometimes wrong
# in NCHS's own source files:
#
#   1. PERSONSX_1994.sas declares BIRTH $ 34-39 (the combined MMYYYY string)
#      AND its own sub-parts BIRTHMO $ 34-35 / BIRTHYR $ 36-39 as SEPARATE
#      variables covering the SAME bytes -- a real, legitimate SAS authoring
#      convention (declare a convenience combined field alongside its parts),
#      but one that breaks any width-summing position reconstruction, and
#      that SAScii::read.SAScii() itself gets wrong when actually READING
#      data (verified against a live nhis_download("person","1994") call:
#      BIRTHMO read 00-19 instead of 1-12, BIRTHYR read 0322-9322, HEIGHT/
#      WEIGHT/everything downstream shifted by exactly 6 bytes).
#   2. The SAME file separately has a plain typo: HEP12WP is declared
#      LENGTH 6 but its INPUT-statement range is written as 327-355 (29
#      bytes) instead of 327-332 -- confirmed against the real physical
#      .DAT record length (336 bytes, matching the file's own declared
#      LRECL=335) and the variable's own LENGTH declaration, not guessed.
#
# Both are real defects in NCHS's own source document, not in how nhanesR
# reads it -- but nhanesR silently inheriting them (via SAScii) means
# nhis_download() would return corrupted data for any affected year without
# any indication something was wrong. The functions below extract the SAS
# file's LITERAL declared positions directly (not via SAScii's width-based
# intermediate, which is exactly what loses the information needed to catch
# this), detect both defect patterns, and either correct them (subset
# overlaps: drop the narrower contained variable(s); LENGTH mismatches:
# trust the LENGTH declaration) or -- if the corrected layout still doesn't
# match the file's own declared LRECL -- abort with a clear error rather
# than silently return wrong data for a still-unrecognized defect pattern.
#
# Years with no defects (checked: 1986-1992) are completely unaffected --
# the correction is a no-op and nhis_download() continues to use
# SAScii::read.SAScii() exactly as before for them.

#' @keywords internal
.nhis_sas_literal_positions <- function(sas_path) {
  lines <- readLines(sas_path, warn = FALSE)
  start_idx <- which(trimws(lines) == "INPUT")
  if (length(start_idx) == 0L) return(NULL)
  start_idx <- start_idx[1]
  rel_end <- which(grepl(";\\s*$", lines[(start_idx + 1):length(lines)]))[1]
  if (is.na(rel_end)) return(NULL)
  input_block <- paste(lines[start_idx:(start_idx + rel_end)], collapse = " ")

  tok_re <- "([A-Za-z_][A-Za-z0-9_]*)\\s+(\\$)?\\s*([0-9]+)\\s*-\\s*([0-9]+)"
  toks <- regmatches(input_block, gregexpr(tok_re, input_block, perl = TRUE))[[1]]
  if (length(toks) == 0L) return(NULL)
  m <- regmatches(toks, regexec(tok_re, toks, perl = TRUE))
  do.call(rbind, lapply(m, function(x) {
    data.frame(varname = x[2], char = nzchar(x[3]),
               start = as.integer(x[4]), end = as.integer(x[5]),
               stringsAsFactors = FALSE)
  }))
}

#' @keywords internal
.nhis_sas_lrecl <- function(sas_path) {
  lines <- readLines(sas_path, warn = FALSE)
  hit <- grep("LRECL", lines, value = TRUE)
  if (length(hit) == 0L) return(NA_integer_)
  as.integer(gsub(".*LRECL\\s*=\\s*([0-9]+).*", "\\1", hit[1]))
}

#' Validate (and where possible, correct) a pre-1997 NHIS SAS layout
#'
#' Returns `NULL` if the file's literal positions can't be extracted at all
#' (falls back to plain `SAScii::read.SAScii()` unchanged), or a data frame
#' of corrected (varname, start, end, char) if extraction succeeded --
#' whether or not any correction was actually needed. Aborts with
#' `cli::cli_abort()` if a defect is found that isn't one of the two known,
#' handled patterns (subset overlap; LENGTH-statement width mismatch).
#' @keywords internal
.nhis_sas_validate_and_fix <- function(sas_path, year, module) {
  spec <- .nhis_sas_literal_positions(sas_path)
  if (is.null(spec)) return(NULL)

  spec <- spec[order(spec$start, -spec$end), ]

  # Pattern 1: a variable's range fully contained within an earlier,
  # already-seen (wider-or-equal) variable's range -- drop the contained one.
  container_end <- -Inf
  spec$dropped <- FALSE
  for (i in seq_len(nrow(spec))) {
    if (spec$start[i] <= container_end && spec$end[i] <= container_end) {
      spec$dropped[i] <- TRUE
    } else {
      container_end <- spec$end[i]
    }
  }
  spec <- spec[!spec$dropped, setdiff(names(spec), "dropped")]

  # NOTE on a rejected second correction: also tried cross-checking each
  # variable's INPUT-declared width against its own LENGTH-statement width,
  # trusting LENGTH when they disagreed (this is how the HEP12WP typo below
  # was first found and "fixed"). Reverted -- confirmed by direct testing
  # that this is unsound in general: SAS's LENGTH statement for a NUMERIC
  # variable declares internal storage size (commonly a flat 3 or 8 bytes
  # for every numeric variable in these files, e.g. "SEX 3  AGE 3"),
  # completely unrelated to the INPUT statement's ASCII column width (SEX is
  # 1 character wide, AGE is 2) -- they only need to agree for CHARACTER
  # ($) variables. Applying this check to numeric variables corrupted
  # several already-correct ones (HISPFLAG, HEIGHT, ...) by "fixing" them to
  # match an unrelated internal storage size. Left as a documented dead end
  # rather than silently dropped, since it's a plausible-looking approach
  # someone might reach for again.

  lrecl <- .nhis_sas_lrecl(sas_path)
  final_end <- max(spec$end)
  if (!is.na(lrecl) && final_end > lrecl) {
    cli::cli_abort(
      "NHIS {module} {year}: after correcting known overlap/typo patterns, \\
       the SAS layout still extends to position {final_end}, past the \\
       file's own declared LRECL={lrecl}. This is an unrecognized defect in \\
       NCHS's source file, not something nhanesR can safely auto-correct -- \\
       refusing to return possibly-corrupted data. Please report this at \\
       {.url https://github.com/dwinsemius/nhanesR/issues}."
    )
  }

  spec[order(spec$start), ]
}

# -- Pre-1997 placeholder-name labelling -----------------------------------------

#' Attach descriptive labels to a pre-1997 Household/Person data frame
#'
#' Looks up `.nhis_pre1997_crosswalk` (built by
#' `data-raw/build_nhis_pre1997_crosswalk.R`, covering 1986-1991 only -- see
#' that script's own header for why the scope stops there) and attaches a
#' `"label"` attribute (haven/labelled convention, same as every other
#' labelled column in this package) to each matching placeholder-named
#' column. Years/modules with no crosswalk entry (1992 onward, and any
#' column the crosswalk itself couldn't resolve to a label) are left
#' untouched -- this never errors or warns for missing coverage, since most
#' of nhis_download()'s callers will be asking for years this doesn't cover.
#' @keywords internal
.nhis_apply_pre1997_labels <- function(df, year, module) {
  cw <- .nhis_pre1997_crosswalk
  rows <- cw[cw$year == year & cw$module == module & !is.na(cw$label), ]
  if (nrow(rows) == 0L) return(df)
  for (i in seq_len(nrow(rows))) {
    v <- rows$varname[i]
    if (v %in% names(df)) {
      attr(df[[v]], "label") <- rows$label[i]
      if (!is.na(rows$item_no[i])) attr(df[[v]], "nhis_item_no") <- rows$item_no[i]
    }
  }
  df
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
#' syntax file. **1986-1996 uses NCHS's original placeholder scheme**
#' instead (e.g. `HH_22`, `PX_24`) -- that's literally what those years' SAS
#' syntax files contain. Column NAMES are never changed (a placeholder stays
#' a placeholder), but for **1986-1991** each placeholder column gets a
#' `"label"` attribute (haven/labelled convention, same as every other
#' labelled column in this package) with its real meaning, built from that
#' year's own `NHISCORE.PDF` codebook (`data-raw/build_nhis_pre1997_crosswalk.R`).
#' Check with `attr(df$HH_22, "label")`, or [NH_describe()] to see all of
#' them at once. **1992-1996 do not get labels** -- checked directly, not
#' just left undone: the source PDF's own page layout changes enough
#' starting in 1992 (its `NHISCORE.PDF` roughly triples in page count that
#' year) that the crosswalk-building parser's match rate drops hard, and
#' unlike 1986-1991, a meaningful share of what doesn't match already has a
#' descriptive native variable name anyway (e.g. `REGION`, `HEIGHT`,
#' `WEIGHT` for 1993), so the gap matters less than the raw match-rate drop
#' suggests. Extending the crosswalk past 1991 is possible future work, not
#' done here.
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

    # Validate the SAS layout before trusting SAScii to read it -- confirmed
    # directly (2026-09-22) that some years' SAS syntax files contain real
    # defects SAScii doesn't detect (overlapping column declarations,
    # position typos) that silently produce corrupted data. See
    # .nhis_sas_validate_and_fix()'s own header for the full story. Years
    # with no defect (checked: 1986-1992) are unaffected -- this is a no-op
    # and SAScii::read.SAScii() is used exactly as before.
    raw_positions <- .nhis_sas_literal_positions(sas_dest)
    validated <- .nhis_sas_validate_and_fix(sas_dest, yr, module)
    needed_correction <- !is.null(validated) && !is.null(raw_positions) &&
      nrow(validated) < nrow(raw_positions)

    if (getOption("nhanesR.verbose")) {
      cli::cli_progress_step("Parsing NHIS {module} {yr}")
    }

    if (needed_correction) {
      # A fixable defect (e.g. an overlapping column declaration) was found
      # and corrected -- SAScii would read this file incorrectly (it has no
      # way to know about the overlap), so read directly from the corrected
      # positions instead of going through SAScii at all for this file.
      col_types <- paste(ifelse(validated$char, "c", "d"), collapse = "")
      df <- as.data.frame(readr::read_fwf(
        dat_path,
        col_positions = readr::fwf_positions(validated$start, validated$end, validated$varname),
        col_types = col_types,
        na = c(".", " ", ""),
        show_col_types = FALSE
      ))
    } else {
      # SAScii::read.SAScii() cat()s per-1000-row and per-column progress
      # with no quiet argument -- captured and discarded rather than left to
      # spam the console. Also throws a benign, cosmetic warning per column
      # ("invalid 'scipen' 1000000, used 9999", from its own internal
      # options(scipen=) call exceeding R's cap) -- confirmed harmless by
      # cross-checking actual parsed values (YEAR/QUARTER etc.) before
      # suppressing it, not assumed.
      invisible(utils::capture.output(
        df <- suppressWarnings(SAScii::read.SAScii(dat_path, sas_dest, zipped = FALSE))
      ))
    }

    df <- .nhis_apply_pre1997_labels(df, yr, module)

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
