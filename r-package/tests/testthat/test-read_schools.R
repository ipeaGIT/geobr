context("read_schools")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------

test_that("read_schools", {

  # read data
  test_sf0 <- geobr::read_schools()

  # check sf object
  testthat::expect_true(is(test_sf0, "sf"))

  # check number of micro
  testthat::expect_equal( nrow(test_sf0), 222936)

})




# ERRORS and messagens  -----------------------
test_that("read_schools", {

  # Wrong year
  testthat::expect_error(read_schools(year=9999999))
  testthat::expect_error(read_schools(year="xxx"))
  testthat::expect_error(read_schools(tp="xxx"))

})
