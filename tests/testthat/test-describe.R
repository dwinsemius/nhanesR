`[.labelled` <- function(x, ...) {
  lbl <- attr(x, "label", exact = TRUE)
  y <- NextMethod("[")
  attr(y, "label") <- lbl
  class(y) <- class(x)
  y
}

sort.labelled <- function(x, decreasing = FALSE, ..., na.last = NA) {
  lbl <- attr(x, "label", exact = TRUE)
  cls <- class(x)
  y <- sort(as.vector(x), decreasing = decreasing, ..., na.last = na.last)
  attr(y, "label") <- lbl
  class(y) <- cls
  y
}

test_that("NH_unlabel removes labels from data frame columns", {
  d <- data.frame(
    RIDAGEYR = 40:50,
    sex = factor(c("female", "male", "female", "male", "female", "male",
                   "female", "male", "female", "male", "female"))
  )
  attr(d$RIDAGEYR, "label") <- "Age (years)"
  attr(d$sex, "label") <- "Sex"

  out <- NH_unlabel(d)

  expect_null(attr(out$RIDAGEYR, "label"))
  expect_null(attr(out$sex, "label"))
  expect_s3_class(out$sex, "factor")
  expect_equal(out$RIDAGEYR, d$RIDAGEYR)
})

test_that("NH_unlabel fixes labelled scalar recycling in newdata", {
  age <- structure(
    40:50,
    label = "Age (years)",
    class = c("labelled", "integer")
  )

  ref_age <- median(age)

  expect_s3_class(ref_age, "labelled")
  expect_error(
    data.frame(grid = 1:5, RIDAGEYR = ref_age),
    regexp = "differing number of rows"
  )

  nd <- data.frame(grid = 1:5, RIDAGEYR = NH_unlabel(ref_age))

  expect_equal(nd$RIDAGEYR, rep(45, 5))
  expect_null(attr(nd$RIDAGEYR, "label"))
  expect_false(inherits(nd$RIDAGEYR, "labelled"))
})