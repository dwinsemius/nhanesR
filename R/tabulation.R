#' Tabulate deaths, person-years and crude mortality rates
#'
#' Counts deaths and accumulates person-years of exposure in the cells of one
#' or more categorical covariates, and returns the crude mortality rate in each
#' cell together with **every marginal table** (one-way, two-way, and so on) in
#' the same long data frame.
#'
#' This is a rate tabulation, **not a life table**. The exposure basis is the
#' follow-up time of everyone: decedents contribute time from entry to death and
#' censored people contribute time from entry to censoring, so a rate is deaths
#' divided by all person-years at risk, not only the exposure of those who died.
#'
#' Margins are exact aggregates of the finest cells, with the rate recomputed
#' from the margin's own deaths and person-years (rates are never averaged).
#' A covariate that has been collapsed is labelled `"All"`; the grand total has
#' every covariate set to `"All"`. Confidence intervals are exact Poisson
#' intervals on the death count, treating person-years as fixed.
#'
#' @param data A data frame with one row per person.
#' @param time Name of the follow-up time column (time from entry to death or
#'   censoring), in `time_units`.
#' @param event Name of the event column: `1` or `TRUE` for a death, `0` or
#'   `FALSE` for censored.
#' @param by Character vector naming the categorical covariates that define the
#'   cells. Numeric covariates with more than 20 distinct values must be cut with
#'   `breaks`.
#' @param time_units Units of `time`: `"years"`, `"months"` or `"days"`.
#'   Person-years are always reported in years.
#' @param scale Rates are reported per `scale` person-years (default 1000).
#' @param weights Optional name of a survey-weight column. Cells then hold
#'   weighted deaths and weighted person-years (point estimates). The confidence
#'   intervals are **not valid** with weights and are returned as `NA`.
#' @param expected Optional name of a column holding each person's **expected
#'   number of deaths** over their follow-up (for example the fitted death
#'   probability from a model of age, sex and period). Cells then also report
#'   expected deaths and the observed/expected ratio (O/E) with exact intervals.
#'   Cannot be combined with `age_breaks`.
#' @param margins If `TRUE` (default) return all marginal tables and the grand
#'   total; if `FALSE` return only the finest cells.
#' @param breaks Optional named list of cut points used to categorise numeric
#'   covariates in `by`, for example `list(BMI = c(0, 18.5, 25, 30, Inf))`.
#'   Intervals are closed on the left.
#' @param age_col,age_breaks Optional. `age_col` names a column holding age at
#'   entry in years; with `age_breaks` each person's follow-up is split across
#'   the attained-age bands they pass through (using [survival::pyears()]), and
#'   attained age becomes one more tabulation covariate named `attained_age`.
#'   Requires the survival package.
#' @param conf_level Confidence level of the intervals (default 0.95).
#' @return A data frame of class `mortality_tabulation` with one column per
#'   covariate in `by`, then `n` (people, or weighted people), `deaths`,
#'   `pyears`, `rate`, `rate_lo`, `rate_hi`, and with `expected` also
#'   `expected`, `oe`, `oe_lo`, `oe_hi`; the column `n_cov` counts how many
#'   covariates define each row (`0` for the grand total). Rows are ordered by
#'   `n_cov`, then by the factor levels of `by`. With `age_breaks`, `n` counts the
#'   people who start follow-up in each cell.
#' @seealso [tabulation_grid()] to pivot two covariates into a grid;
#'   [survival::pyears()], which does the same counting for fixed cells.
#' @examples
#' set.seed(1)
#' d <- data.frame(sex = sample(c("F", "M"), 500, TRUE),
#'                 bmi = sample(c("<25", "25+"), 500, TRUE),
#'                 t = rexp(500, 0.05))
#' d$dead <- as.integer(d$t < 12); d$t <- pmin(d$t, 12)
#' tab <- mortality_tabulation(d, time = "t", event = "dead", by = c("sex", "bmi"))
#' tab
#' tabulation_grid(tab, rows = "bmi", cols = "sex")
#' @export
mortality_tabulation <- function(data, time, event, by,
                                 time_units = c("years", "months", "days"),
                                 scale = 1000, weights = NULL, expected = NULL,
                                 margins = TRUE, breaks = NULL,
                                 age_col = NULL, age_breaks = NULL, conf_level = 0.95) {
  time_units <- match.arg(time_units)
  per_year <- c(years = 1, months = 12, days = 365.25)[[time_units]]
  if (!is.data.frame(data)) stop("`data` must be a data frame")
  miss <- setdiff(c(time, event, by, weights, expected, age_col), names(data))
  if (length(miss)) stop("column(s) not found in `data`: ", paste(miss, collapse = ", "))
  if (length(by) < 1) stop("`by` needs at least one covariate")
  if (!is.null(age_breaks) && (is.null(age_col) || !is.null(expected)))
    stop("`age_breaks` needs `age_col` (age at entry, in years) and cannot be combined with `expected`")
  alpha <- 1 - conf_level

  ## ---- assemble the analysis frame ----
  d <- data.frame(.t = as.numeric(data[[time]]) / per_year, .e = as.numeric(data[[event]]))
  for (v in by) {
    x <- data[[v]]
    if (is.numeric(x) && !is.null(breaks[[v]])) {
      x <- cut(x, breaks[[v]], right = FALSE, include.lowest = TRUE)
    } else if (is.numeric(x) && length(unique(x)) > 20) {
      stop("'", v, "' is numeric with many values; supply breaks = list(", v, " = c(...))")
    }
    d[[v]] <- if (is.factor(x)) droplevels(x) else factor(x)
  }
  d$.w <- if (is.null(weights)) 1 else as.numeric(data[[weights]])
  d$.x <- if (is.null(expected)) NA_real_ else as.numeric(data[[expected]])
  if (!is.null(age_breaks)) d$.age0 <- as.numeric(data[[age_col]])
  need <- c(".t", ".e", by, ".w", if (!is.null(expected)) ".x", if (!is.null(age_breaks)) ".age0")
  ok <- stats::complete.cases(d[, need])
  if (any(!ok)) message(sum(!ok), " row(s) dropped for missing time, event, covariate or weight.")
  d <- d[ok, , drop = FALSE]
  if (any(d$.t < 0)) stop("negative follow-up times")
  if (!all(d$.e %in% c(0, 1))) stop("`event` must be 0/1 or TRUE/FALSE")

  ## ---- finest cells: n, deaths, person-years (and expected) ----
  if (is.null(age_breaks)) {
    key <- do.call(paste, c(d[by], sep = "\r"))
    first <- !duplicated(key)
    cells <- d[first, by, drop = FALSE]
    idx <- match(key, key[first])
    cells$n      <- as.numeric(rowsum(d$.w, idx))
    cells$deaths <- as.numeric(rowsum(d$.w * d$.e, idx))
    cells$pyears <- as.numeric(rowsum(d$.w * d$.t, idx))
    if (!is.null(expected)) cells$expected <- as.numeric(rowsum(d$.w * d$.x, idx))
  } else {
    .nhanes_check_pkg("survival")
    age_lab <- paste0("[", utils::head(age_breaks, -1), ",", utils::tail(age_breaks, -1), ")")
    f <- stats::as.formula(paste("survival::Surv(.t, .e) ~ survival::tcut(.age0, age_breaks, labels = age_lab) +",
                                 paste(by, collapse = " + ")))
    py <- survival::pyears(f, data = d, weights = d$.w, scale = 1, data.frame = TRUE)$data
    names(py)[1] <- "attained_age"
    cells <- py[, c(by, "attained_age"), drop = FALSE]
    cells$n <- py$n; cells$deaths <- py$event; cells$pyears <- py$pyears
    by <- c(by, "attained_age")
    for (v in by) {
      cells[[v]] <- factor(cells[[v]], levels = if (v == "attained_age") age_lab else levels(d[[v]]))
    }
    cells <- cells[cells$pyears > 0 | cells$deaths > 0, , drop = FALSE]
  }

  ## ---- every marginal table: aggregate the finest cells over each subset of `by` ----
  sumcols <- c("n", "deaths", "pyears", if (!is.null(expected)) "expected")
  subsets <- if (margins) {
    unlist(lapply(seq_along(by), function(k) utils::combn(by, k, simplify = FALSE)), recursive = FALSE)
  } else {
    list(by)
  }
  out <- lapply(subsets, function(S) {
    k <- do.call(paste, c(cells[S], sep = "\r"))
    first <- !duplicated(k)
    r <- cells[first, S, drop = FALSE]
    r <- cbind(r, as.data.frame(rowsum(as.matrix(cells[sumcols]), match(k, k[first]))))
    for (v in setdiff(by, S)) r[[v]] <- "All"
    cbind(r[by], r[sumcols])
  })
  if (margins) {                                          # grand total: every covariate "All"
    tot <- as.data.frame(as.list(colSums(cells[sumcols])))
    for (v in by) tot[[v]] <- "All"
    out <- c(list(tot[c(by, sumcols)]), out)
  }
  tab <- do.call(rbind, out)
  for (v in by) tab[[v]] <- factor(as.character(tab[[v]]), levels = c(levels(cells[[v]]), "All"))
  tab$n_cov <- rowSums(tab[by] != "All")

  ## ---- rates and exact Poisson intervals ----
  tab$rate <- scale * tab$deaths / tab$pyears
  exact <- is.null(weights)
  lo <- if (exact) ifelse(tab$deaths == 0, 0, stats::qchisq(alpha / 2, 2 * tab$deaths) / 2) else NA_real_
  hi <- if (exact) stats::qchisq(1 - alpha / 2, 2 * (tab$deaths + 1)) / 2 else NA_real_
  tab$rate_lo <- scale * lo / tab$pyears
  tab$rate_hi <- scale * hi / tab$pyears
  if (!is.null(expected)) {
    tab$oe <- tab$deaths / tab$expected
    tab$oe_lo <- lo / tab$expected
    tab$oe_hi <- hi / tab$expected
  }
  tab <- tab[do.call(order, c(list(tab$n_cov), lapply(by, function(v) tab[[v]]))), , drop = FALSE]
  rownames(tab) <- NULL
  attr(tab, "by") <- by
  attr(tab, "scale") <- scale
  attr(tab, "time_units") <- time_units
  attr(tab, "weighted") <- !is.null(weights)
  class(tab) <- c("mortality_tabulation", "data.frame")
  tab
}

# Subsetting a data frame drops custom attributes; keep them (and the class) so a
# subset still prints with its rate scale and `tabulation_grid()` still works.
#' @export
`[.mortality_tabulation` <- function(x, ...) {
  r <- NextMethod()
  if (is.data.frame(r)) {
    for (a in c("by", "scale", "time_units", "weighted")) attr(r, a) <- attr(x, a)
    class(r) <- class(x)
  }
  r
}

#' @export
print.mortality_tabulation <- function(x, digits = 2, ...) {
  cat(sprintf("Mortality tabulation: deaths and person-years of all follow-up (decedents + censored); rate per %s person-years%s\n",
              format(attr(x, "scale"), big.mark = ","),
              if (isTRUE(attr(x, "weighted"))) " [weighted; CIs not valid]" else ""))
  y <- as.data.frame(x)
  y$n_cov <- NULL
  num <- vapply(y, is.numeric, logical(1))
  y[num] <- lapply(y[num], function(z) round(z, digits))
  print(y, row.names = FALSE, ...)
  invisible(x)
}

#' Pivot a mortality tabulation into a two-way grid
#'
#' Extracts one statistic from a [mortality_tabulation()] result as a matrix
#' with one covariate down the rows and another across the columns. The margins
#' (`"All"`) are included as the last row and column.
#'
#' @param tab Output of [mortality_tabulation()] with margins.
#' @param rows,cols Names of the covariates for the rows and columns.
#' @param value The column to tabulate: `"rate"` (default), `"deaths"`,
#'   `"pyears"`, `"n"`, `"oe"`, and so on.
#' @param fixed Optional named list pinning any further covariates to one level
#'   (they default to `"All"`), for example `list(sex = "F")` to tabulate within
#'   women when `tab` has three covariates.
#' @return A matrix with `rows` levels (plus `"All"`) by `cols` levels (plus
#'   `"All"`).
#' @seealso [mortality_tabulation()]
#' @export
tabulation_grid <- function(tab, rows, cols, value = "rate", fixed = NULL) {
  if (!inherits(tab, "mortality_tabulation")) stop("`tab` must come from mortality_tabulation()")
  by <- attr(tab, "by")
  if (!all(c(rows, cols) %in% by)) stop("`rows` and `cols` must be covariates used in the tabulation")
  if (!value %in% names(tab)) stop("`value` is not a column of `tab`")
  y <- as.data.frame(tab)
  for (v in setdiff(by, c(rows, cols))) {
    level <- if (!is.null(fixed[[v]])) fixed[[v]] else "All"
    y <- y[y[[v]] == level, , drop = FALSE]
  }
  g <- tapply(y[[value]], list(y[[rows]], y[[cols]]), sum)
  names(dimnames(g)) <- c(rows, cols)
  g
}
