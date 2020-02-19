context("Read")


# Reading the data -----------------------

test_that("read_municipal_seat", {

  # # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()

  # read data and check sf object
  expect_true(is(read_municipal_seat(year=NULL), "sf"))
  test_sf <- read_municipal_seat(year=1991)
  expect_true(is(test_sf, "sf"))

  # check projection
    expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})



# ERRORS and messagens  -----------------------
test_that("read_municipal_seat", {

  # # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()

  # Wrong year
  expect_error(read_municipal_seat(year=9999999))
  expect_error(read_municipal_seat(year="xxx"))

})
