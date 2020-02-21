context("read_statistical_grid")

# skip tests because they take too much time
# skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_on_travis()


test_that("read_statistical_grid", {


   testthat::expect_output(read_statistical_grid(code_grid=44, year=2010))
   testthat::expect_output(read_statistical_grid(code_grid="AC", year=2010))

 # testthat::expect_message(read_statistical_grid(code_grid="all")) # TOO HEAVY


# 71.43%

  })



# ERRORS
test_that("read_statistical_grid", {

  # Wrong year and code
  testthat::expect_error(read_statistical_grid())
  testthat::expect_error(read_statistical_grid(code_grid=NULL))

  # Wrong code
  testthat::expect_error(read_statistical_grid(code_grid=9999999))

  # Wrong year
  testthat::expect_error(read_statistical_grid( year=9999999))

})
