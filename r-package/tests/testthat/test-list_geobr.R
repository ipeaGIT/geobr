context("Read")


# Reading the data -----------------------

if (Sys.getenv("TEST_ONE") == ""){



test_that("lookup_muni", {

  # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()

  # read data
  df <- list_geobr()

  # check number of cols
  expect_equal(ncol(df), 4)

})




# ERRORS and messagens  -----------------------
test_that("list_geobr", {

  expect_error(list_geobr(1))
  expect_error(list_geobr('a'))

})


}
