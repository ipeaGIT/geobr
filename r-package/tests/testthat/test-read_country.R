context("read_country")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------

test_that("read_country", {

  # read data
  test_sf0 <- read_country()
  test_sf <- read_country(year=1991)


  # check sf object
  testthat::expect_true(is(test_sf0, "sf"))
  testthat::expect_true(is(test_sf, "sf"))

})


# ERRORS and messagens  -----------------------
test_that("read_country", {

  # Wrong date
  testthat::expect_error(read_country(year=9999999))
  testthat::expect_error(read_country(year="xxx"))
  testthat::expect_error(read_country(tp="xxx"))

})
