context("lookup_muni")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")

# Reading the data -----------------------


test_that("lookup_muni", {


  # read data
  df <- list_geobr()

  # check number of cols
  expect_equal(ncol(df), 4)
  expect_true(is.data.frame(df))

})




# ERRORS and messagens  -----------------------
test_that("list_geobr", {

  expect_error(list_geobr(1))
  expect_error(list_geobr('a'))

})

