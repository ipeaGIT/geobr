context("read_weighting_area")


# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


test_that("read_weighting_area", {

  # read data
  testthat::expect_output( read_weighting_area() )
  testthat::expect_output( read_weighting_area(code_weighting=5201108, year=2010) )
  testthat::expect_output( read_weighting_area(code_weighting="AC", year=2010) )
  testthat::expect_output( read_weighting_area(code_weighting=11, year=2010) )


  test_code <- read_weighting_area(code_weighting=5201108005004, year=2010)

  # check sf object
  testthat::expect_true(is(test_code, "sf"))


  # check number of weighting areas
   testthat::expect_equal(nrow(test_code), 1)


})


# ERRORS
test_that("read_weighting_area", {

  # Wrong year and code
  testthat::expect_error(read_weighting_area(code_weighting=9999999, year=9999999))

  # Wrong code
  testthat::expect_error(read_weighting_area(code_weighting=9999999))
  testthat::expect_error(read_weighting_area(code_weighting=5201108312313213123123123))
  testthat::expect_error(read_weighting_area(code_weighting="AC_ABCD"))

  # Wrong year
  testthat::expect_error(read_weighting_area( year=9999999))

})
