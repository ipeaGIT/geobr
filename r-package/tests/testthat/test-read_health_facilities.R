context("read_health_facilities")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()



# Reading the data -----------------------

test_that("read_health_facilities", {

  # read data
  test_sf <- read_health_facilities(date = 202604)

  # check sf object
  testthat::expect_true(is(test_sf, "sf"))

  # read data
  test_sf_ac <- read_health_facilities(date = 202604, code_state="AC", as_sf = F)

  # check number of observations
  testthat::expect_true(nrow(test_sf) > nrow(test_sf_ac))

  test_sf_ac <- read_health_facilities(date = 202604, code_state=11, as_sf = F)
  testthat::expect_true(is(test_sf_ac, "ArrowObject"))

})




# ERRORS and messagens  -----------------------
test_that("read_health_facilities", {

  # no date input
  testthat::expect_error(read_health_facilities(code_state="AC"))

  # wrong state input
  testthat::expect_error(read_health_facilities(code_state="banana"))

  # Wrong date
  testthat::expect_error(read_health_facilities(date = 9999999))
  testthat::expect_error(read_health_facilities(year = "banana"))

  # wrong showProgress
  testthat::expect_error(read_health_facilities(showProgress = 'banana'))

})


