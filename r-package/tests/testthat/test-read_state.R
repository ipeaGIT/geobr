context("read_state")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


test_that("read_state", {

  # read data
  test_state_abrev <- read_state(code_state="AC", year=2010)
  test_state_abrev2 <- read_state(code_state="AP")
  test_state_abrev3 <- read_state(code_state='all', year=1872)

  test_state_code <- read_state(code_state=11, year=2010)
  test_state_code2 <- read_state(code_state=11)
#  test_state_code3 <- read_state(code_state=11, year=1872)

  test_all <- read_state(code_state="all", year=2010)
  test_all2 <- read_state(code_state="all")
  test_all3 <- read_state(code_state="all", year=1872)

  # check sf object
  expect_true(is(test_state_abrev, "sf"))
  expect_true(is(test_state_abrev2, "sf"))
  expect_true(is(test_state_abrev3, "sf"))
  expect_true(is(test_state_code, "sf"))
  expect_true(is(test_state_code2, "sf"))
  # expect_true(is(test_state_code3, "sf"))
  expect_true(is(test_all, "sf"))
  expect_true(is(test_all2, "sf"))
  expect_true(is(test_all3, "sf"))

  # check number of micro
  expect_equal(test_all$code_state %>% length(), 27)
  expect_equal(test_all3$name_state %>% length(), 21)

  # check projection
  expect_equal(sf::st_crs(test_all)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})




# ERRORS
test_that("read_state", {

  # Wrong year and code
  expect_error(read_state(code_state=9999999, year=9999999))
  expect_error(read_state(code_state=9999999, year="xxx"))
  expect_error(read_state(code_state="xxx", year=9999999))
  expect_error(read_state(code_state="xxx", year="xxx"))
  expect_error(read_state(code_state=NULL, year=9999999))
  expect_error(read_state(code_state=NULL, year="xxx"))

  # Wrong year
  expect_error(read_state(code_state=11, year=9999999))
  expect_error(read_state(code_state=1401, year=9999999))
  expect_error(read_state(code_state=11008, year=9999999))
  expect_error(read_state(code_state=11, year= "xx"))
  expect_error(read_state(code_state=1401, year= "xx"))
  expect_error(read_state(code_state=11008, year= "xx"))

  expect_error(read_state(code_state="all", year=9999999))
  expect_error(read_state(code_state="SC", year=9999999))
  expect_error(read_state(code_state="SC", year="xx"))
  expect_error(read_state(code_state="all", year="xx"))

  # Wrong code
#  expect_message(read_state(code_state=9999999, year=1991))
  expect_error(read_state(code_state=9999999, year=2000))
  expect_error(read_state(code_state=9999999))
#  expect_message(read_state(code_state="XXX", year=1991))
  expect_error(read_state(code_state="XXX", year=2000))
  expect_error(read_state(code_state="XXX"))
#  expect_message(read_state(code_state=NULL, year=1991))
  expect_error(read_state(code_state=NULL, year=2000))
  expect_error(read_state(code_state=NULL))

})
