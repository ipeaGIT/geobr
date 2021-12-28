context("read_urban_area")


# skip tests because they take too much time
testthat::skip_on_cran()
skip_if(Sys.getenv("TEST_ONE") != "")


# Reading the data -----------------------

test_that("read_urban_area", {

  # read data and check sf object
  test_sf <- read_urban_area()

  expect_true(is(test_sf, "sf"))

})



# ERRORS and messagens  -----------------------
test_that("read_urban_area", {

  # Wrong year
  expect_error(read_urban_area(year=9999999))

})
