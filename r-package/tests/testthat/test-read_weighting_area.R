context("Read")

test_that("read_weighting_area", {

  # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()

  # read data

    # input weighting area
    test_code <- read_weighting_area(code_weighting=5201108005004, year=2010)
    test_code2 <- read_weighting_area(code_weighting=5201108005004, year=NULL)

    # input muni
    test_muni <- read_weighting_area(code_weighting=5201108, year=2010)
    test_muni2 <- read_weighting_area(code_weighting=5201108, year=NULL)


    test_abrev <- read_weighting_area(code_weighting="AC", year=2010)
    test_abrev2 <- read_weighting_area(code_weighting="AP", year=NULL)

    test_state <- read_weighting_area(code_weighting=11, year=2010)
    test_state2 <- read_weighting_area(code_weighting=11, year=NULL)

    test_all <- read_weighting_area(code_weighting="all", year=2010)
    test_all2 <- read_weighting_area(code_weighting="all", year=NULL)


  # check sf object
    expect_true(is(test_code, "sf"))
    expect_true(is(test_code2, "sf"))
    expect_true(is(test_muni, "sf"))
    expect_true(is(test_muni2, "sf"))
    expect_true(is(test_abrev, "sf"))
    expect_true(is(test_abrev2, "sf"))
    expect_true(is(test_state, "sf"))
    expect_true(is(test_state2, "sf"))
    expect_true(is(test_all, "sf"))
    expect_true(is(test_all2, "sf"))


  # check number of weighting areas
  expect_equal(test_abrev$code_weighting %>% length(), 8)

  # check projection
  expect_equal(sf::st_crs(test_abrev)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})


# ERRORS
test_that("read_weighting_area", {

  # skip tests because they take too much time
  skip_on_cran()
  skip_on_travis()

  # Wrong year and code
  expect_error(read_weighting_area(code_weighting=9999999, year=9999999))
  expect_error(read_weighting_area(code_weighting=9999999, year="xxx"))
  expect_error(read_weighting_area(code_weighting="xxx", year=9999999))
  expect_error(read_weighting_area(code_weighting="xxx", year="xxx"))
  expect_error(read_weighting_area(code_weighting=9999999, year=NULL))

  # Wrong year  expect_error(read_weighting_area(code_weighting="xxx", year=NULL))
  expect_error(read_weighting_area(code_weighting=11, year=9999999))
  expect_error(read_weighting_area(code_weighting=11, year= "xx"))
  expect_error(read_weighting_area(code_weighting=1401, year=9999999))
  expect_error(read_weighting_area(code_weighting=1401, year= "xx"))

  expect_error(read_weighting_area(code_weighting="SC", year=9999999))
  expect_error(read_weighting_area(code_weighting="SC", year="xx"))

  expect_error(read_weighting_area(code_weighting="all", year=9999999))
  expect_error(read_weighting_area(code_weighting="all", year="xx"))

  # Wrong code
  expect_error(read_weighting_area(code_weighting=9999999, year=2000))
  expect_error(read_weighting_area(code_weighting="XXX", year=2000))
  expect_error(read_weighting_area(code_weighting="XXX", year=NULL))
  expect_error(read_weighting_area(code_weighting=NULL, year=2000))

})
