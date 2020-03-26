context("read_conservation_units")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


# Reading the data -----------------------

test_that("read_conservation_units", {

  # read data
  test_sf <- read_conservation_units(date=201909)
  testthat::expect_output(read_conservation_units())


  # check sf object
  testthat::expect_true(is(test_sf, "sf"))

})



# ERRORS and messagens  -----------------------
test_that("read_conservation_units", {

  # Wrong date
  testthat::expect_error(read_conservation_units(date=9999999))
  testthat::expect_error(read_conservation_units(date="xxx"))
  testthat::expect_error(read_conservation_units(tp="xxx"))

})
