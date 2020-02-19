context("read_immediate_region")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")

# Reading the data -----------------------

test_that("read_immediate_region", {

  # read data
  expect_message(read_immediate_region(year=NULL))
  test_sf <- read_immediate_region(year=2017)

  test_code_state <- read_immediate_region(code_immediate = 11)
  test_code_state2 <- read_immediate_region(code_immediate = "AC")

  test_code_muni <- read_immediate_region(code_immediate =  110002)


  # check sf object
  expect_true(is(test_sf, "sf"))
  expect_true(is(test_code_state, "sf"))
  expect_true(is(test_code_state2, "sf"))
  expect_true(is(test_code_muni, "sf"))

  # check number of micro
  expect_equal(test_sf %>% length(), 8)
  expect_equal(test_code_state %>% length(), 8)
  expect_equal(test_code_state2 %>% length(), 8)
  expect_equal(test_code_muni %>% length(), 8)

  # check projection
  expect_equal(sf::st_crs(test_sf)[[2]], "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

})




# ERRORS and messagens  -----------------------
test_that("read_immediate_region", {


  # Wrong year
  expect_error(read_immediate_region(year = 9999999))
  expect_error(read_immediate_region(year = "xxx"))



  # wrong year and code_immediate
  expect_error(read_immediate_region(code_immediate = "xxxx", year=9999999))
  expect_error(read_immediate_region(code_immediate = 9999999, year="xxx"))

})
