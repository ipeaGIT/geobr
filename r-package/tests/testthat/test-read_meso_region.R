context("read_meso_region")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


test_that("read_meso_region", {

  # read data
  # expect_true(is(read_meso_region(code_meso=1401) , "sf"))
  expect_true(is(read_meso_region(code_meso="AC", year=2010), "sf"))
  # expect_true(is(read_meso_region(code_meso=11, year=2010), "sf"))
  expect_true(is(read_meso_region(code_meso="all", year=2010) , "sf"))
  expect_true(is(read_meso_region(code_meso=12, year=2017) , "sf"))
  expect_true(is(read_meso_region(code_meso="AM", year=2000) , "sf"))


  test_meso_code <-  read_meso_region(code_meso=1401, year=2010)

  # check sf object
  expect_true(is(test_meso_code, "sf"))

  # check number of meso
  expect_equal( nrow(test_meso_code), 1)

})


# ERRORS
test_that("read_meso_region", {


  expect_error(read_meso_region(code_meso=9999999, year=9999999))

  # Wrong code
  expect_error(read_meso_region(code_meso=9999999))
  expect_error(read_meso_region(code_meso=5201108312313213))

  # Wrong year
  expect_error(read_meso_region( year=9999999))

})
