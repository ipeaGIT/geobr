context("read_capitals")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()

# Reading the data -----------------------

test_that("read_capitals", {

  # check sf output
  expect_true(is( read_capitals(), "sf"))

  # check df output
  expect_true(is( read_capitals(as_sf = FALSE), "data.frame"))

})



# ERRORS and messagens  -----------------------
test_that("read_capitals", {

  # Wrong year
  expect_error(read_capitals(as_sf = 9999999))
  expect_error(read_capitals(showProgress = 9999999))

})
