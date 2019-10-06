context("Read")

test_that("read_municipality", {

  # read data
  munis7d <- geobr::read_municipality(code_muni=1200179, year=2010)

  # check sf object
  expect_true(is(munis7d, "sf"))

  # read data
  munis2d <- geobr::read_municipality(code_muni=12, year=2018)

  # check number of states
  expect_equal(munis2d$code_muni %>% length(), 22)

  # check projection
  expect_equal(sf::st_crs(munis2d)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")

})


# ERRORS
test_that("read_municipality", {

  # Wrong year
  expect_error(geobr::read_municipality(code_muni="SC", year=2000000))

  # Wrong code
  expect_error(geobr::read_municipality(code_muni="XXX", year=2000))
  expect_error(geobr::read_municipality( year=2000))

})


