context("read_country")

testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")

# Reading the data -----------------------

test_that("read_country", {

  # read data
  test_sf0 <- read_country()
  test_sf <- read_country(year=1991)


  # check sf object
  testthat::expect_true(is(test_sf0, "sf"))
  testthat::expect_true(is(test_sf, "sf"))

  # check projection
  testthat::expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})



# ERRORS and messagens  -----------------------
test_that("read_country", {

  # Wrong date
  testthat::expect_error(read_country(year=9999999))
  testthat::expect_error(read_country(year="xxx"))

})
