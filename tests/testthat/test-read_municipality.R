context("Read")

test_that("read_municipality", {

  # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()

    # read data
  test_code_1991 <- read_municipality(code_muni=1200179, year=1991)
  test_code_2010 <- read_municipality(code_muni=1200179, year=2010)
  test_code2_2010 <- read_municipality(code_muni=1200179, year=NULL)

  test_state_abrev_1991 <- read_municipality(code_muni="AC", year=1991)
  test_state_abrev_2010 <- read_municipality(code_muni="AC", year=2010)
  test_state_abrev2_2010 <- read_municipality(code_muni="AP", year=NULL)

  test_state_code_1991 <- read_municipality(code_muni=11, year=1991)
  test_state_code_2010 <- read_municipality(code_muni=11, year=2010)
  test_state_code2_2010 <- read_municipality(code_muni=11, year=NULL)

  test_all_1991 <- read_municipality(code_muni='all', year=1991)
  test_all_2010 <- read_municipality(code_muni='all', year=2010)
  test_all2_2010 <- read_municipality(code_muni='all', year=NULL)

  # check sf object
  expect_true(is(test_code_1991, "sf"))
  expect_true(is(test_code_2010, "sf"))
  expect_true(is(test_code2_2010, "sf"))
  expect_true(is(test_state_abrev_1991, "sf"))
  expect_true(is(test_state_abrev_2010, "sf"))
  expect_true(is(test_state_abrev2_2010, "sf"))
  expect_true(is(test_state_code_1991, "sf"))
  expect_true(is(test_state_code_2010, "sf"))
  expect_true(is(test_state_code2_2010, "sf"))
  expect_true(is(test_all_1991, "sf"))
  expect_true(is(test_all_2010, "sf"))
  expect_true(is(test_all2_2010, "sf"))

  # check projection
  expect_equal(sf::st_crs(test_code_2010)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")
  # expect_equal(sf::st_crs(test_code_1991)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")

})


# ERRORS
test_that("read_municipality", {

  # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()

  # Wrong year and code
  expect_error(read_municipality(code_muni=9999999, year=9999999))
  expect_error(read_municipality(code_muni=9999999, year="xxx"))
  expect_error(read_municipality(code_muni="xxx", year=9999999))
  expect_error(read_municipality(code_muni="xxx", year="xxx"))
  expect_error(read_municipality(code_muni=9999999, year=NULL))

  # Wrong year  expect_error(read_municipality(code_muni="xxx", year=NULL))
  expect_error(read_municipality(code_muni=11, year=9999999))
  expect_error(read_municipality(code_muni=11, year= "xx"))
  expect_error(read_municipality(code_muni=1401, year=9999999))
  expect_error(read_municipality(code_muni=1401, year= "xx"))

  expect_error(read_municipality(code_muni="SC", year=9999999))
  expect_error(read_municipality(code_muni="SC", year="xx"))

  expect_error(read_municipality(code_muni="all", year=9999999))
  expect_error(read_municipality(code_muni="all", year="xx"))

  # Wrong code
  expect_error(read_municipality(code_muni=9999999, year=2000))
  expect_error(read_municipality(code_muni="XXX", year=2000))
  expect_error(read_municipality(code_muni="XXX", year=NULL))
  expect_error(read_municipality(code_muni=NULL, year=2000))

})
