context("read_urban_area")


# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


# Reading the data -----------------------

test_that("read_urban_area", {

  # read data and check sf object
  test_sf <- read_urban_area()

  expect_true(is(test_sf, "sf"))

  # check projection
    expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})



# ERRORS and messagens  -----------------------
test_that("read_urban_area", {

  # Wrong year
  expect_error(read_urban_area(year=9999999))

})
