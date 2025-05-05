context("read_disaster_risk_area")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()



# Reading the data -----------------------

test_that("read_disaster_risk_area", {


  # check sf object
  test_sf <- read_disaster_risk_area(year=2010)
  testthat::expect_true(is(test_sf, "sf"))

  test_sf <- read_disaster_risk_area()
  testthat::expect_true(is(test_sf, "sf"))

  # check number of micro
  testthat::expect_equal(test_sf$geo_bater %>% length(), 8309)

})




# ERRORS and messagens  -----------------------
test_that("read_disaster_risk_area", {

  # Wrong year
  testthat::expect_error(read_disaster_risk_area(year=9999999))
  testthat::expect_error(read_disaster_risk_area(year="xxx"))

})
