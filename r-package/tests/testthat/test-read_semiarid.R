context("read_semiarid")


# skip tests because they take too much time
testthat::skip_on_cran()
skip_if(Sys.getenv("TEST_ONE") != "")


# Reading the data -----------------------

test_that("read_semiarid", {

  # read data
  test_sf <- read_semiarid(year=2017)

  # check sf object
  expect_true(is(test_sf, "sf"))

  # check number of micro
  expect_equal(test_sf %>% length(), 5)

})




# ERRORS and messagens  -----------------------
test_that("read_semiarid", {

  # Wrong year
  expect_error(read_semiarid(year=9999999))

})
