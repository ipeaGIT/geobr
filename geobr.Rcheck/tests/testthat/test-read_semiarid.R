context("read_semiarid")


# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


# Reading the data -----------------------

test_that("read_semiarid", {

  # read data
  test_sf <- read_semiarid(year=2017)

  # check sf object
  expect_true(is(test_sf, "sf"))

  # check number of micro
  expect_equal(test_sf %>% length(), 5)

  # check projection
  expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})




# ERRORS and messagens  -----------------------
test_that("read_semiarid", {

  # Wrong year
  expect_error(read_semiarid(year=9999999))

})
