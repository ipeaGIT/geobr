context("read_amazon")

# # skip tests because they take too much time
# skip_if(Sys.getenv("TEST_ONE") != "")
# testthat::skip_on_cran()
# testthat::skip_on_travis()


# Reading the data -----------------------

test_that("read_amazon", {

  # read data
  expect_message(read_amazon(year=NULL))
  test_sf <- read_amazon(year=2012)

  # check sf object
  expect_true(is(test_sf, "sf"))

  # check number of columns
  expect_equal(ncol(test_sf), 2)

  # check projection
  expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})




# ERRORS and messagens  -----------------------
test_that("read_amazon", {

  # Wrong year
  expect_error(read_amazon(year=9999999))
  expect_error(read_amazon(year="xxx"))

})
