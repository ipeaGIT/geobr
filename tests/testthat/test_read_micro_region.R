context("Read")

test_that("read_micro_region", {

  # read data
  micro <- geobr::read_micro_region(code_micro="all", year=2010)

  # check sf object
  expect_true(is(micro, "sf"))

  # check number of micro
  expect_equal(micro$code_micro %>% length(), 557)

  # check projection
  expect_equal(sf::st_crs(micro)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")

})


# micro <- geobr::read_micro_region(code_micro="all", year=2010)
# a <- subset(micro, is.na(code_micro))
#
# ggplot()+
#   geom_sf(data=micro, fill="gray50") +
#   geom_sf(data=a, fill="red")


# ERRORS
test_that("read_micro_region", {

  # Wrong year
  expect_error(geobr::read_micro_region(code_micro="SC", year=2000000))

  # Wrong code
  expect_error(geobr::read_micro_region(code_micro="XXX", year=2000))
  expect_error(geobr::read_micro_region( year=2000))

})


