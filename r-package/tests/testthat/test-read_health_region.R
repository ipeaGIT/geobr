context("read_health_region")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()

# Reading the data -----------------------

test_that("read_health_region", {

  # read data
  test_sf_muni <- read_health_region(year = 2024)
  test_sf_micro <- read_health_region(year = 2024, group_by = "micro")
  test_sf_macro <- read_health_region(year = 2024, group_by = "macro")

  # check sf object
  testthat::expect_true(is(test_sf_muni, "sf"))
  testthat::expect_true(nrow(test_sf_muni) > nrow(test_sf_micro))
  testthat::expect_true(nrow(test_sf_micro) > nrow(test_sf_macro))

  # check number of micro
  testthat::expect_equal(unique(test_sf_micro$code_health_region) |> length(), 450)
  testthat::expect_equal(unique(test_sf_macro$code_health_macroregion) |> length(), 118)

})



# ERRORS and messagens  -----------------------
test_that("read_health_region", {

  # Wrong year
  testthat::expect_error(read_health_region())
  testthat::expect_error(read_health_region(year=9999999))
  testthat::expect_error(read_health_region(year="xxx"))

  # deprecated macro argument
  testthat::expect_error( read_health_region(year = 2024, macro = T))
})
