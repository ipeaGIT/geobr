context("read_comparable_areas")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
#testthat::skip_on_travis()
# Sys.setenv(NOT_CRAN = "true")


# Reading the data -----------------------

test_that("read_comparable_areas", {

  # read data
  amc <- read_comparable_areas(start_year=1970, end_year=2010)

  # check sf object
  testthat::expect_true(is(amc, "sf"))

  # check number of micro
  testthat::expect_equal( nrow(amc), 3800)

})




# ERRORS and messagens  -----------------------
test_that("read_comparable_areas", {

 # Wrong year
 testthat::expect_error( read_comparable_areas(start_year=1, end_year=2010) )
 testthat::expect_error( read_comparable_areas(start_year=1970, end_year=2) )
 testthat::expect_error( read_comparable_areas(start_year=1970, end_year=1900) )

})
