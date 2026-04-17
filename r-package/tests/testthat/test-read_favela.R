context("read_favela")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------

test_that("read_favela", {

  # read data
  test_sf <- read_favela(year = 2022, showProgress = F)

  # check sf object
  testthat::expect_true(is(test_sf, "sf"))


  # Read all favelas of a given municipality
  n <- read_favela(year = 2022, code_muni = 2927408, as_sf = FALSE)
  testthat::expect_true( nrow(n) == 262)

  # Read all favelas of a given state
  n <- read_favela(year = 2022, code_muni = "RJ", as_sf = FALSE)
  testthat::expect_true( nrow(n) == 1724)


})



# ERRORS and messagens  -----------------------
test_that("read_favela", {

  # Wrong year
  testthat::expect_error(read_favela())
  testthat::expect_error(read_favela(year=9999999))
  testthat::expect_error(read_favela(year="xxx"))
  testthat::expect_error(read_favela(tp="xxx"))


})
