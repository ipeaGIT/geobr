context("read_census_tract")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


test_that("read_census_tract", {

  expect_true(is(  read_census_tract(code_tract = 11)  , "sf"))
  expect_true(is(  read_census_tract(code_tract = 11, zone = "rural", year=2000)  , "sf"))
  expect_true(is(  read_census_tract(code_tract = "AC", zone = "rural", year=2000)  , "sf"))
  # expect_true(is(  read_census_tract(code_tract = "AP", zone = "rural") , "sf"))
  # expect_true(is(  read_census_tract(code_tract = 11, zone = "urban", year=2000)  , "sf"))
  expect_true(is(  read_census_tract(code_tract = "AP", zone = "urban", year=2000) , "sf"))
  # expect_true(is(  read_census_tract(code_tract = "AP", zone = "urban", year=2010) , "sf"))
  expect_true(is(  read_census_tract(code_tract = 'all', year = 2000)  , "sf"))
  expect_true(is(  read_census_tract(code_tract = 1100023, year = 2000) , "sf"))

})


# ERRORS
test_that("read_census_tract", {

  # Wrong year and code
  testthat::expect_error( read_census_tract( ) )
  testthat::expect_error(read_census_tract(code_tract=9999999, year=9999999))

 testthat::expect_error( read_census_tract(code_tract = "AP", year=2000, zone = "ABCD") )


  # Wrong code
  testthat::expect_error(read_census_tract(code_tract=NULL))
  testthat::expect_error(read_census_tract(code_tract=9999999))
  testthat::expect_error(read_census_tract(code_tract=5201108312313213))
  testthat::expect_error(read_census_tract(code_tract="AC_ABCD"))

  # Wrong year
  testthat::expect_error(read_census_tract( year=9999999))

})
