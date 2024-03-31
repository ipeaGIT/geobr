context("read_urban_area")


# skip tests because they take too much time
testthat::skip_on_cran()
skip_if(Sys.getenv("TEST_ONE") != "")


# Reading the data -----------------------

test_that("read_urban_area", {

  # read data and check sf object
  test_sf <- read_urban_area()
  expect_true(is(test_sf, "sf"))

  # filter state code
  test_sf <- read_urban_area(code_state = 33)
  expect_true(is(test_sf, "sf"))
  expect_true(33 %in% unique(test_sf$code_state))

  test_sf <- read_urban_area(code_state = c(33, 35))
  expect_true(is(test_sf, "sf"))
  expect_true(all(c(33, 35) %in% unique(test_sf$code_state)))

  # filter state abbrev
  test_sf <- read_urban_area(code_state = 'RJ')
  expect_true(is(test_sf, "sf"))
  expect_true('RJ' %in% unique(test_sf$abbrev_state))

  test_sf <- read_urban_area(code_state = c('RJ', 'SP'))
  expect_true(is(test_sf, "sf"))
  expect_true(all(c('RJ', 'SP') %in% unique(test_sf$abbrev_state)))

})



# ERRORS and messagens  -----------------------
test_that("read_urban_area", {

  # Wrong year
  expect_error(read_urban_area(year=9999999))

  # filter state
  expect_error(read_urban_area(code_state = c('RJ', 33)))
  expect_error(read_urban_area(code_state = 'banana'))
  expect_error(read_urban_area(code_state = 999999999))

})
