context("read_immediate_region")

# skip tests because they take too much time
testthat::skip_on_cran()
# testthat::skip_on_travis()
# skip_if(Sys.getenv("TEST_ONE") != "")

# Reading the data -----------------------

test_that("read_immediate_region", {

  # read data
  testthat::expect_output( read_immediate_region() )
  testthat::expect_output( read_immediate_region(code_immediate = 11) )
  testthat::expect_output( read_immediate_region(code_immediate = "AC") )

  test_code_muni <- read_immediate_region(code_immediate =  110002)


  # check number of micro
  testthat::expect_equal(test_code_muni %>% length(), 8)

  # check projection
  testthat::expect_equal(sf::st_crs(test_code_muni)$proj4string, "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs ")

})




# ERRORS and messagens  -----------------------
test_that("read_immediate_region", {

  # Wrong year
  testthat::expect_error(read_immediate_region(year = 9999999))
  testthat::expect_error(read_immediate_region(year = "xxx"))
  testthat::expect_error(read_immediate_region(code_immediate=5201108312313213))


  # wrong year and code_immediate
  testthat::expect_error(read_immediate_region(code_immediate = "xxxx", year=9999999))
  testthat::expect_error(read_immediate_region(code_immediate = 9999999, year="xxx"))

})

