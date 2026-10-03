# tests/testthat/test-mortality.R

# ── nhanes_lmf_cycles() ────────────────────────────────────────────────────────

test_that("nhanes_lmf_cycles returns expected cycles", {
  cycs <- nhanes_lmf_cycles()
  expect_type(cycs, "character")
  expect_true("1999-2000" %in% cycs)
  expect_true("2017-2018" %in% cycs)
  expect_true("1988-1994" %in% cycs)
})

# ── nhanes_ucod_labels() ───────────────────────────────────────────────────────

test_that("nhanes_ucod_labels returns well-formed table", {
  tbl <- nhanes_ucod_labels()
  expect_s3_class(tbl, "data.frame")
  expect_named(tbl, c("code", "label", "icd10_range"))
  expect_true("001" %in% tbl$code)   # Diseases of heart
  expect_true("007" %in% tbl$code)   # Diabetes mellitus
  expect_equal(nrow(tbl), 11L)
})

# ── nhanes_survival_prep() - unit tests with synthetic data ────────────────────

make_linked_data <- function(n = 200) {
  set.seed(42)
  data.frame(
    SEQN       = seq_len(n),
    cycle      = rep(c("2013-2014", "2015-2016"), each = n / 2),
    ELIGSTAT   = sample(c(1L, 1L, 1L, 2L, 3L), n, replace = TRUE),
    MORTSTAT   = sample(c(0L, 1L), n, replace = TRUE, prob = c(0.85, 0.15)),
    UCOD_LEADING = sample(c("001","002","003", NA_character_), n, replace = TRUE),
    PERMTH_INT = round(runif(n, 12, 240), 1),
    PERMTH_EXM = round(runif(n, 12, 240), 1),
    WTMEC2YR   = runif(n, 10000, 100000),
    SDMVPSU    = sample(1:2, n, replace = TRUE),
    SDMVSTRA   = sample(1:14, n, replace = TRUE),
    stringsAsFactors = FALSE
  )
}

test_that("nhanes_survival_prep drops ineligible with warning", {
  dat <- make_linked_data(200)
  n_ineligible <- sum(dat$ELIGSTAT != 1L)

  # two warnings are expected: the removal of ineligible participants and the
  # multi-cycle follow-up caveat (the test data span two cycles)
  expect_warning(
    expect_warning(
      out <- nhanes_survival_prep(dat, origin = "exam", weight_var = "WTMEC2YR"),
      regexp = "ineligible"
    ),
    regexp = "asym|censor|cycle", ignore.case = TRUE
  )

  expect_equal(nrow(out), 200L - n_ineligible)
  expect_true(all(out$ELIGSTAT == 1L))
})

test_that("nhanes_survival_prep creates time and event columns", {
  dat <- make_linked_data(200)
  suppressWarnings({
    out <- nhanes_survival_prep(dat, origin = "exam", time_unit = "months")
  })
  expect_true("time" %in% names(out))
  expect_true("event" %in% names(out))
  expect_true(all(out$event %in% c(0L, 1L)))
  expect_true(all(out$time > 0, na.rm = TRUE))
})

test_that("time_unit = 'years' divides by 12", {
  dat <- make_linked_data(200)
  suppressWarnings({
    out_m <- nhanes_survival_prep(dat, origin = "exam", time_unit = "months")
    out_y <- nhanes_survival_prep(dat, origin = "exam", time_unit = "years")
  })
  expect_equal(out_y$time, out_m$time / 12, tolerance = 1e-9)
})

test_that("origin = 'interview' uses PERMTH_INT", {
  dat <- make_linked_data(200)
  suppressWarnings({
    out <- nhanes_survival_prep(dat, origin = "interview")
  })
  elig <- dat[dat$ELIGSTAT == 1L, ]
  expect_equal(out$time, elig$PERMTH_INT)
})

test_that("origin = 'exam' uses PERMTH_EXM", {
  dat <- make_linked_data(200)
  suppressWarnings({
    out <- nhanes_survival_prep(dat, origin = "exam")
  })
  elig <- dat[dat$ELIGSTAT == 1L, ]
  expect_equal(out$time, elig$PERMTH_EXM)
})

test_that("survey_weight is the pooled-cycle weight when 2-year weights span several cycles", {
  dat <- make_linked_data(200)                    # two cycles: 2013-2014 and 2015-2016
  suppressWarnings(suppressMessages({
    out <- nhanes_survival_prep(dat, origin = "exam", weight_var = "WTMEC2YR")
  }))
  expect_true("survey_weight" %in% names(out))
  elig <- dat[dat$ELIGSTAT == 1L, ]
  expect_equal(out$survey_weight, elig$WTMEC2YR / 2)         # CDC guidance: each 2-year weight / number of cycles
  expect_equal(out$survey_weight_2yr_raw, elig$WTMEC2YR)     # the original is preserved
})

test_that("survey_weight is unchanged for a single cycle", {
  dat <- make_linked_data(200)
  dat$cycle <- "2015-2016"
  suppressWarnings(suppressMessages({
    out <- nhanes_survival_prep(dat, origin = "exam", weight_var = "WTMEC2YR")
  }))
  elig <- dat[dat$ELIGSTAT == 1L, ]
  expect_equal(out$survey_weight, elig$WTMEC2YR)
  expect_false("survey_weight_2yr_raw" %in% names(out))
})

test_that("a weight the user has already pooled is passed through unscaled", {
  dat <- make_linked_data(200)                    # several cycles, but the weight is not a *2YR column
  dat$WTMEC_adj <- dat$WTMEC2YR / 10              # e.g. a hand-pooled weight as in a 10-cycle analysis
  suppressWarnings(suppressMessages({
    out <- nhanes_survival_prep(dat, origin = "exam", weight_var = "WTMEC_adj")
  }))
  elig <- dat[dat$ELIGSTAT == 1L, ]
  expect_equal(out$survey_weight, elig$WTMEC_adj)            # no second round of pooling
  expect_false("survey_weight_2yr_raw" %in% names(out))
})

test_that("a 4-year weight across more than two cycles warns and is left unscaled", {
  dat <- make_linked_data(300)
  dat$cycle <- rep(c("2011-2012", "2013-2014", "2015-2016"), each = 100)
  dat$WTMEC4YR <- dat$WTMEC2YR * 0.5
  msgs <- character(0)
  out <- withCallingHandlers(
    suppressMessages(nhanes_survival_prep(dat, origin = "exam", weight_var = "WTMEC4YR")),
    warning = function(w) { msgs <<- c(msgs, conditionMessage(w)); invokeRestart("muffleWarning") }
  )
  expect_true(any(grepl("WTMEC4YR.*3 pooled cycles|3 pooled cycles", msgs)))
  elig <- dat[dat$ELIGSTAT == 1L, ]
  expect_equal(out$survey_weight, elig$WTMEC4YR)       # warned about, not rescaled
})

test_that("invalid weight_var triggers error", {
  dat <- make_linked_data(200)
  expect_error(
    suppressWarnings(
      nhanes_survival_prep(dat, origin = "exam", weight_var = "WTMEC99YR")
    ),
    regexp = "WTMEC99YR"
  )
})

test_that("cause-specific event column is created correctly", {
  dat <- make_linked_data(200)
  suppressWarnings({
    out <- nhanes_survival_prep(dat, origin = "exam", cause = "001")
  })
  expect_true("event_cause" %in% names(out))
  expect_true(all(out$event_cause %in% c(0L, 1L)))
  # event_cause must be a subset of event
  expect_true(all(out$event_cause <= out$event))
})

test_that("invalid cause code triggers error", {
  dat <- make_linked_data(200)
  expect_error(
    suppressWarnings(
      nhanes_survival_prep(dat, origin = "exam", cause = "999")
    ),
    regexp = "Invalid"
  )
})

test_that("multi-cycle asymmetric follow-up warning is emitted", {
  dat <- make_linked_data(200)
  expect_warning(
    expect_warning(
      nhanes_survival_prep(dat, origin = "exam"),
      regexp = "asym|censor|cycle", ignore.case = TRUE
    ),
    regexp = "ineligible"                 # the removal of ineligible participants warns as well
  )
})

test_that("metadata attribute is attached to output", {
  dat <- make_linked_data(200)
  suppressWarnings({
    out <- nhanes_survival_prep(dat, origin = "exam", time_unit = "years",
                                weight_var = "WTMEC2YR")
  })
  meta <- attr(out, ".nhanes_survival")
  expect_type(meta, "list")
  expect_equal(meta$origin, "exam")
  expect_equal(meta$time_unit, "years")
  expect_equal(meta$censor_date, "2019-12-31")
})

# ── nhanes_followup_summary() ─────────────────────────────────────────────────

test_that("nhanes_followup_summary returns one row per cycle", {
  dat <- make_linked_data(200)
  suppressWarnings({
    out <- nhanes_survival_prep(dat, origin = "exam")
    summ <- nhanes_followup_summary(out)
  })
  expect_s3_class(summ, "data.frame")
  expect_equal(nrow(summ), length(unique(out$cycle)))
  expect_true("event_rate_pct" %in% names(summ))
  expect_true("median_followup" %in% names(summ))
})
