context("read_polling_places")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()



# Reading the data -----------------------

test_that("read_polling_places", {

  # read data
  test_sf <- read_polling_places(year = 2010)

  # check sf object
  testthat::expect_true(is(test_sf, "sf"))

  # read data
  test_sf_ac <- read_polling_places(year = 2010, code_muni="AC", as_sf = F)

  # check number of observations
  testthat::expect_true(nrow(test_sf) > nrow(test_sf_ac))

  test_sf_ac <- read_polling_places(year = 2010, code_muni=11, as_sf = F)
  testthat::expect_true(is(test_sf_ac, "ArrowObject"))

})




# ERRORS and messagens  -----------------------
test_that("read_polling_places", {

  # no year input
  testthat::expect_error(read_polling_places(code_muni="AC"))

  # wrong state input
  testthat::expect_error(read_polling_places(code_muni="banana"))

  # Wrong year
  testthat::expect_error(read_polling_places(year = 9999999))
  testthat::expect_error(read_polling_places(year = "banana"))

  # wrong showProgress
  testthat::expect_error(read_polling_places(showProgress = 'banana'))

})


