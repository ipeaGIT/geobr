context("read_biomes")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
#testthat::skip_on_travis()
# Sys.setenv(NOT_CRAN = "true")


# Reading the data -----------------------

test_that("read_biomes", {

  # read data
  test_sf0 <- read_biomes()

  # check sf object
  testthat::expect_true(is(test_sf0, "sf"))

  # check number of micro
  testthat::expect_equal( nrow(test_sf0), 7)

  # check projection
  testthat::expect_equal(sf::st_crs(test_sf0)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})




# ERRORS and messagens  -----------------------
test_that("read_biomes", {

  # Wrong year
  testthat::expect_error(read_biomes(year=9999999))
  testthat::expect_error(read_biomes(year="xxx"))

})
