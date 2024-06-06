context("read_health_facilities")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()



# Reading the data -----------------------

test_that("read_health_facilities", {

  # read data
  test_sf <- read_health_facilities(showProgress = FALSE)

  # check sf object
  expect_true(is(test_sf, "sf"))

  # read data
  test_sf_202303 <- read_health_facilities(date = 202303)

  # check number of observations
  expect_equal(nrow(test_sf_202303), 517629)

})




# ERRORS and messagens  -----------------------
test_that("read_health_facilities", {

  # Wrong date
  testthat::expect_error(read_health_facilities(date = 9999999))
  testthat::expect_error(read_health_facilities(year = "banana"))

  # wrong showProgress
  testthat::expect_error(read_health_facilities(showProgress = 'banana'))

})


