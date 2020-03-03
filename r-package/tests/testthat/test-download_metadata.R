context("download_metadata")


test_that("download_metadata", {

  metadata <- download_metadata(geography = 'amazonia_legal')
  testthat::expect_true(is(metadata, "data.frame"))
  testthat::expect_equal(ncol(metadata), 5)

})





# Expected errors
test_that("download_metadata", {

  testthat::expect_error( download_metadata( )  )
  testthat::expect_error( download_metadata(data_type="asdasd") )
  testthat::expect_error( download_metadata(geography = "aaa")  )

})
