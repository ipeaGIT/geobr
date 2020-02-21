context("read_meso_region")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")


test_that("read_meso_region", {

  # read data
  test_code <- read_meso_region(code_meso=1401, year=2010)
  test_code2 <- read_meso_region(code_meso=1401, year=NULL)

  test_state_abrev <- read_meso_region(code_meso="AC", year=2010)
  test_state_abrev2 <- read_meso_region(code_meso="AP", year=NULL)

  test_state_code <- read_meso_region(code_meso=11, year=2010)
  test_state_code2 <- read_meso_region(code_meso=11, year=NULL)

  test_all <- read_meso_region( year=2010)
  test_all2 <- read_meso_region(code_meso="all", year=NULL)
  expect_true(identical(test_all, test_all2))

  # check sf object
  expect_true(is(test_code, "sf"))
  expect_true(is(test_code2, "sf"))
  expect_true(is(test_state_abrev, "sf"))
  expect_true(is(test_state_abrev2, "sf"))
  expect_true(is(test_state_code, "sf"))
  expect_true(is(test_state_code2, "sf"))
  expect_true(is(test_all, "sf"))
  expect_true(is(test_all2, "sf"))

  # check number of meso
  expect_equal(test_all$code_meso %>% length(), 137)

  # check projection
  expect_equal(sf::st_crs(test_all)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})


# ERRORS
test_that("read_meso_region", {

  # Wrong year and code
    expect_error(read_meso_region(code_meso=9999999, year=9999999))
    expect_error(read_meso_region(code_meso=9999999, year="xxx"))
    expect_error(read_meso_region(code_meso="xxx", year=9999999))
    expect_error(read_meso_region(code_meso="xxx", year="xxx"))
    expect_error(read_meso_region(code_meso=9999999, year=NULL))

  # Wrong year  expect_error(read_meso_region(code_meso="xxx", year=NULL))
    expect_error(read_meso_region(code_meso=11, year=9999999))
    expect_error(read_meso_region(code_meso=11, year= "xx"))
    expect_error(read_meso_region(code_meso=1401, year=9999999))
    expect_error(read_meso_region(code_meso=1401, year= "xx"))

    expect_error(read_meso_region(code_meso="SC", year=9999999))
    expect_error(read_meso_region(code_meso="SC", year="xx"))

    expect_error(read_meso_region(code_meso="all", year=9999999))
    expect_error(read_meso_region(code_meso="all", year="xx"))

  # Wrong code
     expect_error(read_meso_region(code_meso=9999999, year=2000))
     expect_error(read_meso_region(code_meso="XXX", year=2000))
     expect_error(read_meso_region(code_meso="XXX", year=NULL))
     expect_error(read_meso_region(code_meso=NULL, year=2000))
})
