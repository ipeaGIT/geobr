context("read_urban_concentrations")


# skip tests because they take too much time
testthat::skip_on_cran()
skip_if(Sys.getenv("TEST_ONE") != "")


# Reading the data -----------------------

test_that("read_urban_concentrations", {

  # read data and check sf object
  test_sf <- read_urban_concentrations()

  expect_true(is(test_sf, "sf"))

})



# ERRORS and messagens  -----------------------
test_that("read_urban_concentrations", {

  # Wrong year
  expect_error(read_urban_concentrations(year=9999999))

})
