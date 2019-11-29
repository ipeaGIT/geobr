context("Read")


# Reading the data -----------------------

test_that("read_intermediate_region", {

  # skip tests because they take too much time
  #skip_on_cran()
  skip_on_travis()

  # read data
  expect_message(read_intermediate_region(year=NULL))
  test_sf <- read_intermediate_region(year=2017)

  test_code_state <- read_intermediate_region(code_intermediate = 11)
  test_code_state2 <- read_intermediate_region(code_intermediate = "AC")


  # check sf object
  expect_true(is(test_sf, "sf"))
  expect_true(is(test_code_state, "sf"))
  expect_true(is(test_code_state2, "sf"))

  # check number of micro
  expect_equal(test_sf %>% length(), 8)
  expect_equal(test_code_state %>% length(), 8)
  expect_equal(test_code_state2 %>% length(), 8)

  # check projection
  expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})




# ERRORS and messagens  -----------------------
test_that("read_intermediate_region", {

  # skip tests because they take too much time
  #skip_on_cran()
  skip_on_travis()


  # Wrong year
  expect_error(read_intermediate_region(year = 9999999))
  expect_error(read_intermediate_region(year = "xxx"))



  # wrong year and code_immediate
  expect_error(read_intermediate_region(code_intermediate = "xxxx", year=9999999))
  expect_error(read_intermediate_region(code_intermediate = 9999999, year="xxx"))

})
