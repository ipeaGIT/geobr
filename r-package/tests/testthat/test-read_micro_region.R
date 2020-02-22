context("read_micro_region")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


test_that("read_micro_region", {

  # read data
  testthat::expect_output(  read_micro_region(code_micro=11008) )
  testthat::expect_output(  read_micro_region(code_micro="AC", year=2010) )
  testthat::expect_output(  read_micro_region(code_micro="AP") )
  testthat::expect_output(  read_micro_region(code_micro=11, year=2010) )
  testthat::expect_output(  read_micro_region(code_micro=11) )
  testthat::expect_output(  read_micro_region(code_micro="all", year=2010) )
  testthat::expect_output(  read_micro_region(code_micro="all") )

  test_micro_code <-  read_micro_region(code_micro=11008, year=2010)

  # check sf object
  expect_true(is(test_micro_code, "sf"))

  # check number of micro
  expect_equal( nrow(test_micro_code), 1)

  # check projection
  expect_equal(sf::st_crs(test_micro_code)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})



# ERRORS
test_that("read_micro_region", {


  # expect_error(read_census_tract(code_tract=9999999, year=9999999))
  #
  # # Wrong code
  # expect_error(read_census_tract(code_tract=9999999))
  # expect_error(read_census_tract(code_tract=5201108312313213))
  #
  # # Wrong year
  # expect_error(read_census_tract( year=9999999))

  # Wrong year and code
  expect_error(read_micro_region(code_micro=9999999, year=9999999))
  expect_error(read_micro_region(code_micro=9999999, year="xxx"))
  expect_error(read_micro_region(code_micro="xxx", year=9999999))
  expect_error(read_micro_region(code_micro="xxx", year="xxx"))
  expect_error(read_micro_region(code_micro=NULL, year=9999999))
  expect_error(read_micro_region(code_micro=NULL, year="xxx"))

  # Wrong year
  expect_error(read_micro_region(code_micro=11, year=9999999))
  expect_error(read_micro_region(code_micro=1401, year=9999999))
  expect_error(read_micro_region(code_micro=11008, year=9999999))
  expect_error(read_micro_region(code_micro=11, year= "xx"))
  expect_error(read_micro_region(code_micro=1401, year= "xx"))
  expect_error(read_micro_region(code_micro=11008, year= "xx"))

  expect_error(read_micro_region(code_micro="all", year=9999999))
  expect_error(read_micro_region(code_micro="SC", year=9999999))
  expect_error(read_micro_region(code_micro="SC", year="xx"))
  expect_error(read_micro_region(code_micro="all", year="xx"))

  # Wrong code
  expect_error(read_micro_region(code_micro=9999999, year=2000))
  expect_error(read_micro_region(code_micro=9999999))
  expect_error(read_micro_region(code_micro="XXX", year=2000))
  expect_error(read_micro_region(code_micro="XXX"))
  expect_error(read_micro_region(code_micro=NULL, year=2000))
  expect_error(read_micro_region(code_micro=NULL))

})
