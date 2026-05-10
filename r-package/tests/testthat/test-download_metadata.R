context("download_metadata2")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


test_that("download_metadata2", {

  metadata <- download_metadata2()
  testthat::expect_true(is(metadata, "data.frame"))
  testthat::expect_equal(ncol(metadata), 4)

  testthat::expect_true(is( download_metadata2() , "data.frame"))


})


# Expected errors
test_that("download_metadata2", {

    testthat::expect_error( download_metadata2("asdasd") )
  testthat::expect_error( download_metadata2( NULL)  )

})
