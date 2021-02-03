context("cep_to_state")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


# Reading the data -----------------------


test_that("cep_to_state", {

  # check output
  expect_equal( cep_to_state(cep = 69900000), "AC")
  expect_equal( cep_to_state(cep = '69900-000'), "AC")
  expect_equal( cep_to_state(cep = 70233020), "DF")

})


# ERRORS and messagens  -----------------------
test_that("cep_to_state", {

  expect_error( cep_to_state(cep = 'aaaa') )
  expect_error( cep_to_state() )


})


