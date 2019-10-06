context("Download")


test_that("download_fun", {


  expect_that( download_fun(0), equals(4108) )

    # # download
    # temp_sf <- geobr::download_fun()
    #
    # # test
    # expect_equal(ncol(temp_sf), 3)
})
