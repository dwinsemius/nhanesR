# R/harmonize.R

#' Harmonize variable names across NHANES cycles and stack into one data frame
#'
#' NHANES analytes are sometimes stored under different variable names in
#' different cycles (e.g. HDL cholesterol: `LBDHDL` in 1999-2002, `LBXHDD` in
#' 2003-2004, `LBDHDD` from 2005 onward). `nhanes_harmonize()` renames these
#' per-cycle variables to a single common name before stacking.
#'
#' Use [nhanes_variable_map()] to discover which variable names appear in which
#' cycles, then pass the rename mapping here.
#'
#' @param data_list A named list of per-cycle data frames, as returned by
#'   [nhanes_download()] or [nhanes_download_analyte()].
#' @param mapping A named character vector where **names** are the old
#'   (per-cycle) variable names and **values** are the single common name to
#'   use across all cycles. Multiple old names can map to the same new name.
#'   Example: `c(LBDHDL = "HDL_mgdL", LBXHDD = "HDL_mgdL", LBDHDD = "HDL_mgdL")`.
#' @param stack Logical. If `TRUE` (default), row-bind the renamed data frames
#'   into a single data frame using [nhanes_stack()]. Set to `FALSE` to return
#'   the renamed list without stacking.
#'
#' @return If `stack = TRUE` (default), a single data frame with all cycles
#'   row-bound and the harmonized variable names present. If `stack = FALSE`,
#'   a named list of data frames with renamed variables.
#' @export
#' @examples
#' \dontrun{
#' cycles <- nhanes_cycles()[1:10, "cycle"]
#'
#' # HDL cholesterol: three different variable names across ten cycles
#' hdl_list <- nhanes_download_analyte("HDL", cycles)
#' hdl <- nhanes_harmonize(
#'   hdl_list,
#'   mapping = c(LBDHDL = "HDL_mgdL", LBXHDD = "HDL_mgdL", LBDHDD = "HDL_mgdL")
#' )
#' table(hdl$cycle, is.na(hdl$HDL_mgdL))
#'
#' # Total cholesterol needs no harmonization (LBXTC throughout), but you can
#' # still rename for clarity:
#' tchol_list <- nhanes_download_analyte("total cholesterol", cycles)
#' tchol <- nhanes_harmonize(tchol_list, mapping = c(LBXTC = "TC_mgdL"))
#' }
nhanes_harmonize <- function(data_list, mapping, stack = TRUE) {
  if (!is.character(mapping) || is.null(names(mapping))) {
    cli::cli_abort(
      "{.arg mapping} must be a named character vector where names are the \\
       old variable names and values are the new common name. \\
       Example: {.code c(LBDHDL = \"HDL_mgdL\", LBDHDD = \"HDL_mgdL\")}"
    )
  }

  result <- lapply(data_list, function(df) {
    present <- names(mapping)[names(mapping) %in% names(df)]
    if (length(present) == 0L) return(df)

    new_names <- mapping[present]

    # Warn and deduplicate if two source vars resolve to the same target
    dupes <- names(which(table(new_names) > 1L))
    if (length(dupes) > 0L) {
      cy <- if ("cycle" %in% names(df)) df$cycle[1L] else "unknown cycle"
      cli::cli_warn(
        "Multiple source variables map to {.val {dupes}} in {.val {cy}}. \\
         Using the first match."
      )
      keep      <- !duplicated(new_names)
      present   <- present[keep]
      new_names <- new_names[keep]
    }

    names(df)[match(present, names(df))] <- new_names
    df
  })

  if (stack) nhanes_stack(result) else result
}
