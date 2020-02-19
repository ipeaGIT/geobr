context("Read")


# Reading the data -----------------------

test_that("read_indigenous_land", {

  # skip tests because they take too much time
  Sys.setenv(NOT_CRAN = "true")
  skip_on_cran()
  skip_on_travis()

  # read data
  test_sf <- read_indigenous_land(date=201907)

  # check sf object
  expect_true(is(test_sf, "sf"))

  # check number of micro
  expect_equal(test_sf$code_terrai %>% length(), 615)

  # check projection
  expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})



# ERRORS and messagens  -----------------------
test_that("read_indigenous_land", {

  # skip tests because they take too much time
  Sys.setenv(NOT_CRAN = "true")
  skip_on_cran()
  skip_on_travis()

  # Wrong date
  expect_error(read_indigenous_land(date=9999999))
  expect_error(read_indigenous_land(date="xxx"))
  expect_error(read_indigenous_land(date=NULL))

})
