context("Read")


test_that("read_micro_region", {

  # test metada
  tempf <- file.path(tempdir(), "metadata.rds")

  # check if metadata has already been downloaded
  if (file.exists(tempf)) {
    metadata <- readr::read_rds(tempf)

  } else {
    # download it and save to metadata
    httr::GET(url="http://www.ipea.gov.br/geobr/metadata/metadata.rds", httr::write_disk(tempf, overwrite = T))
    metadata <- readr::read_rds(tempf)
  }

  expect_true(class(metadata)=='data.frame')
  expect_true(file.exists(tempf))

})


test_that("read_meso_region", {

  # read data
  meso <- geobr::read_meso_region(code_meso="all", year=2010)

  # check sf object
  expect_true(is(meso, "sf"))

  # check number of meso
  expect_equal(meso$code_meso %>% length(), 137)

  # check projection
  expect_equal(sf::st_crs(meso)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")

})


# ERRORS
test_that("read_meso_region", {

  # Wrong year
  expect_error(geobr::read_meso_region(code_meso="SC", year=2000000))

  # Wrong code
  expect_error(geobr::read_meso_region(code_meso="XXX", year=2000))
  expect_error(geobr::read_meso_region( year=2000))

})


