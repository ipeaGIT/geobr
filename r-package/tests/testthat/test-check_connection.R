context("check_connection")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


url_ok <- 'http://google.com/'
url_timeout <- 'http://www.google.com:81/'
url_error <- 'http://httpbin.org/status/300'


# expected success ------------------------------------
test_that("check_connection", {

  testthat::expect_true(check_connection(file_url = url_ok) )
})



# Expected errors to fail gracefully -----------------------
test_that("check_connection", {

  # broken link / non-existent
  testthat::expect_message( check_connection(file_url = "banana") )
  testthat::expect_false( check_connection(file_url = "banana") )

  # connection timeout
  testthat::expect_message( check_connection(file_url = url_timeout) )
  testthat::expect_false( check_connection(file_url = url_timeout) )

  # link not working
  testthat::expect_message( check_connection(file_url = url_error) )
  testthat::expect_false( check_connection(file_url = url_error) )

})
