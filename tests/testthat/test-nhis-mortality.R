# tests/testthat/test-nhis-mortality.R

# ── nhis_lmf_years() ───────────────────────────────────────────────────────────

test_that("nhis_lmf_years returns expected years", {
  yrs <- nhis_lmf_years()
  expect_type(yrs, "character")
  expect_equal(length(yrs), 33L)
  expect_true("1986" %in% yrs)
  expect_true("2018" %in% yrs)
  expect_false("2019" %in% yrs)
})

# ── .nhis_parse_lmf_dat() — fixed-width column-position correctness ────────────

# One synthetic fixed-width record, hand-built to the exact NCHS column
# layout (verified against NCHS's own R_ReadInProgramAllSurveys.R):
# PUBLICID(1-14) ELIGSTAT(15) MORTSTAT(16) UCOD_LEADING(17-19) DIABETES(20)
# HYPERTEN(21) DODQTR(22) DODYEAR(23-26) WGT_NEW(27-34) SA_WGT_NEW(35-42)
.make_nhis_dat_line <- function(publicid, eligstat, mortstat, ucod, diabetes,
                                hyperten, dodqtr, dodyear, wgt_new, sa_wgt_new) {
  paste0(
    formatC(publicid, width = 14, flag = "-"),
    formatC(eligstat, width = 1),
    formatC(mortstat, width = 1),
    formatC(ucod,     width = 3),
    formatC(diabetes, width = 1),
    formatC(hyperten, width = 1),
    formatC(dodqtr,   width = 1),
    formatC(dodyear,  width = 4),
    formatC(wgt_new,  width = 8),
    formatC(sa_wgt_new, width = 8)
  )
}

test_that(".nhis_parse_lmf_dat reads fields at the correct column positions", {
  lines <- c(
    .make_nhis_dat_line("A00000000001", "1", "1", "001", "0", "1", "2", "2010",
                        "1234.56", "2345.67"),
    .make_nhis_dat_line("A00000000002", "1", "0", ".", ".", ".", ".", ".",
                        "9876.54", ".")
  )
  tmp <- tempfile(fileext = ".dat")
  writeLines(lines, tmp)
  on.exit(unlink(tmp))

  df <- .nhis_parse_lmf_dat(tmp, year = "2010")

  expect_equal(nrow(df), 2L)
  expect_equal(df$PUBLICID, c("A00000000001", "A00000000002"), ignore_attr = TRUE)
  expect_equal(df$ELIGSTAT, c(1L, 1L), ignore_attr = TRUE)
  expect_equal(df$MORTSTAT, c(1L, 0L), ignore_attr = TRUE)
  expect_equal(df$UCOD_LEADING, c("001", NA_character_), ignore_attr = TRUE)
  expect_equal(df$DIABETES, c(0L, NA_integer_), ignore_attr = TRUE)
  expect_equal(df$HYPERTEN, c(1L, NA_integer_), ignore_attr = TRUE)
  expect_equal(df$DODQTR, c(2L, NA_integer_), ignore_attr = TRUE)
  expect_equal(df$DODYEAR, c(2010L, NA_integer_), ignore_attr = TRUE)
  expect_equal(df$WGT_NEW, c(1234.56, 9876.54), ignore_attr = TRUE)
  expect_equal(df$SA_WGT_NEW, c(2345.67, NA_real_), ignore_attr = TRUE)
  expect_true(all(df$.nhis_lmf_year == "2010"))
})

# ── nhis_mortality_parse() / nhis_mortality_link() — offline, cache-only ───────

test_that("nhis_mortality_parse + nhis_mortality_link work end-to-end offline", {
  old_dir <- getOption("nhanesR.cache_dir")
  tmp_cache <- file.path(tempdir(), paste0("nhanesR_test_", Sys.getpid()))
  options(nhanesR.cache_dir = tmp_cache, nhanesR.verbose = FALSE)
  on.exit(options(nhanesR.cache_dir = old_dir, nhanesR.verbose = TRUE))

  dat_path <- .nhis_lmf_dat_path("2010")
  dir.create(dirname(dat_path), recursive = TRUE, showWarnings = FALSE)
  lines <- c(
    .make_nhis_dat_line("A00000000001", "1", "1", "001", "0", "1", "2", "2010",
                        "1234.56", "2345.67"),
    .make_nhis_dat_line("A00000000002", "1", "0", ".", ".", ".", ".", ".",
                        "9876.54", ".")
  )
  writeLines(lines, dat_path)

  lmf <- nhis_mortality_parse("2010", download = FALSE)
  expect_type(lmf, "list")
  expect_equal(nrow(lmf[["2010"]]), 2L)

  nhis_data <- data.frame(
    PUBLICID = c("A00000000001", "A00000000002", "A00000000099"),
    SRVY_YR  = c(2010, 2010, 2010),
    age      = c(45, 60, 70),
    stringsAsFactors = FALSE
  )

  out <- suppressWarnings(nhis_mortality_link(nhis_data, download = FALSE))
  expect_true("MORTSTAT" %in% names(out))
  expect_equal(out$MORTSTAT[out$PUBLICID == "A00000000001"], 1L)
  expect_equal(out$MORTSTAT[out$PUBLICID == "A00000000002"], 0L)
  expect_true(is.na(out$MORTSTAT[out$PUBLICID == "A00000000099"]))

  expect_warning(
    nhis_mortality_link(nhis_data, download = FALSE),
    regexp = "no matching LMF record"
  )
})

test_that("nhis_mortality_link errors informatively on missing ID column", {
  expect_error(
    nhis_mortality_link(data.frame(x = 1), years = "2010", download = FALSE),
    regexp = "PUBLICID"
  )
})

test_that(".nhis_validate_lmf_years rejects years without a public-use LMF", {
  expect_error(
    .nhis_validate_lmf_years("2019"),
    regexp = "not available"
  )
})
