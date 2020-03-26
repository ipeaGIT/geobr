context("read_intermediate_region")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")

# Reading the data -----------------------

test_that("read_intermediate_region", {

  # read data
  testthat::expect_output( read_intermediate_region() )
  testthat::expect_output( read_intermediate_region(code_intermediate = 11) )
  testthat::expect_output( read_intermediate_region(code_intermediate = "AC") )

  test_code_muni <- read_intermediate_region(code_intermediate =  1201)

  # check number of rows
  testthat::expect_equal(nrow(test_code_muni), 1)

})




# ERRORS and messagens  -----------------------
test_that("read_intermediate_region", {


  # Wrong year
  testthat::expect_error(read_intermediate_region(year = 9999999))
  testthat::expect_error(read_intermediate_region(year = "xxx"))
  testthat::expect_error(read_intermediate_region(code_intermediate=5201108312313213))


  # wrong year and code_intermediate
  testthat::expect_error(read_intermediate_region(code_intermediate = "xxxx", year=9999999))
  testthat::expect_error(read_intermediate_region(code_intermediate = 9999999, year="xxx"))

})
