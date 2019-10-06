context("Read")


# Reading the data -----------------------

test_that("read_disaster_risk_area", {

  # read data
  test_sf <- geobr::read_disaster_risk_area(year=2010)

  # check sf object
  expect_true(is(test_sf, "sf"))

  # check number of micro
  expect_equal(test_sf$geo_bater %>% length(), 8309)

  # check projection
  expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")

})




# ERRORS and messagens  -----------------------
test_that("read_disaster_risk_area", {

  # Wrong year
  expect_error(geobr::read_disaster_risk_area(year=9999999))
  expect_error(geobr::read_disaster_risk_area(year="xxx"))
  expect_error(geobr::read_disaster_risk_area(year=NULL))

})
