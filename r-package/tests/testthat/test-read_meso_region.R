context("read_meso_region")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


test_that("read_meso_region", {

  # read data
  testthat::expect_output(  read_meso_region(code_meso=1401) )
  testthat::expect_output(  read_meso_region(code_meso="AC", year=2010) )
  testthat::expect_output(  read_meso_region(code_meso=11, year=2010) )
  testthat::expect_output(  read_meso_region(code_meso="all", year=2010) )

  test_meso_code <-  read_meso_region(code_meso=1401, year=2010)

  # check sf object
  expect_true(is(test_meso_code, "sf"))

  # check number of meso
  expect_equal( nrow(test_meso_code), 1)

  # check projection
  expect_equal(sf::st_crs(test_meso_code)$proj4string, "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs ")

})


# ERRORS
test_that("read_meso_region", {


  expect_error(read_meso_region(code_meso=9999999, year=9999999))

  # Wrong code
  expect_error(read_meso_region(code_meso=9999999))
  expect_error(read_meso_region(code_meso=5201108312313213))

  # Wrong year
  expect_error(read_meso_region( year=9999999))

})
