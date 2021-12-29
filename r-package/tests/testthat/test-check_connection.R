context("check_connection")

# # skip tests because they take too much time
# skip_if(Sys.getenv("TEST_ONE") != "")
# testthat::skip_on_cran()


test_that("check_connection", {

  testthat::expect_invisible( check_connection() )
})


# Expected errors to fail gracefully
test_that("check_connection", {

  # broken link
  testthat::expect_message( check_connection(file_url = "banana") )

  # timeout connection
  testthat::expect_message( check_connection(file_url = 'http://example.com:81') )

})
