context("read_metro_area")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")

# Reading the data -----------------------

test_that("read_metro_area", {

  # read data and check sf object
  expect_true(is(read_metro_area(year=1970), "sf"))
  test_sf <- read_metro_area(year=2001)
  expect_true(is(test_sf, "sf"))

  # check projection
    expect_equal(sf::st_crs(test_sf)$proj4string, "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs ")

})



# ERRORS and messagens  -----------------------
test_that("read_metro_area", {

  # Wrong year
  expect_error(read_metro_area(year=9999999))
  expect_error(read_metro_area(year="xxx"))
  expect_error(read_metro_area(year=NULL))

})
