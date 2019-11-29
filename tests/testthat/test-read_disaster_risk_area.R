context("Read")




# Downloading the data -----------------------

test_that("read_disaster_risk_area", {

  # skip tests because they take too much time
  #skip_on_cran()
  skip_on_travis()

  # read data
  test_sf <- read_disaster_risk_area(year=2010)
    # test
    expect_equal(test_sf %>% length(), 10)


}
)





# Reading the data -----------------------

test_that("read_disaster_risk_area", {

  # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()

  # read data
  test_sf <- read_disaster_risk_area(year=2010)

  # check sf object
  expect_true(is(test_sf, "sf"))

  # check number of micro
  expect_equal(test_sf$geo_bater %>% length(), 8309)

  # check projection
  expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")

})




# ERRORS and messagens  -----------------------
test_that("read_disaster_risk_area", {

  # skip tests because they take too much time
  #skip_on_cran()
  skip_on_travis()

  # Wrong year
  expect_error(read_disaster_risk_area(year=9999999))
  expect_error(read_disaster_risk_area(year="xxx"))
  expect_error(read_disaster_risk_area(year=NULL))

})
