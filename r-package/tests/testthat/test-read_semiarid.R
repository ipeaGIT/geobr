context("read_semiarid")


# skip tests because they take too much time
testthat::skip_on_cran()
skip_if(Sys.getenv("TEST_ONE") != "")


# Reading the data -----------------------

test_that("read_semiarid", {


  # check sf object
  test_sf <- read_semiarid(year=2017)
  expect_true(is(test_sf, "sf"))

  test_sf <- read_semiarid()
  expect_true(is(test_sf, "sf"))

})




# ERRORS and messagens  -----------------------
test_that("read_semiarid", {

  # Wrong year
  expect_error(read_semiarid(year=9999999))

})
