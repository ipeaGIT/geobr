context("Download")

test_that("download_metadata", {


  metadata <- download_metadata()

  testthat::expect_true(is(metadata, "data.frame"))

  testthat::expect_equal(ncol(metadata), 5)

  # expect_true(file.exists(tempf))

})




test_that("download_metadata", {

  testthat::expect_error( download_metadata(data_type="asdasd") )

 # testthat::expect_error( download_metadata()  )


})
