context("Read")

test_that("read_weighting_area", {

  # read data
    # input State
    apABREV <- geobr::read_weighting_area(code_weighting="DF", year=2010)

    # input muni
    apMUNI <- geobr::read_weighting_area(code_weighting=5201108)

    # input weighting area
    apW <- geobr::read_weighting_area(code_weighting=5201108005004, year=2010)


  # check sf object
    expect_true(is(apABREV, "sf"))
    expect_true(is(apMUNI, "sf"))
    expect_true(is(apW, "sf"))


  # check number of weighting areas
  expect_equal(apABREV$code_weighting %>% length(), 51)

  # check projection
  expect_equal(sf::st_crs(apABREV)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")

})


# ERRORS
test_that("read_weighting_area", {

  # Wrong year
  expect_error(geobr::read_weighting_area(code_weighting="SC", year=2000000))

  # Wrong code
  expect_error(geobr::read_weighting_area(code_weighting="XXX", year=2000))
  expect_error(geobr::read_weighting_area( year=2000))

})


