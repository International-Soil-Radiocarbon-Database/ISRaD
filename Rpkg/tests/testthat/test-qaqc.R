

test_that("qaqc", {
  
  # Handles bad input
  expect_error(qaqc(file = 1))
  expect_error(qaqc("1", outfile_QAQC = 1))
  expect_error(qaqc("1", summaryStats = 1))
  expect_error(qaqc("1", dataReport = 1))
  expect_error(qaqc("1", checkdoi = 1))
  expect_error(qaqc("1", verbose = 1))
})
