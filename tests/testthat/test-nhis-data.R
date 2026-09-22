# tests/testthat/test-nhis-data.R
# All tests here are offline (registry lookups, URL construction) -- no
# network access, same convention as test-mortality.R/test-nhis-mortality.R.
# nhis_download() itself is only exercised via its \donttest{} roxygen
# example, not here.

test_that("nhis_data_years returns expected years and modules", {
  either <- nhis_data_years()
  expect_type(either, "character")
  expect_true("1986" %in% either)
  expect_true("2018" %in% either)
  expect_equal(length(either), 33L)

  hh <- nhis_data_years("household")
  expect_false("1989" %in% hh)   # the confirmed 1989 Household gap
  expect_equal(length(hh), 32L)

  px <- nhis_data_years("person")
  expect_true("1989" %in% px)    # Person is unaffected that year
  expect_equal(length(px), 33L)
})

test_that(".nhis_data_zip_url builds the flat-year URL pattern", {
  expect_equal(
    nhanesR:::.nhis_data_zip_url("1986", "household"),
    "https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NHIS/1986/HOUSEHLD.zip"
  )
  expect_equal(
    nhanesR:::.nhis_data_zip_url("1997", "person"),
    "https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NHIS/1997/PERSONSX.zip"
  )
})

test_that(".nhis_data_zip_url and .nhis_data_sas_url handle the 2004 subdirectory anomaly", {
  expect_equal(
    nhanesR:::.nhis_data_zip_url("2004", "household"),
    "https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NHIS/2004/household/HOUSEHLD.zip"
  )
  expect_equal(
    nhanesR:::.nhis_data_sas_url("2004", "person"),
    "https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Program_Code/NHIS/2004/person/PERSONSX.sas"
  )
})

test_that(".nhis_data_registry_row errors clearly on the 1989 household gap", {
  expect_error(
    nhanesR:::.nhis_data_registry_row("1989", "household"),
    regexp = "not available"
  )
  # Person for the same year is unaffected
  expect_silent(nhanesR:::.nhis_data_registry_row("1989", "person"))
})

test_that(".nhis_data_registry_row errors clearly on an unregistered year", {
  expect_error(
    nhanesR:::.nhis_data_registry_row("2019", "household"),
    regexp = "No .* registered"
  )
})

test_that("nhis_download validates its module argument", {
  expect_error(nhis_download("family"), regexp = "should be one of")
})

# ── Pre-1997 placeholder-name crosswalk (1986-1992) ─────────────────────────────

test_that(".nhis_pre1997_crosswalk covers exactly 1986-1992, not the full span", {
  cw <- nhanesR:::.nhis_pre1997_crosswalk
  expect_setequal(unique(cw$year), as.character(1986:1992))
  expect_true(all(cw$module %in% c("household", "person")))
})

test_that(".nhis_pre1997_crosswalk has known-correct 1986 labels", {
  cw <- nhanesR:::.nhis_pre1997_crosswalk
  row <- cw[cw$year == "1986" & cw$module == "household" & cw$varname == "HH_22", ]
  expect_equal(nrow(row), 1L)
  expect_equal(row$label, "TYPE OF LIVING QUARTERS:")

  # Person's copy of a shared household-level prefix item (positions 22-24
  # repeat on every person record) -- same label as the household version.
  px_row <- cw[cw$year == "1986" & cw$module == "person" & cw$varname == "PX_22", ]
  expect_equal(px_row$label, "TYPE OF LIVING QUARTERS:")
})

test_that(".nhis_apply_pre1997_labels attaches labels for a covered year/module", {
  df <- data.frame(HH_22 = 1:3, HH_24 = 4:6, UNKNOWN_COL = 7:9)
  out <- nhanesR:::.nhis_apply_pre1997_labels(df, "1986", "household")
  expect_equal(attr(out$HH_22, "label"), "TYPE OF LIVING QUARTERS:")
  expect_equal(attr(out$HH_24, "label"), "HAS TELEPHONE")
  expect_null(attr(out$UNKNOWN_COL, "label"))
})

test_that(".nhis_apply_pre1997_labels is a no-op outside 1986-1992", {
  df <- data.frame(HH_22 = 1:3)
  out <- nhanesR:::.nhis_apply_pre1997_labels(df, "1993", "household")
  expect_identical(df, out)
})

# ── SAS layout validation (overlapping/mistyped column declarations) ───────────
# Synthetic fixtures, not the real cached CDC files -- these mirror the real
# defect patterns found in PERSONSX_1994.sas (2026-09-22): a combined field
# declared alongside overlapping sub-parts (the BIRTH/BIRTHMO/BIRTHYR case),
# and a position typo that overruns the file's own declared LRECL (the
# HEP12WP case).

.write_sas_fixture <- function(lines) {
  tf <- tempfile(fileext = ".sas")
  writeLines(lines, tf)
  tf
}

test_that(".nhis_sas_literal_positions extracts a clean layout", {
  tf <- .write_sas_fixture(c(
    "INFILE ASCIIDAT LRECL=10;",
    "INPUT",
    "   RECTYPE   1-2      YEAR   3-4",
    "   SEX       5-5      AGE    6-7",
    "   ;"
  ))
  on.exit(unlink(tf))
  spec <- nhanesR:::.nhis_sas_literal_positions(tf)
  expect_equal(spec$varname, c("RECTYPE", "YEAR", "SEX", "AGE"))
  expect_equal(spec$end, c(2L, 4L, 5L, 7L))
})

test_that(".nhis_sas_literal_positions handles space-padded dashes (pre-1990 style)", {
  tf <- .write_sas_fixture(c(
    "INFILE ASCIIDAT LRECL=10;",
    "INPUT",
    "   RECTYPE       1 - 2         YEAR          3 - 4",
    "   ;"
  ))
  on.exit(unlink(tf))
  spec <- nhanesR:::.nhis_sas_literal_positions(tf)
  expect_equal(spec$varname, c("RECTYPE", "YEAR"))
  expect_equal(spec$start, c(1L, 3L))
  expect_equal(spec$end, c(2L, 4L))
})

test_that(".nhis_sas_lrecl extracts the declared record length", {
  tf <- .write_sas_fixture(c("INFILE ASCIIDAT LRECL=335;", "INPUT", "   X 1-2", "   ;"))
  on.exit(unlink(tf))
  expect_equal(nhanesR:::.nhis_sas_lrecl(tf), 335L)
})

test_that(".nhis_sas_validate_and_fix drops a subset-overlapping combined field", {
  tf <- .write_sas_fixture(c(
    "INFILE ASCIIDAT LRECL=15;",
    "INPUT",
    "   RECTYPE   1-2         YEAR      3-4",
    "   BIRTH  $  5-10        BIRTHMO $ 5-6",
    "   BIRTHYR $  7-10       SEX       11-11",
    "   ;"
  ))
  on.exit(unlink(tf))
  spec <- nhanesR:::.nhis_sas_validate_and_fix(tf, "1994", "person")
  expect_false("BIRTHMO" %in% spec$varname)
  expect_false("BIRTHYR" %in% spec$varname)
  expect_true("BIRTH" %in% spec$varname)
  expect_equal(max(spec$end), 11L)
})

test_that(".nhis_sas_validate_and_fix errors on an unfixable overrun rather than guessing", {
  tf <- .write_sas_fixture(c(
    "INFILE ASCIIDAT LRECL=10;",
    "INPUT",
    "   RECTYPE   1-2      BADVAR   5-20",
    "   ;"
  ))
  on.exit(unlink(tf))
  expect_error(
    nhanesR:::.nhis_sas_validate_and_fix(tf, "1994", "person"),
    regexp = "declared LRECL"
  )
})

test_that(".nhis_sas_validate_and_fix is a clean no-op for a defect-free layout", {
  tf <- .write_sas_fixture(c(
    "INFILE ASCIIDAT LRECL=10;",
    "INPUT",
    "   RECTYPE   1-2      YEAR   3-4",
    "   SEX       5-5",
    "   ;"
  ))
  on.exit(unlink(tf))
  spec <- nhanesR:::.nhis_sas_validate_and_fix(tf, "1986", "household")
  expect_equal(nrow(spec), 3L)
  expect_equal(max(spec$end), 5L)
})
