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

# ── Pre-1997 placeholder-name crosswalk (1986-1991) ─────────────────────────────

test_that(".nhis_pre1997_crosswalk covers exactly 1986-1991, not the full span", {
  cw <- nhanesR:::.nhis_pre1997_crosswalk
  expect_setequal(unique(cw$year), as.character(1986:1991))
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

test_that(".nhis_apply_pre1997_labels is a no-op outside 1986-1991", {
  df <- data.frame(HH_22 = 1:3)
  out <- nhanesR:::.nhis_apply_pre1997_labels(df, "1993", "household")
  expect_identical(df, out)
})
