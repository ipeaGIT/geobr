context("read_quilombola_land")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()

# Reading the data -----------------------

test_that("read_quilombola_land", {

  # check sf object
  test_sf <- read_quilombola_land(date = 202605)

  testthat::expect_true(is(test_sf, "sf"))

  # filter
  test_sf2 <- read_quilombola_land(date = 202605, code_state = "BA")
  testthat::expect_true(nrow(test_sf2) < nrow(test_sf))

})



# ERRORS and messagens  -----------------------
test_that("read_quilombola_land", {

  # Wrong date
  testthat::expect_error(read_quilombola_land())
  testthat::expect_error(read_quilombola_land(date=9999999))
  testthat::expect_error(read_quilombola_land(date="xxx"))

})
