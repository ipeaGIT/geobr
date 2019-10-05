context("Filter")

test_that("read_state", {

  # read data
  states <- read_state(code_state="all", year=2010)

  # check sf object
  expect_true(is(states, "sf"))

  # check number of states
  expect_equal(states$code_state %>% unique() %>% length(), 27)

  # check projection
  expect_equal(st_crs(states)[[2]], "+proj=longlat +ellps=GRS80 +no_defs")

})
