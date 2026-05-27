#' Harmonize variable names across NHANES cycles and stack into one data frame
#'
#' NHANES analytes are sometimes stored under different variable names in
#' different cycles (e.g. HDL cholesterol: `LBDHDL` in 1999-2002, `LBXHDD`
#' in 2003-2004, `LBDHDD` from 2005 onward). `nhanes_harmonize()` offers two
#' ways to resolve this:
#'
#' - **Unit-based** (`unit` + `name`): scans column label attributes for the
#'   specified unit string (e.g. `"mg/dL"`) and renames the matching column.
#'   No need to know the CDC variable codes in advance. Use `label_pattern` to
#'   disambiguate when a file contains multiple columns in the same unit
#'   (e.g. early cycles that bundled total cholesterol and HDL together).
#'
#' - **Explicit mapping** (`mapping`): a named character vector of old -> new
#'   variable names. More verbose but unambiguous.
#'
#' @param data_list A named list of per-cycle data frames, as returned by
#'   [nhanes_download()] or [nhanes_download_analyte()].
#' @param mapping A named character vector where **names** are the old
#'   (per-cycle) variable names and **values** are the single common name to
#'   use across all cycles. Multiple old names may map to the same new name.
#'   Example: `c(LBDHDL = "HDL_mgdl", LBXHDD = "HDL_mgdl",
#'   LBDHDD = "HDL_mgdl")`. Ignored when `unit` is provided.
#' @param unit Character or `NULL`. A unit string to match against column
#'   label attributes (case-insensitive). Common values: `"mg/dL"`, `"g/dL"`,
#'   `"U/L"`, `"umol/L"`. When supplied, `name` must also be provided.
#' @param name Character or `NULL`. The output column name to use when
#'   `unit` is supplied (e.g. `"HDL_mgdl"`).
#' @param label_pattern Character or `NULL`. An additional regex matched
#'   against column labels when `unit` is used. Use this to disambiguate when
#'   a file contains multiple columns in the same unit (e.g. `"HDL"` to
#'   select only the HDL column from a file that also contains total
#'   cholesterol in mg/dL).
#' @param prefer_mgdl Logical. If `TRUE` (default), drop SI-unit columns
#'   (mmol/L, g/L, etc.) when a conventional-unit counterpart (mg/dL, g/dL,
#'   U/L) exists in the same data frame. Detection uses label attributes:
#'   the unit token is stripped from each label and SI columns whose base
#'   description matches a conventional-unit column are removed. Applied
#'   before any renaming step.
#' @param trim Logical. Only applies when `unit` is used. If `TRUE` (default),
#'   the returned data frame contains only `SEQN`, `cycle`, and the column
#'   named by `name`. Set to `FALSE` to retain all columns (useful when the
#'   source file contains other variables you want to keep).
#' @param stack Logical. If `TRUE` (default), row-bind the renamed data
#'   frames into a single data frame using [nhanes_stack()]. Set to `FALSE`
#'   to return the renamed list without stacking.
#'
#' @return If `stack = TRUE` (default), a single stacked data frame. When
#'   `unit` is used with `trim = TRUE` (the default), only `SEQN`, `cycle`,
#'   and the harmonized column are returned — ready for merging. If
#'   `stack = FALSE`, a named list of data frames.
#' @export
#' @examples
#' \dontrun{
#' cycles <- nhanes_cycles()[1:10, "cycle"]
#'
#' # Unit-based: trim = TRUE (default) returns SEQN + cycle + HDL_mgdl only
#' hdl_list <- nhanes_download_analyte("HDL", cycles)
#' hdl <- nhanes_harmonize(hdl_list, unit = "mg/dL", name = "HDL_mgdl",
#'                          label_pattern = "HDL")
#'
#' # Merge two analytes cleanly
#' tchol_list <- nhanes_download_analyte("total cholesterol", cycles)
#' TC  <- nhanes_harmonize(tchol_list, unit = "mg/dL", name = "TC_mgdl",
#'                          label_pattern = "total cholesterol")
#' lipids <- merge(hdl, TC, by = c("SEQN", "cycle"))
#'
#' # Explicit mapping (trim does not apply)
#' hdl <- nhanes_harmonize(
#'   hdl_list,
#'   mapping = c(LBDHDL = "HDL_mgdl", LBXHDD = "HDL_mgdl",
#'               LBDHDD = "HDL_mgdl")
#' )
#' }
nhanes_harmonize <- function(data_list,
                              mapping       = NULL,
                              unit          = NULL,
                              name          = NULL,
                              label_pattern = NULL,
                              prefer_mgdl   = TRUE,
                              trim          = TRUE,
                              stack         = TRUE) {
  if (isTRUE(prefer_mgdl)) {
    data_list <- lapply(data_list, .nhanes_drop_si_duplicates)
  }

  if (!is.null(unit)) {
    if (is.null(name)) {
      cli::cli_abort(
        "{.arg name} must be provided when {.arg unit} is used. \\
         Example: {.code nhanes_harmonize(lst, unit = \"mg/dL\", \\
         name = \"HDL_mgdl\")}"
      )
    }
    result <- lapply(data_list, function(df) {
      df <- .nhanes_harmonize_by_unit(df, unit, name, label_pattern)
      if (isTRUE(trim)) {
        keep <- intersect(c("SEQN", "cycle", name), names(df))
        df   <- df[, keep, drop = FALSE]
      }
      df
    })
  } else if (!is.null(mapping)) {
    if (!is.character(mapping) || is.null(names(mapping))) {
      cli::cli_abort(
        "{.arg mapping} must be a named character vector. \\
         Example: {.code c(LBDHDL = \"HDL_mgdl\", LBDHDD = \"HDL_mgdl\")}"
      )
    }
    result <- lapply(data_list, function(df) {
      .nhanes_harmonize_by_mapping(df, mapping)
    })
  } else {
    cli::cli_abort(
      "Provide either {.arg unit} (with {.arg name}) or {.arg mapping}."
    )
  }

  if (stack) nhanes_stack(result) else result
}

# ── Internal helpers ──────────────────────────────────────────────────────────

.nhanes_harmonize_by_unit <- function(df, unit, name, label_pattern) {
  labels  <- vapply(df, function(col) attr(col, "label") %||% "",
                    character(1L))
  matches <- grepl(unit, labels, ignore.case = TRUE)
  if (!is.null(label_pattern)) {
    matches <- matches & grepl(label_pattern, labels, ignore.case = TRUE)
  }
  idx <- which(matches)

  if (length(idx) == 0L) {
    cycle_label <- if ("cycle" %in% names(df)) df$cycle[1L] else "unknown"
    cli::cli_warn(
      "No column with unit {.val {unit}} found in {.val {cycle_label}}. \\
       Column {.val {name}} will be {.code NA} after stacking."
    )
    return(df)
  }

  if (length(idx) > 1L) {
    cycle_label <- if ("cycle" %in% names(df)) df$cycle[1L] else "unknown"
    cli::cli_warn(
      "Multiple columns match unit {.val {unit}} in {.val {cycle_label}}: \\
       {.val {names(df)[idx]}}. Using {.val {names(df)[idx[1L]]}}. \\
       Use {.arg label_pattern} to disambiguate."
    )
    idx <- idx[1L]
  }

  names(df)[idx] <- name
  df
}

#' Drop SI-unit columns when a conventional-unit counterpart exists
#'
#' Uses label attributes rather than variable name patterns because CDC naming
#' is inconsistent (e.g. LBXTC / LBDTCSI, LBXHDD / LBDHDDSI). Strips the
#' unit token from each label and drops SI columns whose base description
#' matches any conventional-unit column in the same data frame.
#' @keywords internal
.nhanes_drop_si_duplicates <- function(df) {
  si_units   <- "mmol/L|g/L|umol/L|nmol/L"
  conv_units <- "mg/dL|g/dL|U/L|IU/L|ug/mL|mg/L|ug/dL|ng/mL"

  labels <- vapply(df, function(col) attr(col, "label") %||% "",
                   character(1L))

  si_idx   <- which(grepl(si_units,   labels, ignore.case = TRUE))
  conv_idx <- which(grepl(conv_units, labels, ignore.case = TRUE))

  if (length(si_idx) == 0L || length(conv_idx) == 0L) return(df)

  strip_unit <- function(x) {
    pattern <- paste0(
      "\\s*[:(]?\\s*(", si_units, "|", conv_units, ")\\s*[):]?\\s*"
    )
    trimws(gsub(pattern, "", x, ignore.case = TRUE))
  }

  si_base   <- strip_unit(labels[si_idx])
  conv_base <- strip_unit(labels[conv_idx])

  to_drop <- names(df)[si_idx[si_base %in% conv_base]]

  if (length(to_drop) > 0L) {
    df <- df[, setdiff(names(df), to_drop), drop = FALSE]
  }
  df
}

.nhanes_harmonize_by_mapping <- function(df, mapping) {
  present   <- names(mapping)[names(mapping) %in% names(df)]
  if (length(present) == 0L) return(df)
  new_names <- mapping[present]

  dupes <- names(which(table(new_names) > 1L))
  if (length(dupes) > 0L) {
    cycle_label <- if ("cycle" %in% names(df)) df$cycle[1L] else "unknown"
    cli::cli_warn(
      "Multiple source variables map to {.val {dupes}} in \\
       {.val {cycle_label}}. Using the first match."
    )
    keep      <- !duplicated(new_names)
    present   <- present[keep]
    new_names <- new_names[keep]
  }

  names(df)[match(present, names(df))] <- new_names
  df
}
