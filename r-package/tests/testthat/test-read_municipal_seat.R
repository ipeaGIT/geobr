context("read_municipal_seat")

# skip tests because they take too much time
# skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
#testthat::skip_on_travis()

# Reading the data -----------------------

test_that("read_municipal_seat", {

  # read data and check sf object
  testthat::expect_output( read_municipal_seat() )
  test_sf <- read_municipal_seat(year=1991)


  expect_true(is(test_sf, "sf"))

})



# ERRORS and messagens  -----------------------
test_that("read_municipal_seat", {

  # Wrong year
  expect_error(read_municipal_seat(year=9999999))
  expect_error(read_municipal_seat(year="xxx"))

})
