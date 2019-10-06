context("Read")

# R/read_micro_region.R: 60.47%


test_that("read_micro_region", {

  # test metada
  tempf <- file.path(tempdir(), "metadata.rds")
  expect_true(file.exists(tempf))

  # read data
  micro_micro_code <- geobr::read_micro_region(code_micro=11008, year=2010)
  micro_state_abrev <- geobr::read_micro_region(code_micro="AC", year=2010)
  micro_state_abrev <- geobr::read_micro_region(code_micro="AP", year=NULL)
  micro_state_code <- geobr::read_micro_region(code_micro=11, year=2010)
  micro_all <- geobr::read_micro_region(code_micro="all", year=2010)

  # check sf object
  expect_true(is(micro_micro_code, "sf"))
  expect_true(is(micro_state_abrev, "sf"))
  expect_true(is(micro_state_abrev, "sf"))
  expect_true(is(micro_state_code, "sf"))

  # check number of micro
  expect_equal(micro_all$code_micro %>% length(), 557)

  # check projection
  expect_equal(sf::st_crs(micro_all)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")

})


# micro_all <- geobr::read_micro_region(code_micro="all", year=2010)
# a <- subset(micro_all, is.na(code_micro))
#
# ggplot()+
#   geom_sf(data=micro_all, fill="gray50") +
#   geom_sf(data=a, fill="red")


# ERRORS
test_that("read_micro_region", {

  # Wrong year
  expect_error(geobr::read_micro_region(code_micro="SC", year=2000000))
  expect_error(geobr::read_micro_region(code_micro=11, year=2000000))
  expect_error(geobr::read_micro_region(code_micro=11, year= "xx"))

  # Wrong code
  expect_error(geobr::read_micro_region(code_micro="xx", year=2000))
  expect_error(geobr::read_micro_region( code_micro=NULL, year=2000))

})


