context("read_municipality")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


test_that("read_municipality", {

  # read data
  test_1991 <- read_municipality(code_muni=1100064, year=1991)
  test_2010 <- read_municipality(code_muni=1200179, year=2010)

  # check sf object
  expect_true(is(test_1991, "sf"))
  expect_true(is(test_2010, "sf"))

 # testthat::expect_output( read_municipality(code_muni='AC', year=1991) )
  testthat::expect_output( read_municipality(code_muni='AC', year=2010) )

  testthat::expect_output( read_municipality(code_muni=11, year=1991) )
  testthat::expect_output( read_municipality(code_muni=11, year=2010) )

  testthat::expect_output( read_municipality(code_muni='all', year=1991) )
  testthat::expect_output( read_municipality(code_muni='all', year=2010) )

  testthat::expect_output( read_municipality( year=1991) )
  testthat::expect_output( read_municipality( year=2010) )

})


# ERRORS
test_that("read_municipality", {

  # Wrong code
  testthat::expect_error(read_municipality(code_muni=9999999))
  testthat::expect_error(read_municipality(code_muni=5201108312313213))

  testthat::expect_error(read_municipality(code_muni="RJ_ABC"))
  testthat::expect_error(read_municipality(code_muni="AA"))

  # Wrong year
  testthat::expect_error(read_municipality( year=9999999))
  testthat::expect_error(read_municipality( year='SAS'))

})
