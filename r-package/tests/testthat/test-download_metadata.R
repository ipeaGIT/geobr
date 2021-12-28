context("download_metadata")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


test_that("download_metadata", {

  metadata <- download_metadata()
  testthat::expect_true(is(metadata, "data.frame"))
  testthat::expect_equal(ncol(metadata), 5)

  testthat::expect_true(is( download_metadata() , "data.frame"))


})


# Expected errors
test_that("download_metadata", {

    testthat::expect_error( download_metadata("asdasd") )
  testthat::expect_error( download_metadata( NULL)  )

})
