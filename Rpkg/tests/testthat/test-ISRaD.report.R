
test_that("ISRaD.report", {
  # Errors on unknown report
  expect_error(ISRaD.report(1, "xxx"), regexp = "Unknown report type")  
})
