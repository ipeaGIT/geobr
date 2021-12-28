context("read_immediate_region")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()

# Reading the data -----------------------

test_that("read_immediate_region", {

  # read data
  expect_true(is(  read_immediate_region() , "sf"))
  expect_true(is(  read_immediate_region(code_immediate = 11) , "sf"))
  expect_true(is(  read_immediate_region(code_immediate = "AC") , "sf"))

  test_code_muni <- read_immediate_region(code_immediate =  110002)


  # check number of micro
  testthat::expect_equal(test_code_muni %>% length(), 8)

})




# ERRORS and messagens  -----------------------
test_that("read_immediate_region", {

  # Wrong year
  testthat::expect_error(read_immediate_region(year = 9999999))
  testthat::expect_error(read_immediate_region(year = "xxx"))
  testthat::expect_error(read_immediate_region(code_immediate=5201108312313213))


  # wrong year and code_immediate
  testthat::expect_error(read_immediate_region(code_immediate = "xxxx", year=9999999))
  testthat::expect_error(read_immediate_region(code_immediate = 9999999, year="xxx"))

})

