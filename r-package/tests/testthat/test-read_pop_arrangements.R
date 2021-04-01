context("read_pop_arrangements")


# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


# Reading the data -----------------------

test_that("read_pop_arrangements", {

  # read data and check sf object
  test_sf <- read_pop_arrangements()

  expect_true(is(test_sf, "sf"))

})



# ERRORS and messagens  -----------------------
test_that("read_pop_arrangements", {

  # Wrong year
  expect_error(read_pop_arrangements(year=9999999))

})
