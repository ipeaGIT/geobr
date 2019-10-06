context("Read")


# test_that("read_meso_region", {
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


test_that("read_meso_region", {

  # read data
  test_meso_code <- geobr::read_meso_region(code_meso=1401, year=2010)
  test_meso_code2 <- geobr::read_meso_region(code_meso=1401, year=NULL)

  test_state_abrev <- geobr::read_meso_region(code_meso="AC", year=2010)
  test_state_abrev2 <- geobr::read_meso_region(code_meso="AP", year=NULL)

  test_state_code <- geobr::read_meso_region(code_meso=11, year=2010)
  test_state_code2 <- geobr::read_meso_region(code_meso=11, year=NULL)

  test_all <- geobr::read_meso_region(code_meso="all", year=2010)
  test_all2 <- geobr::read_meso_region(code_meso="all", year=NULL)

  # check sf object
  expect_true(is(test_meso_code, "sf"))
  expect_true(is(test_meso_code2, "sf"))
  expect_true(is(test_state_abrev, "sf"))
  expect_true(is(test_state_abrev2, "sf"))
  expect_true(is(test_state_code, "sf"))
  expect_true(is(test_state_code2, "sf"))
  expect_true(is(test_all, "sf"))
  expect_true(is(test_all2, "sf"))

  # check number of meso
  expect_equal(test_all$code_meso %>% length(), 137)

  # check projection
  expect_equal(sf::st_crs(test_all)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")

})


# ERRORS
test_that("read_meso_region", {

  # Wrong year and code
    expect_error(geobr::read_meso_region(code_meso=9999999, year=9999999))
    expect_error(geobr::read_meso_region(code_meso=9999999, year="xxx"))
    expect_error(geobr::read_meso_region(code_meso="xxx", year=9999999))
    expect_error(geobr::read_meso_region(code_meso="xxx", year="xxx"))
    expect_error(geobr::read_meso_region(code_meso=9999999, year=NULL))

  # Wrong year  expect_error(geobr::read_meso_region(code_meso="xxx", year=NULL))
    expect_error(geobr::read_micro_region(code_micro=11, year=9999999))
    expect_error(geobr::read_micro_region(code_micro=11, year= "xx"))

    expect_error(geobr::read_meso_region(code_meso="SC", year=9999999))
    expect_error(geobr::read_meso_region(code_meso="SC", year="xx"))

    expect_error(geobr::read_micro_region(code_micro="all", year=9999999))
    expect_error(geobr::read_micro_region(code_micro="all", year="xx"))

  # Wrong code
   expect_error(geobr::read_meso_region(code_meso=9999999, year=2000))
   expect_error(geobr::read_meso_region(code_meso="XXX", year=2000))
   expect_error(geobr::read_meso_region(code_meso="XXX", year=NULL))
   expect_error(geobr::read_meso_region(code_meso=NULL, year=2000))

})


