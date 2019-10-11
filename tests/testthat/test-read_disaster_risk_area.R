context("Read")




# Downloading the data -----------------------

test_that("read_disaster_risk_area", {

  # skip tests because they take too much time
  skip_on_cran()

  # Get metadata with data addresses
  tempf <- file.path(tempdir(), "metadata.rds")

  # check if metadata has already been downloaded
  if (file.exists(tempf)) {
    metadata <- readr::read_rds(tempf)

  } else {

    # download it and save to metadata
    httr::GET(url="http://www.ipea.gov.br/geobr/metadata/metadata.rds", httr::write_disk(tempf, overwrite = T))
    metadata <- readr::read_rds(tempf)

    # test
    expect_equal(tempf %>% length(), 1)
    expect_equal(ncol(metadata), 5)
    }

}
)





# Reading the data -----------------------

test_that("read_disaster_risk_area", {

  # skip tests because they take too much time
  skip_on_cran()


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

  # Wrong year
  expect_error(read_disaster_risk_area(year=9999999))
  expect_error(read_disaster_risk_area(year="xxx"))
  expect_error(read_disaster_risk_area(year=NULL))

})
