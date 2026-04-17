context("read_indigenous_land")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()

# Reading the data -----------------------

test_that("read_indigenous_land", {

  # check sf object
  test_sf <- read_indigenous_land(year = 2024)

  testthat::expect_true(is(test_sf, "sf"))


})



# ERRORS and messagens  -----------------------
test_that("read_indigenous_land", {

  # Wrong year
  testthat::expect_error(read_indigenous_land())
  testthat::expect_error(read_indigenous_land(year=9999999))
  testthat::expect_error(read_indigenous_land(year="xxx"))

})
