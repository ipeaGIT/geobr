context("read_health_facilities")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")



# Reading the data -----------------------

test_that("read_health_facilities", {

  # read data
  test_sf <- read_health_facilities()

  # check sf object
  expect_true(is(test_sf, "sf"))

  # check number of micro
  expect_equal(nrow(test_sf), 360177)

  # check projection
  expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})
