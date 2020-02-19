context("read_census_tract")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_on_travis()


test_that("read_census_tract", {

  # read data
  test_code_2000 <- read_census_tract(code_tract = 1100023, year = 2000)
  test_code_2010 <- read_census_tract(code_tract = 1100023, year = 2010)
  test_code2_2010 <- read_census_tract(code_tract = 1100023, year = NULL)

  test_zone_2000 <- read_census_tract(code_tract = "AC", zone = "rural", year=2000)
  test_zone_2010 <- read_census_tract(code_tract = "AC", zone = "rural", year=2010)
  test_zone2_2010 <- read_census_tract(code_tract = "AP", zone = "rural", year=NULL)

  test_state_code_2000 <- read_census_tract(code_tract = 11, year = 2000)
  test_state_code_2010 <- read_census_tract(code_tract = 11, year = 2010)
  test_state_code2_2010 <- read_census_tract(code_tract = 11, year = NULL)

  test_all_2000 <- read_census_tract(code_tract = 'all', year = 2000)
  test_all_2010 <- read_census_tract(code_tract = 'all', year = 2010)
  test_all2_2010 <- read_census_tract(code_tract = 'all', year = NULL)

  # check sf object
  expect_true(is(test_code_2000, "sf"))
  expect_true(is(test_code_2010, "sf"))
  expect_true(is(test_code2_2010, "sf"))
  expect_true(is(test_zone_2000, "sf"))
  expect_true(is(test_zone_2010, "sf"))
  expect_true(is(test_zone2_2010, "sf"))
  expect_true(is(test_state_code_2000, "sf"))
  expect_true(is(test_state_code_2010, "sf"))
  expect_true(is(test_state_code2_2010, "sf"))
  expect_true(is(test_all_2000, "sf"))
  expect_true(is(test_all_2010, "sf"))
  expect_true(is(test_all2_2010, "sf"))

  # check projection
  expect_equal(sf::st_crs(test_code_2010)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")
  expect_equal(sf::st_crs(test_code_2000)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})


# ERRORS
test_that("read_census_tract", {

  # Wrong year and code
  expect_error(read_census_tract(code_tract = 9999999, year = 9999999))
  expect_error(read_census_tract(code_tract = 9999999, year = "xxx"))
  expect_error(read_census_tract(code_tract = "xxx", year = 9999999))
  expect_error(read_census_tract(code_tract = "xxx", year = "xxx"))
  expect_error(read_census_tract(code_tract = 9999999, year = NULL))

  # Wrong year  expect_error(read_census_tract(code_tract="xxx", year=NULL))
  expect_error(read_census_tract(code_tract = 11, year = 9999999))
  expect_error(read_census-tract(code_tract = 11, year = "xx"))
  expect_error(read_census_tract(code_tract = 1401, year = 9999999))
  expect_error(read_census_tract(code_tract = 1401, year = "xx"))

  expect_error(read_census_tract(code_tract = "SC", year = 9999999))
  expect_error(read_census_tract(code_tract = "SC", year = "xx"))

  expect_error(read_census_tract(code_tract = "all", year = 9999999))
  expect_error(read_census_tract(code_tract = "all", year = "xx"))

  # Wrong code
  expect_error(read_census_tract(code_tract = 9999999, year = 2000))
  expect_error(read_census_tract(code_tract = "XXX", year = 2000))
  expect_error(read_census_tract(code_tract = "XXX", year = NULL))
  expect_error(read_census_tract(code_tract = NULL, year = 2000))

})
