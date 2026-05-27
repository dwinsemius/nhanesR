# R/search.R

#' Search NHANES variables by keyword
#'
#' Searches the CDC NHANES variable catalog for variables whose name or
#' description matches a keyword or phrase. Results are drawn from the CDC
#' variable list pages and cached locally to avoid repeated HTTP requests.
#'
#' This is the recommended way to find the correct file code and variable
#' name for an analyte across NHANES cycles. For example, total cholesterol
#' was stored in `LAB13` (1999-2000), `L13_B` (2001-2002), `L13_C`
#' (2003-2004), and `TCHOL` (2005 onwards), always in variable `LBXTC`.
#'
#' @param term Character. A keyword or phrase to search for. Matched
#'   case-insensitively against variable names and descriptions.
#' @param component Character or `NULL`. Restrict search to one NHANES
#'   component: `"Demographics"`, `"Dietary"`, `"Examination"`,
#'   `"Laboratory"`, or `"Questionnaire"`. If `NULL` (default), searches
#'   all components.
#' @param refresh Logical. Re-fetch the variable catalog from CDC even if
#'   cached? Default `FALSE`.
#'
#' @return A data frame with columns:
#'   \describe{
#'     \item{variable_name}{CDC variable code (e.g. `LBXTC`).}
#'     \item{variable_desc}{Plain-language description.}
#'     \item{file_name}{Data file code to pass to [nhanes_download()].}
#'     \item{file_desc}{Description of the data file.}
#'     \item{cycle}{Two-year cycle label (e.g. `"2015-2016"`).}
#'     \item{component}{NHANES component.}
#'   }
#'
#' @export
#' @examples
#' \dontrun{
#' # Find total cholesterol across all cycles
#' nhanes_search_variables("total cholesterol")
#'
#' # Restrict to laboratory component
#' nhanes_search_variables("alanine", component = "Laboratory")
#'
#' # Search for HDL cholesterol
#' nhanes_search_variables("HDL")
#' }
nhanes_search_variables <- function(term,
                                    component = NULL,
                                    refresh   = FALSE) {
  .nhanes_check_pkg("rvest")

  components <- if (!is.null(component)) {
    .nhanes_validate_component(component)
  } else {
    c("Demographics", "Dietary", "Examination", "Laboratory", "Questionnaire")
  }

  results <- lapply(components, function(comp) {
    .nhanes_fetch_variable_list(comp, refresh = refresh)
  })

  catalog <- do.call(rbind, results)

  if (is.null(catalog) || nrow(catalog) == 0L) {
    cli::cli_warn("Variable catalog is empty. Try {.code refresh = TRUE}.")
    return(.nhanes_empty_variable_list())
  }

  # Case-insensitive search across variable name and description
  pattern <- term
  matches <- grepl(pattern, catalog$variable_name, ignore.case = TRUE) |
             grepl(pattern, catalog$variable_desc,  ignore.case = TRUE)

  out <- catalog[matches, , drop = FALSE]
  rownames(out) <- NULL

  if (nrow(out) == 0L) {
    cli::cli_inform("No variables matched {.val {term}}. Try a broader term.")
  } else {
    cli::cli_inform(
      "Found {nrow(out)} match{?es} for {.val {term}} across \\
       {length(unique(out$cycle))} cycle{?s}."
    )
  }

  out
}

# ── Internal helpers ───────────────────────────────────────────────────────────

#' Fetch and cache the CDC variable list for one component
#' @keywords internal
.nhanes_fetch_variable_list <- function(component, refresh = FALSE) {
  rds_path <- file.path(
    .nhanes_cache_subdir("variable_catalog"),
    paste0(tolower(component), ".rds")
  )

  if (!refresh && .nhanes_cache_valid(rds_path)) {
    return(readRDS(rds_path))
  }

  if (isTRUE(getOption("nhanesR.verbose"))) {
    cli::cli_inform("Fetching variable catalog for {component} from CDC...")
  }

  url <- sprintf(
    "https://wwwn.cdc.gov/nchs/nhanes/search/variablelist.aspx?Component=%s",
    component
  )

  page <- tryCatch(
    rvest::read_html(url),
    error = function(e) {
      cli::cli_warn(
        "Could not fetch variable list for {component}: {conditionMessage(e)}"
      )
      return(NULL)
    }
  )

  if (is.null(page)) return(.nhanes_empty_variable_list())

  tbl <- tryCatch(
    rvest::html_table(
      rvest::html_element(page, "table"),
      fill = TRUE
    ),
    error = function(e) NULL
  )

  if (is.null(tbl) || nrow(tbl) == 0L) {
    cli::cli_warn("No variable table found for component {.val {component}}.")
    return(.nhanes_empty_variable_list())
  }

  # Normalise column names
  names(tbl) <- c("variable_name", "variable_desc", "file_name",
                  "file_desc", "begin_year", "end_year",
                  "component", "use_constraints")

  # Build cycle label and tidy file_name (strip " Doc" suffix CDC appends)
  tbl$cycle     <- paste0(tbl$begin_year, "-", tbl$end_year)
  tbl$file_name <- trimws(gsub("\\s+Doc\\s*$", "", tbl$file_name,
                               ignore.case = TRUE))

  out <- tbl[, c("variable_name", "variable_desc", "file_name",
                 "file_desc", "cycle", "component"), drop = FALSE]
  out <- out[nzchar(out$variable_name), , drop = FALSE]

  saveRDS(out, rds_path)
  .nhanes_write_hash(rds_path)

  out
}

.nhanes_empty_variable_list <- function() {
  data.frame(
    variable_name = character(),
    variable_desc = character(),
    file_name     = character(),
    file_desc     = character(),
    cycle         = character(),
    component     = character(),
    stringsAsFactors = FALSE
  )
}
