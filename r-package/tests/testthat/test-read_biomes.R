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
  test_sf <- read_biomes(year=2004)

  # check sf object
  expect_true(is(test_sf0, "sf"))
  expect_true(is(test_sf, "sf"))

  # check number of micro
  expect_equal(test_sf$code_biome %>% length(), 10)

  # check projection
  expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})




# ERRORS and messagens  -----------------------
test_that("read_biomes", {

  # Wrong year
  expect_error(read_biomes(year=9999999))
  expect_error(read_biomes(year="xxx"))

})
