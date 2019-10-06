context("Read")


test_that("read_statistical_grid", {

  # read data
  test_quad_code <- geobr::read_statistical_grid(code_grid=44, year=2010)
  test_quad_code2 <- geobr::read_statistical_grid(code_grid=44, year=NULL)

  test_state_abrev <- geobr::read_statistical_grid(code_grid="AC", year=2010)
  test_state_abrev2 <- geobr::read_statistical_grid(code_grid="AP", year=NULL)


  # check sf object
  expect_true(is(test_quad_code, "sf"))
  expect_true(is(test_quad_code2, "sf"))
  expect_true(is(test_state_abrev, "sf"))
  expect_true(is(test_state_abrev2, "sf"))

  # check number of micro
  expect_equal(test_state_abrev2$ID_UNICO %>% length(), 778694)
  # clean memory
  rm(test_quad_code, test_quad_code2, test_state_abrev, test_state_abrev2)
  gc(reset = T)

   # test_all <- geobr::read_statistical_grid(code_grid="all", year=2010)
   # expect_true(is(test_all, "sf"))

   # test_all2 <- geobr::read_statistical_grid(code_grid="all", year=NULL)
   # expect_true(is(test_all2, "sf"))


  # check projection
  #expect_equal(sf::st_crs(test_all)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")

})



# ERRORS
test_that("read_statistical_grid", {

  # Wrong year and code
  expect_error(geobr::read_statistical_grid(code_grid=9999999, year=9999999))
  expect_error(geobr::read_statistical_grid(code_grid=9999999, year="xxx"))
  expect_error(geobr::read_statistical_grid(code_grid="xxx", year=9999999))
  expect_error(geobr::read_statistical_grid(code_grid="xxx", year="xxx"))
  expect_error(geobr::read_statistical_grid(code_grid=NULL, year=9999999))
  expect_error(geobr::read_statistical_grid(code_grid=NULL, year="xxx"))

  # Wrong year
  expect_error(geobr::read_statistical_grid(code_grid=11, year=9999999))
  expect_error(geobr::read_statistical_grid(code_grid=1401, year=9999999))
  expect_error(geobr::read_statistical_grid(code_grid=11008, year=9999999))
  expect_error(geobr::read_statistical_grid(code_grid=11, year= "xx"))
  expect_error(geobr::read_statistical_grid(code_grid=1401, year= "xx"))
  expect_error(geobr::read_statistical_grid(code_grid=11008, year= "xx"))

  expect_error(geobr::read_statistical_grid(code_grid="all", year=9999999))
  expect_error(geobr::read_statistical_grid(code_grid="SC", year=9999999))
  expect_error(geobr::read_statistical_grid(code_grid="SC", year="xx"))
  expect_error(geobr::read_statistical_grid(code_grid="all", year="xx"))

  # Wrong code
  expect_error(geobr::read_statistical_grid(code_grid=9999999, year=2000))
#  expect_error(geobr::read_statistical_grid(code_grid=9999999, year=NULL))
  expect_error(geobr::read_statistical_grid(code_grid="XXX", year=2000))
#  expect_error(geobr::read_statistical_grid(code_grid="XXX", year=NULL))
  expect_error(geobr::read_statistical_grid(code_grid=NULL, year=2000))
#  expect_error(geobr::read_statistical_grid(code_grid=NULL, year=NULL))

})
