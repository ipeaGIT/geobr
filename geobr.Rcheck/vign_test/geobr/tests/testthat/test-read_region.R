context("read_region")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


# Reading the data -----------------------

test_that("read_region", {



  # read data
  test_sf <- read_region()

  # check sf object
  expect_true(is(test_sf, "sf"))


  # check number of rows
  expect_equal(nrow(test_sf), 5)

  # check projection
  expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")
})




# ERRORS and messagens  -----------------------
test_that("read_region", {

  # Wrong year
  expect_error(read_region(year=9999999))

})
