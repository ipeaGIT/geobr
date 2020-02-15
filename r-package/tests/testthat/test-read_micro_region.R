context("Read")

test_that("read_micro_region", {

  # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()

  # read data
  test_micro_code <- read_micro_region(code_micro=11008, year=2010)
  test_micro_code2 <- read_micro_region(code_micro=11008, year=NULL)

  test_state_abrev <- read_micro_region(code_micro="AC", year=2010)
  test_state_abrev2 <- read_micro_region(code_micro="AP", year=NULL)

  test_state_code <- read_micro_region(code_micro=11, year=2010)
  test_state_code2 <- read_micro_region(code_micro=11, year=NULL)

  test_all <- read_micro_region(code_micro="all", year=2010)
  test_all2 <- read_micro_region(code_micro="all", year=NULL)

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
  expect_equal(sf::st_crs(test_all)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})



# ERRORS
test_that("read_micro_region", {

  # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()

  # Wrong year and code
  expect_error(read_micro_region(code_micro=9999999, year=9999999))
  expect_error(read_micro_region(code_micro=9999999, year="xxx"))
  expect_error(read_micro_region(code_micro="xxx", year=9999999))
  expect_error(read_micro_region(code_micro="xxx", year="xxx"))
  expect_error(read_micro_region(code_micro=NULL, year=9999999))
  expect_error(read_micro_region(code_micro=NULL, year="xxx"))

  # Wrong year
  expect_error(read_micro_region(code_micro=11, year=9999999))
  expect_error(read_micro_region(code_micro=1401, year=9999999))
  expect_error(read_micro_region(code_micro=11008, year=9999999))
  expect_error(read_micro_region(code_micro=11, year= "xx"))
  expect_error(read_micro_region(code_micro=1401, year= "xx"))
  expect_error(read_micro_region(code_micro=11008, year= "xx"))

  expect_error(read_micro_region(code_micro="all", year=9999999))
  expect_error(read_micro_region(code_micro="SC", year=9999999))
  expect_error(read_micro_region(code_micro="SC", year="xx"))
  expect_error(read_micro_region(code_micro="all", year="xx"))

  # Wrong code
  expect_error(read_micro_region(code_micro=9999999, year=2000))
  expect_error(read_micro_region(code_micro=9999999, year=NULL))
  expect_error(read_micro_region(code_micro="XXX", year=2000))
  expect_error(read_micro_region(code_micro="XXX", year=NULL))
  expect_error(read_micro_region(code_micro=NULL, year=2000))
  expect_error(read_micro_region(code_micro=NULL, year=NULL))

})
