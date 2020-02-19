context("lookup_muni")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


# Reading the data -----------------------


test_that("lookup_muni", {

  # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()

  # read data
  test_sf <- lookup_muni(name_muni = "fortaleza")

  # check sf object
  expect_true(is(test_sf, "data.frame"))

  # check number of cols
  expect_equal(test_sf %>% ncol(), 13)

  # When using two arguments (supposed to give a warning)
  expect_warning(lookup_muni(name_muni="fortaleza", code_muni=2304400))
})




# ERRORS and messagens  -----------------------
test_that("lookup_muni", {


  expect_error(lookup_muni())

  # Wrong name
  expect_error(lookup_muni(name_muni="arroz"))
  expect_error(lookup_muni(name_muni=123))

  # Wrong code
  expect_error(lookup_muni(code_muni=123))
  expect_error(lookup_muni(name_muni="teste"))



})


