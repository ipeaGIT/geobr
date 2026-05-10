context("read_statistical_grid")

# skip tests because they take too much time
testthat::skip_on_cran()
skip_if(Sys.getenv("TEST_ONE") != "")


test_that("read_statistical_grid", {

  temp <- read_statistical_grid(year=2010, code_muni="all", as_sf = FALSE)
  testthat::expect_true( nrow(temp) == 13286535 )

  temp <- read_statistical_grid(year=2010, code_muni="AC", as_sf = FALSE)
  testthat::expect_true( nrow(temp) == 183695 )

  temp <- read_statistical_grid(year=2010, code_muni=2927408, as_sf = FALSE)
  testthat::expect_true( nrow(temp) == 17254 )

  testthat::expect_true(is(temp, "ArrowObject"))

  temp <- read_statistical_grid(year=2010, code_muni=2927408, as_sf = TRUE)

  testthat::expect_true("sf"  %in% class(temp))


  })



# ERRORS
test_that("read_statistical_grid", {

  # Wrong year and code
  testthat::expect_error(read_statistical_grid())
  testthat::expect_error(read_statistical_grid(code_muni=NULL))

  # Wrong code
  testthat::expect_error(read_statistical_grid(code_muni=9999999))

  # Wrong year
  testthat::expect_error(read_statistical_grid( year=9999999))

})
