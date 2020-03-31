context("read_disaster_risk_area")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")



# Reading the data -----------------------

test_that("read_disaster_risk_area", {


  # read data
  test_sf <- read_disaster_risk_area(year=2010)

  # check sf object
  testthat::expect_true(is(test_sf, "sf"))

  # check number of micro
  testthat::expect_equal(test_sf$geo_bater %>% length(), 8309)

})




# ERRORS and messagens  -----------------------
test_that("read_disaster_risk_area", {

  # Wrong year
  testthat::expect_error(read_disaster_risk_area(year=9999999))
  testthat::expect_error(read_disaster_risk_area(year="xxx"))
  testthat::expect_error(read_disaster_risk_area(year=NULL))

})
