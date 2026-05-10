context("read_metro_area")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()

# Reading the data -----------------------

testthat::test_that("read_metro_area", {

  # read data and check sf object
  testthat::expect_true(is(read_metro_area(year=1970), "sf"))
  test_sf <- read_metro_area(year=2024)
  testthat::expect_true(is(test_sf, "sf"))

  # filter state code
  test_sf <- read_metro_area(year=2024, code_state = 33)
  testthat::expect_true(is(test_sf, "sf"))
  testthat::expect_true(33 %in% unique(test_sf$code_state))

  test_sf <- read_metro_area(year=2024, code_state = c(33, 35))
  testthat::expect_true(is(test_sf, "sf"))
  testthat::expect_true(all(c(33, 35) %in% unique(test_sf$code_state)))

  # filter state abbrev
  test_sf <- read_metro_area(year=2024, code_state = 'RJ')
  testthat::expect_true(is(test_sf, "sf"))
  testthat::expect_true('RJ' %in% unique(test_sf$abbrev_state))

  test_sf <- read_metro_area(year=2024, code_state = c('RJ', 'SP'))
  testthat::expect_true(is(test_sf, "sf"))
  testthat::expect_true(all(c('RJ', 'SP') %in% unique(test_sf$abbrev_state)))

})



# ERRORS and messagens  -----------------------
testthat::test_that("read_metro_area", {

  # Wrong year
  testthat::expect_error(read_metro_area())
  testthat::expect_error(read_metro_area(year=9999999))
  testthat::expect_error(read_metro_area(year="xxx"))

  # filter state
  testthat::expect_error(read_metro_area(code_state = c('RJ', 33)))
  testthat::expect_error(read_metro_area(code_state = 'banana'))
  testthat::expect_error(read_metro_area(code_state = 999999999))

})
