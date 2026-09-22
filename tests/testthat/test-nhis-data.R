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
