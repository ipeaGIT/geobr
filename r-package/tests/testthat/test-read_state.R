context("read_state")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


test_that("read_state", {

  # read data
  expect_true(is( read_state(code_state=11, year=1970) , "sf"))
  expect_true(is( read_state(code_state='all', year=1970) , "sf"))
  expect_true(is( read_state(code_state='AC', year=1970) , "sf"))


  expect_true(is( read_state() , "sf"))
  expect_true(is( read_state(code_state=11, year=2010) , "sf"))
  expect_true(is( read_state(code_state='all', year=2010) , "sf"))
  expect_true(is(  read_state(code_state='AC', year=2010) , "sf"))



  # check sf object
  test_code <- read_state(code_state=11, year=2010)
  testthat::expect_true(is(test_code, "sf"))

  # check number of rows in ouput
  testthat::expect_equal(nrow(test_code), 1)

})




# ERRORS
test_that("read_state", {

  # Wrong year and code
  testthat::expect_error(read_state(code_state=9999999, year=9999999))

  # Wrong code
  testthat::expect_error( read_state(code_state=NULL, year=1991) ) # EXception

   testthat::expect_error(read_state(code_state=9999999))
   testthat::expect_error(read_state(code_state=5201108312313213123123123))
   testthat::expect_error(read_state(code_state="AC_ABCD"))

  # Wrong year
   testthat::expect_error(read_state( year=9999999))
   testthat::expect_error(read_state(showProgress = 'aaaa'))


})
