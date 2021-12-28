context("read_conservation_units")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------

test_that("read_conservation_units", {

  # read data
  expect_true(is(  read_conservation_units() , "sf"))

})



# ERRORS and messagens  -----------------------
test_that("read_conservation_units", {

  # Wrong date
  testthat::expect_error(read_conservation_units(date=9999999))
  testthat::expect_error(read_conservation_units(date="xxx"))
  testthat::expect_error(read_conservation_units(tp="xxx"))

})
