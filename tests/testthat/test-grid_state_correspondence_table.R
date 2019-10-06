context("Data")


test_that("grid_state_correspondence_table", {

  # load data
#  load( system.file("data/grid_state_correspondence_table.RData", package="geobr") )

  data(grid_state_correspondence_table)
  head(grid_state_correspondence_table)
  # test
  expect_equal(ncol(grid_state_correspondence_table), 3)
  expect_equal(nrow(grid_state_correspondence_table), 139)

})




