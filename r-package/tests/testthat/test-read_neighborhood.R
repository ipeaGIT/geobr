context("read_neighborhood")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


# Reading the data -----------------------

test_that("read_neighborhood", {

  # read data
  test_sf <- read_neighborhood(showProgress = F)

  # check sf object
  testthat::expect_true(is(test_sf, "sf"))



  # # check projection
  # testthat::expect_equal(sf::st_crs(test_sf)$epsg, 4674)

})



# ERRORS and messagens  -----------------------
test_that("read_neighborhood", {

  # Wrong year
  testthat::expect_error(read_neighborhood(year=9999999))
  testthat::expect_error(read_neighborhood(year="xxx"))
  testthat::expect_error(read_neighborhood(tp="xxx"))


})
