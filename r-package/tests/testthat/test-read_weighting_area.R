context("read_weighting_area")


# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


test_that("read_weighting_area", {

  # # read data
  testthat::expect_output( read_weighting_area(code_weighting=5201108, year=2010) )
  testthat::expect_output( read_weighting_area(code_weighting="AC", year=2010) )
  testthat::expect_output( read_weighting_area(code_weighting=11, year=2010) )


  test_code <- read_weighting_area(code_weighting=5201108005004, year=2010)

  # check sf object
   expect_true(is(test_code, "sf"))


  # check number of weighting areas
  expect_equal(nrow(test_code), 68)

  # check projection
  expect_equal(sf::st_crs(test_code)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})


# ERRORS
test_that("read_weighting_area", {

  # Wrong year and code
  expect_error(read_weighting_area(code_weighting=9999999, year=9999999))

  # Wrong code
  expect_error(read_weighting_area(code_weighting=9999999))
  expect_error(read_weighting_area(code_weighting=5201108312313213))

  # Wrong year
  expect_error(read_weighting_area( year=9999999))

})
