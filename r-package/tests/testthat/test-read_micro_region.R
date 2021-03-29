context("read_micro_region")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


test_that("read_micro_region", {

  # read data
  # expect_true(is(  read_micro_region(code_micro=11008) , "sf"))
  expect_true(is(  read_micro_region(code_micro="AC", year=2010) , "sf"))
  # expect_true(is(  read_micro_region(code_micro=11, year=2010) , "sf"))
  expect_true(is(  read_micro_region(code_micro="all", year=2010)  , "sf"))

  test_micro_code <-  read_micro_region(code_micro=11008, year=2010)

  # check number of micro
  expect_equal( nrow(test_micro_code), 1)

})



# ERRORS
test_that("read_micro_region", {


  expect_error(read_micro_region(code_micro=9999999, year=9999999))

  # Wrong code
  expect_error(read_micro_region(code_micro=9999999))
  expect_error(read_micro_region(code_micro=5201108312313213))

  # Wrong year
  expect_error(read_micro_region( year=9999999))

})
