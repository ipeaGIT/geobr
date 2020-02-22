context("read_census_tract")

# skip tests because they take too much time
# skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
# testthat::skip_on_travis()


 test_that("read_census_tract", {

   # test_muni <- read_census_tract(code_tract=5201108, year=2010)
   # test_abrev <- read_census_tract(code_tract="AC", year=2010)
   # test_state <- read_census_tract(code_tract=11, year=2010)
   # test_all <- read_census_tract(code_tract="all", year=2010)
   #
   # # check sf object
   # expect_true(is(test_muni, "sf"))
   # expect_true(is(test_abrev, "sf"))
   # expect_true(is(test_state, "sf"))
   # expect_true(is(test_all, "sf"))


  # read data
  testthat::expect_output( read_census_tract(code_tract = "AC", zone = "rural", year=2000) )
  testthat::expect_output( read_census_tract(code_tract = "AP", zone = "rural") )
  testthat::expect_output( read_census_tract(code_tract = "AP", zone = "urban", year=2000) )
  testthat::expect_output( read_census_tract(code_tract = 'all', year = 2000) )


  test_code_2000 <- read_census_tract(code_tract = 1100023, year = 2000)

  # check projection
  expect_equal(sf::st_crs(test_code_2000)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

 })


# ERRORS
test_that("read_census_tract", {

  # Wrong year and code
  expect_error(read_census_tract(code_tract=9999999, year=9999999))

  # Wrong code
  expect_error(read_census_tract(code_tract=9999999))
  expect_error(read_census_tract(code_tract=5201108312313213))

  # Wrong year
  expect_error(read_census_tract( year=9999999))

})
