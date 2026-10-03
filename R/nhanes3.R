# R/nhanes3.R
# NHANES III (1988-1994) public-use data files: fixed-width `.dat` files with a SAS
# program (`.sas`) that gives the column positions. These functions cover the path
# download -> layout (names, labels, positions) -> choose columns -> read, so a user can
# stop after the layout and decide which of the thousands of columns to read.

.nhanes3_base_url <- "https://wwwn.cdc.gov/nchs/data/nhanes3/"

.nhanes3_registry <- function() {
  data.frame(
    file = c("exam", "adult", "youth", "lab", "lab2"),
    folder = c("1a", "1a", "1a", "1a", "2a"),
    description = c(
      "Examination file (body measures such as height, weight and waist, and other exam components)",
      "Adult questionnaire (ages 17 and over)",
      "Youth questionnaire",
      "First laboratory file (its COP serum cotinine column is blank for every record)",
      "Second laboratory file (serum cotinine, COP)"),
    stringsAsFactors = FALSE)
}

#' List the NHANES III data files and their CDC addresses
#'
#' NHANES III (1988-1994) predates the per-cycle XPT files of continuous NHANES. Its
#' public-use data are a few large fixed-width `.dat` files, each with a SAS program
#' (`.sas`) that gives the column positions and variable labels, and a codebook PDF.
#' This lists the files [nhanes3_download()], [nhanes3_layout()] and [nhanes3_read()]
#' know by name.
#'
#' @return A data frame with `file` (the name to pass to the other functions), `folder`
#'   on the CDC server, a `description`, and the `dat_url`, `sas_url` and
#'   `codebook_url` of each file.
#' @seealso [nhanes3_layout()] to see what is in a file, [nhanes3_read()] to read chosen
#'   columns. The `nhanes-iii` vignette walks through the whole workflow.
#' @examples
#' nhanes3_files()
#' @export
nhanes3_files <- function() {
  r <- .nhanes3_registry()
  stem <- paste0(.nhanes3_base_url, r$folder, "/", r$file)
  r$dat_url <- paste0(stem, ".dat")
  r$sas_url <- paste0(stem, ".sas")
  r$codebook_url <- paste0(stem, "-acc.pdf")
  r
}

.nhanes3_row <- function(file) {
  r <- nhanes3_files()
  i <- match(file, r$file)
  if (is.na(i)) {
    cli::cli_abort(c(
      "{.val {file}} is not a known NHANES III file.",
      "i" = "Known files: {.val {r$file}}. See {.fn nhanes3_files}.",
      "i" = "To use a file of your own, give the path to its {.file .sas} program (and {.arg dat_file})."))
  }
  r[i, , drop = FALSE]
}

#' Download NHANES III files into the nhanesR cache
#'
#' Fetches the data file, its SAS program (which holds the column positions and
#' variable labels) and the codebook PDF, and keeps them in the nhanesR cache
#' (see [nhanes_cache_dir()]) so they are downloaded once. The exam file is about
#' 195 MB, so the download timeout is raised to at least 15 minutes for these files.
#'
#' The `.sas` file is small. It is enough for [nhanes3_layout()], so you can look
#' through the variables before deciding to download the large `.dat`.
#'
#' @param file A file name from [nhanes3_files()]: `"exam"`, `"adult"`, `"youth"`, `"lab"`
#'   or `"lab2"`.
#' @param what Which pieces to fetch: `"sas"`, `"dat"` and/or `"codebook"`. The default is
#'   all three.
#' @param refresh Download again even if the file is already cached.
#' @return Invisibly, a named character vector of the local paths.
#' @seealso [nhanes3_layout()], [nhanes3_read()]
#' @examples
#' \dontrun{
#' # the small SAS program only: enough to browse the variables
#' nhanes3_download("adult", what = "sas")
#' }
#' @export
nhanes3_download <- function(file, what = c("sas", "dat", "codebook"), refresh = FALSE) {
  what <- match.arg(what, several.ok = TRUE)
  row <- .nhanes3_row(file)
  dir <- .nhanes_cache_subdir("nhanes3")
  urls <- c(sas = row$sas_url, dat = row$dat_url, codebook = row$codebook_url)
  ext  <- c(sas = ".sas", dat = ".dat", codebook = "-acc.pdf")
  op <- options(nhanesR.timeout = max(getOption("nhanesR.timeout", 120L), 900L))
  on.exit(options(op), add = TRUE)
  paths <- character(0)
  for (w in what) {
    dest <- file.path(dir, paste0(file, ext[[w]]))
    if (refresh || !file.exists(dest)) {
      .nhanes_download_file(urls[[w]], dest, desc = paste("NHANES III", file, w))
    }
    paths[w] <- dest
  }
  invisible(paths)
}

# Path of the .sas program: an explicit path, a `file` that is itself a path, or the cached /
# downloaded copy of a known file.
.nhanes3_sas_path <- function(file, sas_file = NULL, refresh = FALSE) {
  if (!is.null(sas_file)) {
    if (!file.exists(sas_file)) cli::cli_abort("{.arg sas_file} not found: {.path {sas_file}}")
    return(sas_file)
  }
  if (file.exists(file) && grepl("\\.sas$", file, ignore.case = TRUE)) return(file)
  unname(nhanes3_download(file, what = "sas", refresh = refresh)[["sas"]])
}

#' The variables in an NHANES III file: names, labels and column positions
#'
#' Parses the SAS program that ships with each NHANES III file. This is the stage where
#' you can stop and choose which columns to read: the exam file has more than 2,000 and
#' the adult questionnaire more than 1,200, and reading a handful by position is fast
#' while reading them all is not. Only the small `.sas` file is needed, not the large `.dat`.
#'
#' Labels are the short descriptions from the SAS program (for example
#' `"How tall are you without shoes - inches"`). Value labels and the missing-value codes of
#' each variable are in the codebook PDF, and a variable's own special codes (for example
#' 666 for "varies") are not the same as the all-8s/all-9s codes that [nhanes3_read()] can
#' recode; check the codebook before recoding (see the `nhanes-iii` vignette).
#'
#' @param file A file name from [nhanes3_files()], or the path to a `.sas` program.
#' @param pattern Optional regular expression; keep the variables whose **name or label**
#'   matches it, for example `"height|weight|waist"`.
#' @param ignore.case Match `pattern` without regard to case (default `TRUE`).
#' @param sas_file Path to the `.sas` program, if you already have it; otherwise the cached
#'   copy is used, downloaded on first use.
#' @param refresh Download the `.sas` file again.
#' @return A data frame of class `nhanes3_layout` with one row per variable: `var`, `label`
#'   (`NA` if the SAS program gives none), `start`, `end`, `width` (the number of
#'   characters in the field) and `type` (`"numeric"` or `"character"`). The record length
#'   is checked against the layout and stored in `attr(, "lrecl")`.
#' @seealso [nhanes3_read()], [nhanes3_files()]
#' @examples
#' \dontrun{
#' nhanes3_layout("adult", pattern = "tall|weigh")   # heights and weights people reported
#' nhanes3_layout("exam", pattern = "^BMP")          # the body-measure variables
#' }
#' @export
nhanes3_layout <- function(file, pattern = NULL, ignore.case = TRUE, sas_file = NULL, refresh = FALSE) {
  path <- .nhanes3_sas_path(file, sas_file, refresh)
  s <- readLines(path, warn = FALSE)

  # lines after a `HEADER` line up to the end of the SAS statement. The terminating ';' is
  # usually on a line of its own, but NHANES III files also put it at the end of the last item
  # (e.g. the last LABEL line in the adult file).
  block <- function(header) {
    i <- grep(paste0("^\\s*", header, "\\s*$"), s)[1L]
    if (is.na(i)) return(character(0))
    rest <- s[(i + 1L):length(s)]
    end <- grep(";\\s*$", rest)[1L]
    if (is.na(end)) end <- length(rest)
    out <- rest[seq_len(end)]
    out[length(out)] <- sub(";\\s*$", "", out[length(out)])
    out[nzchar(trimws(out))]
  }

  inp <- block("INPUT")
  if (!length(inp)) cli::cli_abort("No INPUT block found in {.path {path}}; is this an NHANES III SAS program?")
  m <- regmatches(inp, regexec("^\\s*([A-Z][A-Z0-9_]*)\\s+(\\$?)\\s*([0-9]+)(-([0-9]+))?\\s*$", inp))
  m <- m[lengths(m) == 6L]
  if (!length(m)) cli::cli_abort("Could not read any column positions from the INPUT block of {.path {path}}.")
  g <- function(k) vapply(m, `[`, "", k)
  L <- data.frame(var = g(2L), start = as.integer(g(4L)), stringsAsFactors = FALSE)
  L$end <- ifelse(nzchar(g(6L)), as.integer(g(6L)), L$start)
  L$width <- L$end - L$start + 1L
  L$type <- ifelse(g(3L) == "$", "character", "numeric")

  lab <- block("LABEL")
  lm <- regmatches(lab, regexec("^\\s*([A-Z][A-Z0-9_]*)\\s*=\\s*\"(.*)\"\\s*$", lab))
  lm <- lm[lengths(lm) == 3L]
  labels <- stats::setNames(vapply(lm, `[`, "", 3L), vapply(lm, `[`, "", 2L))
  L$label <- unname(labels[L$var])
  L <- L[, c("var", "label", "start", "end", "width", "type")]

  lrecl <- suppressWarnings(as.integer(sub(".*LRECL\\s*=\\s*([0-9]+).*", "\\1",
                                           grep("LRECL\\s*=", s, value = TRUE)[1L])))
  if (!is.na(lrecl) && max(L$end) != lrecl - 2L) {     # LRECL counts 2 bytes for the line ending
    cli::cli_abort(c(
      "The column layout does not cover the whole record in {.path {path}}.",
      "i" = "Last column ends at {max(L$end)}, but the record length (LRECL, less the 2-byte line ending) is {lrecl - 2L}.",
      "i" = "Reading by these positions would be wrong, so nothing is returned."))
  }
  if (anyDuplicated(L$var)) cli::cli_warn("Duplicate variable names in the layout: {.val {unique(L$var[duplicated(L$var)])}}.")

  if (!is.null(pattern)) {
    keep <- grepl(pattern, L$var, ignore.case = ignore.case) |
            grepl(pattern, ifelse(is.na(L$label), "", L$label), ignore.case = ignore.case)
    L <- L[keep, , drop = FALSE]
  }
  rownames(L) <- NULL
  attr(L, "lrecl") <- lrecl
  attr(L, "sas_file") <- path
  class(L) <- c("nhanes3_layout", "data.frame")
  L
}

#' @export
print.nhanes3_layout <- function(x, n = 25L, ...) {
  cat(sprintf("NHANES III layout: %d variable%s%s\n", nrow(x), if (nrow(x) == 1L) "" else "s",
              if (!is.null(attr(x, "lrecl")) && !is.na(attr(x, "lrecl"))) sprintf(" (record length %d)", attr(x, "lrecl") - 2L) else ""))
  y <- as.data.frame(x)
  y$label <- ifelse(is.na(y$label), "", ifelse(nchar(y$label) > 60, paste0(substr(y$label, 1L, 57L), "..."), y$label))
  y$position <- ifelse(y$width == 1L, as.character(y$start), paste0(y$start, "-", y$end))
  show <- utils::head(y[, c("var", "label", "position", "type")], n)
  print(show, row.names = FALSE, ...)
  if (nrow(y) > n) cat(sprintf("... and %d more; use pattern = to narrow, or print(as.data.frame(x)) for all.\n", nrow(y) - n))
  invisible(x)
}

#' Read chosen columns of an NHANES III file
#'
#' Reads only the columns you ask for from the large fixed-width `.dat` file, using the
#' positions in its SAS program ([nhanes3_layout()]). Choose the columns by name with
#' `vars`, or, in an interactive session, leave `vars` out to pick them from a list (use
#' `pattern` to shorten the list first). `SEQN`, the respondent ID used to link files and
#' mortality, is always included when the file has it.
#'
#' NHANES III stores "blank but applicable" as all 8s and "don't know" as all 9s, sized to
#' the field (`8`/`9` for a one-character item, `88888`/`99999` for a five-character
#' measurement). Left in place they look like real values. `recode` turns these into `NA` for
#' the variables you name. It is **not** applied to everything: IDs, weights and age have no such
#' codes, and many items have special codes of their own (666 for "varies", 777 for "less than
#' 1 per day"), so check the codebook ([nhanes3_download()] with `what = "codebook"`) first.
#'
#' @param file A file name from [nhanes3_files()], or the path to a `.sas` program (then
#'   give `dat_file` too).
#' @param vars Character vector of variable names to read. If `NULL` in an interactive session,
#'   you choose from a list; otherwise an error asks you to supply them.
#' @param pattern Optional regular expression that narrows the interactive list (name or
#'   label), as in [nhanes3_layout()].
#' @param recode Names of numeric variables (among `vars`) whose all-8s and all-9s codes become
#'   `NA`. Default none.
#' @param id Name of the ID column to always include, or `NULL` for none.
#' @param dat_file Path to the `.dat` file, if you already have it; otherwise the cached copy is
#'   used, downloaded on first use (about 195 MB for the exam file).
#' @param sas_file Path to the `.sas` program, if you already have it.
#' @param n_max Maximum number of rows to read (default all), useful for a quick look.
#' @return A tibble with the requested columns (numeric, except any `$` character columns). It
#'   carries `attr(, "width")`, the width of each field, and `attr(, "var_labels")`, the SAS
#'   labels.
#' @seealso [nhanes3_layout()], [nhanes3_files()], [nhanes_mortality_parse()] for the
#'   NHANES III linked mortality file.
#' @examples
#' \dontrun{
#' exam <- nhanes3_read("exam", c("HSSEX", "HSAGEIR", "BMPHT", "BMPWT", "WTPFEX6"),
#'                      recode = c("BMPHT", "BMPWT"))
#' }
#' @export
nhanes3_read <- function(file, vars = NULL, pattern = NULL, recode = NULL, id = "SEQN",
                         dat_file = NULL, sas_file = NULL, n_max = Inf) {
  L <- nhanes3_layout(file, sas_file = sas_file)
  if (is.null(vars)) {
    if (!interactive()) {
      ex <- sprintf("nhanes3_layout(\"%s\", pattern = \"weight\")", file)
      cli::cli_abort(c(
        "{.arg vars} is required outside an interactive session.",
        "i" = "Browse the variables with {.fn nhanes3_layout}, for example {.code {ex}}."))
    }
    cand <- if (is.null(pattern)) L else L[grepl(pattern, L$var, ignore.case = TRUE) |
                                           grepl(pattern, ifelse(is.na(L$label), "", L$label), ignore.case = TRUE), ]
    if (!nrow(cand)) cli::cli_abort("No variables match {.val {pattern}}.")
    shown <- sprintf("%-10s %s", cand$var, ifelse(is.na(cand$label), "", cand$label))
    picked <- utils::select.list(shown, multiple = TRUE, title = "Select NHANES III columns to read:")
    if (!length(picked)) cli::cli_abort("No columns selected.")
    vars <- cand$var[match(picked, shown)]
  }
  vars <- unique(as.character(vars))
  unknown <- setdiff(vars, L$var)
  if (length(unknown)) {
    cli::cli_abort(c("Not in the layout: {.val {unknown}}.",
                     "i" = "Look names up with {.fn nhanes3_layout}."))
  }
  if (!is.null(id) && id %in% L$var && !id %in% vars) vars <- c(id, vars)
  if (!is.null(recode)) {
    bad <- setdiff(recode, vars)
    if (length(bad)) cli::cli_abort("{.arg recode} names columns that are not being read: {.val {bad}}.")
    chr <- recode[L$type[match(recode, L$var)] == "character"]
    if (length(chr)) cli::cli_abort("{.arg recode} applies to numeric columns; {.val {chr}} is character.")
  }

  if (is.null(dat_file)) {
    if (file.exists(file) && grepl("\\.sas$", file, ignore.case = TRUE)) {
      cli::cli_abort("Give {.arg dat_file} when {.arg file} is the path to a SAS program.")
    }
    dat_file <- unname(nhanes3_download(file, what = "dat")[["dat"]])
  } else if (!file.exists(dat_file)) {
    cli::cli_abort("{.arg dat_file} not found: {.path {dat_file}}")
  }

  sel <- L[match(vars, L$var), ]
  x <- readr::read_fwf(dat_file, readr::fwf_positions(sel$start, sel$end, sel$var),
                       col_types = paste(ifelse(sel$type == "character", "c", "d"), collapse = ""),
                       n_max = n_max, progress = FALSE)

  verbose <- isTRUE(getOption("nhanesR.verbose", TRUE))
  for (v in recode) {
    w <- sel$width[sel$var == v]
    codes <- as.numeric(c(strrep("8", w), strrep("9", w)))
    hit <- x[[v]] %in% codes
    if (verbose && any(hit)) {
      cli::cli_inform("{.field {v}}: {sum(hit)} value{?s} set to NA (codes {.val {codes}})")
    }
    x[[v]][hit] <- NA
  }
  attr(x, "width") <- stats::setNames(sel$width, sel$var)
  attr(x, "var_labels") <- stats::setNames(sel$label, sel$var)
  x
}
