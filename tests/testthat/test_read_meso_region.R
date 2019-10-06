context("Read")

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


