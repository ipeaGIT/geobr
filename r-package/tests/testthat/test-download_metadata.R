context("download_metadata")

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
