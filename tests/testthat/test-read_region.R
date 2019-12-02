context("Read")


# Reading the data -----------------------

test_that("read_region", {

  # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()

  # read data
  expect_message(read_region(year=NULL))
  test_sf <- read_region(year=2010)
  test_2000_sf <- read_region(year=2000)
  test_2001_sf <- read_region(year=2001)
  test_2013_sf <- read_region(year=2013)
  test_2014_sf <- read_region(year=2014)
  test_2015_sf <- read_region(year=2015)
  test_2016_sf <- read_region(year=2016)
  test_2017_sf <- read_region(year=2017)
  test_2018_sf <- read_region(year=2018)

  # check sf object
  expect_true(is(test_sf, "sf"))
  expect_true(is(test_2000_sf, "sf"))
  expect_true(is(test_2001_sf, "sf"))
  expect_true(is(test_2013_sf, "sf"))
  expect_true(is(test_2014_sf, "sf"))
  expect_true(is(test_2015_sf, "sf"))
  expect_true(is(test_2016_sf, "sf"))
  expect_true(is(test_2017_sf, "sf"))
  expect_true(is(test_2018_sf, "sf"))

  # check number of micro
  expect_equal(test_sf %>% length(), 3)
  expect_equal(test_2000_sf %>% length(), 3)
  expect_equal(test_2001_sf %>% length(), 3)
  expect_equal(test_2013_sf %>% length(), 3)
  expect_equal(test_2014_sf %>% length(), 3)
  expect_equal(test_2015_sf %>% length(), 3)
  expect_equal(test_2016_sf %>% length(), 3)
  expect_equal(test_2017_sf %>% length(), 3)
  expect_equal(test_2018_sf %>% length(), 3)

  # check projection
  expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")
  expect_equal(sf::st_crs(test_2000_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")
  expect_equal(sf::st_crs(test_2001_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")
  expect_equal(sf::st_crs(test_2013_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")
})




# ERRORS and messagens  -----------------------
test_that("read_region", {

  # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()


  # Wrong year
  expect_error(read_region(year=9999999))
  expect_error(read_region(year="xxx"))

})
