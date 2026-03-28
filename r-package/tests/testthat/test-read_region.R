context("read_region")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------

test_that("read_region", {



  # read data
  test_sf <- read_region(year = 2023)

  # check sf object
  expect_true(is(test_sf, "sf"))

  # check number of rows
  expect_equal(nrow(test_sf), 5)

  test_arrw <- read_region(year = 2023, as_sf = FALSE)
  expect_true(is(test_arrw, "ArrowObject"))

  })




# ERRORS and messagens  -----------------------
test_that("read_region", {

  # Wrong year
  expect_error(read_region())
  expect_error(read_region(year=9999999))

})
