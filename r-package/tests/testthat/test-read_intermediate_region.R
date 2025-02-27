context("read_intermediate_region")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()

# Reading the data -----------------------

test_that("read_intermediate_region", {

  # read data
  expect_true(is(  read_intermediate_region() , "sf"))
  expect_true(is(  read_intermediate_region(code_intermediate = 11) , "sf"))
  expect_true(is(  read_intermediate_region(code_intermediate = "AC") , "sf"))

  test_code_muni <- read_intermediate_region(code_intermediate =  1201)

  # check number of rows
  testthat::expect_equal(nrow(test_code_muni), 1)

})




# ERRORS and messagens  -----------------------
test_that("read_intermediate_region", {


  # Wrong year
  testthat::expect_error(read_intermediate_region(year = 9999999))
  testthat::expect_error(read_intermediate_region(year = "xxx"))


  # wrong year and code_intermediate
  testthat::expect_error(read_intermediate_region(code_intermediate = "xxxx", year=9999999))
  testthat::expect_error(read_intermediate_region(code_intermediate = 9999999, year="xxx"))

})
