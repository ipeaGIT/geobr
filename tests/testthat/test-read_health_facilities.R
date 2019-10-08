context("Read")


# Testing metadata -----------------------

test_that("read_health_facilities", {

  # Get metadata with data addresses
  tempf <- file.path(tempdir(), "metadata.rds")

  # check if metadata has already been downloaded
  if (file.exists(tempf)) {
    metadata <- readr::read_rds(tempf)

  } else {
    # download it and save to metadata
    httr::GET(url="http://www.ipea.gov.br/geobr/metadata/metadata.rds", httr::write_disk(tempf, overwrite = T))
    metadata <- readr::read_rds(tempf)
  }


  # Select geo
  temp_meta <- subset(metadata, geo=="health_facilities")

  # list paths of files to download
  filesD <- as.character(temp_meta$download_path)


  expect_true(class(metadata)=='data.frame')
  expect_true(file.exists(tempf))
  expect_equal(filesD %>% length(), 1)
})


# Reading the data -----------------------

test_that("read_health_facilities", {

  # read data
  test_sf <- read_health_facilities()

  # check sf object
  expect_true(is(test_sf, "sf"))

  # check number of micro
  expect_equal(test_sf$code_cnes %>% length(), 360177)

  # check projection
#  expect_equal(sf::st_crs(test_all)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")

})



