context("read_health_facilities")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()



# Reading the data -----------------------

test_that("read_health_facilities", {

  # read data
  test_sf <- read_health_facilities()

  # check sf object
  expect_true(is(test_sf, "sf"))

  # check number of micro
  expect_equal(nrow(test_sf), 360177)

})
