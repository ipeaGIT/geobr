context("read_municipality")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


test_that("read_municipality", {

  # read data
  test_1970 <- read_municipality(code_muni=1100205, year=1970)
  test_2010 <- read_municipality(code_muni=1100205, year=2010)

  # check sf object
  testthat::expect_true(is(test_1970, "sf"))
  testthat::expect_true(is(test_2010, "sf"))

  testthat::expect_true(is(  read_municipality( year=1970)  , "sf"))
  testthat::expect_true(is(  read_municipality(code_muni=11, year=1970)  , "sf"))
   # testthat::expect_true(is(  read_municipality(code_muni=11, year=1970, simplified = F) , "sf"))
  # testthat::expect_true(is(  read_municipality(code_muni='all', year=1970) , "sf"))
  # testthat::expect_true(is(  read_municipality(code_muni='all', year=1970, simplified = F) , "sf"))
  testthat::expect_true(is(  read_municipality(code_muni='AC', year=1970) , "sf"))
  testthat::expect_true(is(  read_municipality(code_muni=1100205, year=1970) , "sf"))

  testthat::expect_true(is(  read_municipality() , "sf"))
  testthat::expect_true(is(  read_municipality( year=2010) , "sf"))
  # testthat::expect_true(is(  read_municipality(code_muni=11, year=2010) , "sf"))
  testthat::expect_true(is(  read_municipality(code_muni=11, year=2010, simplified = F) , "sf"))
  # testthat::expect_true(is(  read_municipality(code_muni='all', year=2010) , "sf"))
  # testthat::expect_true(is(  read_municipality(code_muni='all', year=2010, simplified = F) , "sf"))
  testthat::expect_true(is(  read_municipality(code_muni='AC', year=2010)  , "sf"))
  testthat::expect_true(is(  read_municipality(code_muni=1200179, year=2010) , "sf"))

  # check filter
  test_filter <-  read_municipality(code_muni=1200179, year=2010)
  expect_equal( nrow(test_filter), 1)

  # check keep_areas_operacionais
  n22f <- read_municipality(code_muni = 'all', year = 2022) |> nrow()
  n22t <- read_municipality(code_muni = 'all', year = 2022, keep_areas_operacionais = TRUE) |> nrow()
  testthat::expect_true(n22t > n22f)

  # test cache
  cache_true <- system.time(read_municipality(cache = TRUE))
  cache_false <- system.time(read_municipality(cache = FALSE))
  cache_false[[3]] > cache_true[[3]]
})


# ERRORS
test_that("read_municipality", {

  # Wrong code
  testthat::expect_error(read_municipality(code_muni=9999999, year=2010))
  testthat::expect_error(read_municipality(code_muni=9999999, year=1970))
  testthat::expect_error(read_municipality(code_muni=5201108312313213, year=2010))
  testthat::expect_error(read_municipality(code_muni=5201108312313213, year=1970))
  testthat::expect_error(read_municipality(code_muni=NULL))

  testthat::expect_error(read_municipality(code_muni="RJ_ABC", year=2010))
  testthat::expect_error(read_municipality(code_muni="RJ_ABC", year=1970))
  testthat::expect_error(read_municipality(code_muni="AAA", year=2010))
  testthat::expect_error(read_municipality(code_muni="AAA", year=1970))


  # Wrong year
  testthat::expect_error(read_municipality( year=9999999))
  testthat::expect_error(read_municipality( year='SASa'))
  testthat::expect_error(read_municipality( year=NULL))
  testthat::expect_error(read_municipality( showProgress = 'aaaaa'))
  testthat::expect_error(read_municipality( showProgress = NULL))
  testthat::expect_error(read_municipality( simplified = 'aaaaa'))
  testthat::expect_error(read_municipality( simplified = NULL))
  testthat::expect_error(read_municipality( cache = 'aaaaa'))
  testthat::expect_error(read_municipality( cache = NULL))
  testthat::expect_error(read_municipality( keep_areas_operacionais = 'aaaaa'))
  testthat::expect_error(read_municipality( keep_areas_operacionais = NULL))

})
