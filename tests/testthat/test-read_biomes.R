context("Read")


# Reading the data -----------------------

test_that("read_biomes", {

  # skip tests because they take too much time
  skip_on_cran()

  # read data
  expect_message(read_biomes(year=NULL))
  test_sf <- read_biomes(year=2004)

  # check sf object
  expect_true(is(test_sf, "sf"))

  # check number of micro
  expect_equal(test_sf$code_biome %>% length(), 10)

  # check projection
#  expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")

})




# ERRORS and messagens  -----------------------
test_that("read_biomes", {

  # skip tests because they take too much time
  skip_on_cran()


  # Wrong year
  expect_error(read_biomes(year=9999999))
  expect_error(read_biomes(year="xxx"))

})
