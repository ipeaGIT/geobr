context("read_favela")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------

test_that("read_favela", {

  # read data
  test_sf <- read_favela(year = 2022, showProgress = F)

  # check sf object
  testthat::expect_true(is(test_sf, "sf"))



  # # check projection
  # testthat::expect_equal(sf::st_crs(test_sf)$epsg, 4674)

})



# ERRORS and messagens  -----------------------
test_that("read_favela", {

  # Wrong year
  testthat::expect_error(read_favela())
  testthat::expect_error(read_favela(year=9999999))
  testthat::expect_error(read_favela(year="xxx"))
  testthat::expect_error(read_favela(tp="xxx"))


})
