context("Read")


# Reading the data -----------------------

test_that("read_country", {

  # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()


  # read data
  test_sf <- read_country(year=1991)


  # check sf object
  expect_true(is(test_sf, "sf"))

  # if argument 'year' is not passed
  expect_message(read_country(year=NULL))

  # check projection
  expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})



# ERRORS and messagens  -----------------------
test_that("read_country", {

  # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()

  # Wrong date
  expect_error(read_country(year=9999999))
  expect_error(read_country(year="xxx"))

})
