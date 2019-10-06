context("Read")

# R/read_micro_region.R: 65.12%
# R/read_micro_region.R: 93.02%

# test_that("read_micro_region", {
#
#   # test metada
#   tempf <- file.path(tempdir(), "metadata.rds")
#
#   # check if metadata has already been downloaded
#   if (file.exists(tempf)) {
#     metadata <- readr::read_rds(tempf)
#
#   } else {
#     # download it and save to metadata
#     httr::GET(url="http://www.ipea.gov.br/geobr/metadata/metadata.rds", httr::write_disk(tempf, overwrite = T))
#     metadata <- readr::read_rds(tempf)
#   }
#
#   expect_true(class(metadata)=='data.frame')
#   expect_true(file.exists(tempf))
#
# })



test_that("read_micro_region", {

  # read data
  test_micro_code <- geobr::read_micro_region(code_micro=11008, year=2010)
  test_micro_code2 <- geobr::read_micro_region(code_micro=11008, year=NULL)

  test_state_abrev <- geobr::read_micro_region(code_micro="AC", year=2010)
  test_state_abrev2 <- geobr::read_micro_region(code_micro="AP", year=NULL)

  test_state_code <- geobr::read_micro_region(code_micro=11, year=2010)
  test_state_code2 <- geobr::read_micro_region(code_micro=11, year=NULL)

  test_all <- geobr::read_micro_region(code_micro="all", year=2010)
  test_all2 <- geobr::read_micro_region(code_micro="all", year=NULL)

  # check sf object
  expect_true(is(test_micro_code, "sf"))
  expect_true(is(test_micro_code2, "sf"))
  expect_true(is(test_state_abrev, "sf"))
  expect_true(is(test_state_abrev2, "sf"))
  expect_true(is(test_state_code, "sf"))
  expect_true(is(test_state_code2, "sf"))
  expect_true(is(test_all, "sf"))
  expect_true(is(test_all2, "sf"))

  # check number of micro
  expect_equal(test_all$code_micro %>% length(), 557)

  # check projection
  expect_equal(sf::st_crs(test_all)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")

})


# test_all <- geobr::read_micro_region(code_micro="all", year=2010)
# a <- subset(test_all, is.na(code_micro))
#
# ggplot()+
#   geom_sf(data=test_all, fill="gray50") +
#   geom_sf(data=a, fill="red")


# ERRORS
# ERRORS
# test_that("read_micro_region", {
#
#   # Wrong year and code
#   expect_error(geobr::read_micro_region(code_micro=9999999, year=9999999))
#   expect_error(geobr::read_micro_region(code_micro=9999999, year="xxx"))
#   expect_error(geobr::read_micro_region(code_micro="xxx", year=9999999))
#   expect_error(geobr::read_micro_region(code_micro="xxx", year="xxx"))
#   expect_error(geobr::read_micro_region(code_micro=9999999, year=NULL))
#
#   # Wrong year  expect_error(geobr::read_micro_region(code_micro="xxx", year=NULL))
#   expect_error(geobr::read_micro_region(code_micro=11, year=9999999))
#   expect_error(geobr::read_micro_region(code_micro=11, year= "xx"))
#   expect_error(geobr::read_micro_region(code_micro=11008, year=9999999))
#   expect_error(geobr::read_micro_region(code_micro=11008, year= "xx"))
#
#
#
#   expect_error(geobr::read_micro_region(code_micro="SC", year=9999999))
#   expect_error(geobr::read_micro_region(code_micro="SC", year="xx"))
#
#   expect_error(geobr::read_micro_region(code_micro="all", year=9999999))
#   expect_error(geobr::read_micro_region(code_micro="all", year="xx"))
#
#   # Wrong code
#   expect_error(geobr::read_micro_region(code_micro=9999999, year=2000))
#   expect_error(geobr::read_micro_region(code_micro="XXX", year=2000))
#   expect_error(geobr::read_micro_region(code_micro="XXX", year=NULL))
#   expect_error(geobr::read_micro_region(code_micro=NULL, year=2000))
# })


# ERRORS
test_that("read_micro_region", {

  # Wrong year and code
  expect_error(geobr::read_micro_region(code_micro=9999999, year=9999999))
  expect_error(geobr::read_micro_region(code_micro=9999999, year="xxx"))
  expect_error(geobr::read_micro_region(code_micro="xxx", year=9999999))
  expect_error(geobr::read_micro_region(code_micro="xxx", year="xxx"))
  expect_error(geobr::read_micro_region(code_micro=NULL, year=9999999))
  expect_error(geobr::read_micro_region(code_micro=NULL, year="xxx"))

  # Wrong year
  expect_error(geobr::read_micro_region(code_micro=11, year=9999999))
  expect_error(geobr::read_micro_region(code_micro=1401, year=9999999))
  expect_error(geobr::read_micro_region(code_micro=11008, year=9999999))
  expect_error(geobr::read_micro_region(code_micro=11, year= "xx"))
  expect_error(geobr::read_micro_region(code_micro=1401, year= "xx"))
  expect_error(geobr::read_micro_region(code_micro=11008, year= "xx"))

  expect_error(geobr::read_micro_region(code_micro="all", year=9999999))
  expect_error(geobr::read_micro_region(code_micro="SC", year=9999999))
  expect_error(geobr::read_micro_region(code_micro="SC", year="xx"))
  expect_error(geobr::read_micro_region(code_micro="all", year="xx"))

  # Wrong code
  expect_error(geobr::read_micro_region(code_micro=9999999, year=2000))
  expect_error(geobr::read_micro_region(code_micro=9999999, year=NULL))
  expect_error(geobr::read_micro_region(code_micro="XXX", year=2000))
  expect_error(geobr::read_micro_region(code_micro="XXX", year=NULL))
  expect_error(geobr::read_micro_region(code_micro=NULL, year=2000))
  expect_error(geobr::read_micro_region(code_micro=NULL, year=NULL))

})
