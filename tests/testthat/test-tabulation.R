# tests/testthat/test-tabulation.R

make_tab_data <- function(n = 4000, seed = 5) {
  set.seed(seed)
  d <- data.frame(sex = sample(c("F", "M"), n, TRUE), grp = sample(c("a", "b", "c"), n, TRUE),
                  age0 = runif(n, 30, 70), w = runif(n, 0.5, 3))
  rate <- 0.01 * ifelse(d$sex == "M", 1.5, 1) * c(a = 1, b = 2, c = 3)[d$grp]
  t_death <- rexp(n, rate)
  t_cens <- runif(n, 2, 15)
  d$time <- pmin(t_death, t_cens)
  d$event <- as.integer(t_death <= t_cens)
  d$exp_deaths <- rate * d$time
  d
}

test_that("exposure basis is everyone's follow-up and deaths are conserved", {
  d <- make_tab_data()
  tab <- mortality_tabulation(d, "time", "event", by = c("sex", "grp"))
  fine <- tab[tab$n_cov == 2, ]
  expect_equal(nrow(fine), 6L)
  expect_equal(sum(fine$pyears), sum(d$time))     # decedents AND censored contribute
  expect_equal(sum(fine$deaths), sum(d$event))
  cell <- fine[fine$sex == "M" & fine$grp == "c", ]
  h <- d[d$sex == "M" & d$grp == "c", ]
  expect_equal(cell$rate, 1000 * sum(h$event) / sum(h$time))
})

test_that("results agree with survival::pyears and poisson.test", {
  skip_if_not_installed("survival")
  d <- make_tab_data()
  tab <- mortality_tabulation(d, "time", "event", by = c("sex", "grp"))
  cell <- tab[tab$n_cov == 2 & tab$sex == "M" & tab$grp == "c", ]
  py <- survival::pyears(survival::Surv(time, event) ~ sex + grp, data = d, scale = 1)
  expect_equal(as.numeric(py$pyears["M", "c"]), cell$pyears)
  expect_equal(as.numeric(py$event["M", "c"]), cell$deaths)
  ci <- stats::poisson.test(cell$deaths, cell$pyears)$conf.int * 1000
  expect_equal(c(cell$rate_lo, cell$rate_hi), as.numeric(ci))
})

test_that("margins, grand total and ordering are correct", {
  d <- make_tab_data()
  d$half <- ifelse(d$age0 < 50, "young", "old")
  t3 <- mortality_tabulation(d, "time", "event", by = c("sex", "grp", "half"))
  expect_equal(sum(t3$n_cov == 0), 1L)
  expect_equal(sum(t3$n_cov == 1), 2L + 3L + 2L)
  expect_equal(sum(t3$n_cov == 2), 6L + 4L + 6L)
  expect_equal(sum(t3$n_cov == 3), 12L)
  expect_false(is.unsorted(t3$n_cov))
  tot <- t3[t3$n_cov == 0, ]
  expect_equal(tot$deaths, sum(d$event))
  expect_equal(tot$rate, 1000 * sum(d$event) / sum(d$time))
  m1 <- t3[t3$n_cov == 1 & t3$grp != "All", ]
  expect_equal(m1$rate[m1$grp == "a"], 1000 * sum(d$event[d$grp == "a"]) / sum(d$time[d$grp == "a"]))
  f1 <- t3[t3$n_cov == 1 & t3$sex != "All", ]
  expect_identical(as.character(f1$sex), c("F", "M"))
  expect_equal(nrow(mortality_tabulation(d, "time", "event", by = c("sex", "grp"), margins = FALSE)), 6L)
})

test_that("time units, weights, expected and numeric breaks work", {
  d <- make_tab_data()
  tab <- mortality_tabulation(d, "time", "event", by = "grp")
  months <- mortality_tabulation(transform(d, time = time * 12), "time", "event",
                                 by = "grp", time_units = "months")
  expect_equal(months$rate, tab$rate)

  tw <- mortality_tabulation(d, "time", "event", by = "sex", weights = "w")
  expect_true(all(is.na(tw$rate_lo)))
  expect_equal(sum(tw$pyears[tw$n_cov == 1]), sum(d$w * d$time))

  te <- mortality_tabulation(d, "time", "event", by = c("sex", "grp"), expected = "exp_deaths")
  expect_equal(te$oe, te$deaths / te$expected)
  expect_lt(abs(te$oe[te$n_cov == 2 & te$sex == "M" & te$grp == "c"] - 1), 0.25)

  tb <- mortality_tabulation(d, "time", "event", by = "age0", breaks = list(age0 = c(30, 40, 50, 60, 70)))
  expect_equal(nlevels(tb$age0), 5L)                 # four bands plus "All"
  expect_equal(sum(tb$deaths[tb$n_cov == 1]), sum(d$event))
  expect_error(mortality_tabulation(d, "time", "event", by = "age0"), "breaks")
})

test_that("attained-age bands conserve person-years and deaths", {
  skip_if_not_installed("survival")
  d <- make_tab_data()
  ta <- mortality_tabulation(d, "time", "event", by = "sex",
                             age_col = "age0", age_breaks = c(30, 40, 50, 60, 70, 100))
  cells <- ta[ta$n_cov == 2, ]
  expect_equal(sum(cells$pyears), sum(d$time))
  expect_equal(sum(cells$deaths), sum(d$event))
  expect_error(mortality_tabulation(d, "time", "event", by = "sex", age_col = "age0",
                                    age_breaks = c(30, 100), expected = "exp_deaths"), "expected")
})

test_that("missing data are reported and bad input is rejected", {
  d <- make_tab_data()
  d$grp[1:10] <- NA
  expect_message(mortality_tabulation(d, "time", "event", by = "grp"), "10 row")
  expect_error(mortality_tabulation(d, "nope", "event", by = "grp"), "not found")
  d2 <- make_tab_data(); d2$event[1] <- 2
  expect_error(mortality_tabulation(d2, "time", "event", by = "grp"), "0/1")
})

test_that("tabulation_grid pivots two covariates and respects fixed levels", {
  d <- make_tab_data()
  d$half <- ifelse(d$age0 < 50, "young", "old")
  t3 <- mortality_tabulation(d, "time", "event", by = c("sex", "grp", "half"))
  g <- tabulation_grid(t3, rows = "grp", cols = "sex")
  expect_equal(dim(g), c(4L, 3L))
  expect_equal(g["All", "All"], 1000 * sum(d$event) / sum(d$time))
  gf <- tabulation_grid(t3, rows = "grp", cols = "sex", fixed = list(half = "young"))
  y <- d[d$half == "young" & d$sex == "F" & d$grp == "a", ]
  expect_equal(gf["a", "F"], 1000 * sum(y$event) / sum(y$time))
  expect_error(tabulation_grid(t3, rows = "nope", cols = "sex"), "covariates")
})

test_that("print method reports the basis and the scale", {
  d <- make_tab_data()
  tab <- mortality_tabulation(d, "time", "event", by = "sex")
  out <- paste(capture.output(print(tab)), collapse = "\n")
  expect_match(out, "decedents \\+ censored")
  expect_match(out, "1,000 person-years")
})
