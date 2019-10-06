context("Read")

test_that("read_state", {

  # read data
  states <- geobr::read_state(code_state="all", year=2010)

  # check sf object
  expect_true(is(states, "sf"))

  # check number of states
  expect_equal(states$code_state %>% length(), 27)

  # check projection
  expect_equal(sf::st_crs(states)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")

})


# ERRORS
test_that("read_state", {

  # Wrong year
  expect_error(geobr::read_state(code_state="SC", year=2000000))

  # Wrong code
  expect_error(geobr::read_state(code_state="XXX", year=2000))
  expect_error(geobr::read_state( year=2000))

})


