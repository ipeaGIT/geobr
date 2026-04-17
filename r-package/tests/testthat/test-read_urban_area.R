context("read_urban_area")


# skip tests because they take too much time
testthat::skip_on_cran()
skip_if(Sys.getenv("TEST_ONE") != "")


# Reading the data -----------------------

testthat::test_that("read_urban_area", {

  # read data and check sf object
  test_sf <- read_urban_area(year = 2015)
  testthat::expect_true(is(test_sf, "sf"))

  # filter state code
  test_sf <- read_urban_area(code_muni = 33,year = 2015)
  testthat::expect_true(is(test_sf, "sf"))
  testthat::expect_true(33 %in% unique(test_sf$code_state))

  test_sf <- read_urban_area(code_muni = c(33, 35), year = 2015)
  testthat::expect_true(is(test_sf, "sf"))
  testthat::expect_true(all(c(33, 35) %in% unique(test_sf$code_state)))

  # filter state abbrev
  test_sf <- read_urban_area(code_muni = 'RJ', year = 2015)
  expect_true(is(test_sf, "sf"))
  expect_true('RJ' %in% unique(test_sf$abbrev_state))

  test_sf <- read_urban_area(code_muni = c('RJ', 'SP'), year = 2015)
  testthat::expect_true(is(test_sf, "sf"))
  testthat::expect_true(all(c('RJ', 'SP') %in% unique(test_sf$abbrev_state)))

})



# ERRORS and messagens  -----------------------
test_that("read_urban_area", {

  # Wrong year
  testthat::expect_error(read_urban_area())
  testthat::expect_error(read_urban_area(year=9999999))

  # filter state
  testthat::expect_error(read_urban_area(code_muni = c('RJ', 33), year = 2015))
  testthat::expect_error(read_urban_area(code_muni = 'banana', year = 2015))
  testthat::expect_error(read_urban_area(code_muni = 999999999, year = 2015))

})
