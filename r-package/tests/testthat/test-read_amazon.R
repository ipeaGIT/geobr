context("read_amazon")

# # skip tests because they take too much time
# skip_if(Sys.getenv("TEST_ONE") != "")
# testthat::skip_on_cran()
# testthat::skip_on_travis()


# Reading the data -----------------------

test_that("read_amazon", {

  # read data
  test_sf <- read_amazon()

  # check sf object
  testthat::expect_true(is(test_sf, "sf"))

  # check number of columns
  testthat::expect_equal(ncol(test_sf), 2)

  # check projection
  testthat::expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})




# ERRORS and messagens  -----------------------
test_that("read_amazon", {

  # Wrong year
  testthat::expect_error(read_amazon(year=9999999))
  testthat::expect_error(read_amazon(year="xxx"))
  testthat::expect_error(read_amazon(tp="xxx"))


})
