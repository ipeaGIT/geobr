context("remove_islands")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()

br <- read_country(year = 2022)


testthat::test_that("remove_islands", {

  result <- remove_islands(br)

  testthat::expect_s3_class(result, "sf")
  testthat::expect_s3_class(result, "data.frame")

  testthat::expect_equal(sf::st_crs(result)$epsg, 4674)
  testthat::expect_equal(nrow(result), nrow(br))
  testthat::expect_named(result, names(br))

  testthat::expect_true(all(sf::st_is_valid(result)))
  testthat::expect_false(any(sf::st_is_empty(result)))

  # Geometry should change after removing islands
  testthat::expect_false(
    identical(sf::st_as_text(sf::st_geometry(br)), sf::st_as_text(sf::st_geometry(result)))
  )

  # Resulting geometry area should be smaller or equal
  br_area <- sf::st_area(sf::st_transform(br, 5880))
  result_area <- sf::st_area(sf::st_transform(result, 5880))

  testthat::expect_true(all(result_area <= br_area))
})



# ERRORS and messagens  -----------------------
test_that("remove_islands", {

  sf::st_crs(br) <- NA
  expect_error(remove_islands(br))
  expect_error(remove_islands(x = NULL))
  expect_error(remove_islands(x = "banana"))

})
