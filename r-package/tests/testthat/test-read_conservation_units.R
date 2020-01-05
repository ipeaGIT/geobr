context("Read")


# Reading the data -----------------------

test_that("read_conservation_units", {

  # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()

  # read data
  test_sf <- read_conservation_units(date=201909)
  expect_output(read_conservation_units(date=NULL))


  # check sf object
  expect_true(is(test_sf, "sf"))


  # check projection
    expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})



# ERRORS and messagens  -----------------------
test_that("read_conservation_units", {

  # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()

  # Wrong date
  expect_error(read_conservation_units(date=9999999))
  expect_error(read_conservation_units(date="xxx"))

})
