
test_that("ISRaD.report", {
  # Errors on bad database
  expect_error(ISRaD.report(1, "xxx"))

  # Errors on unknown report
  x <- database <- ISRaD::Gaudinski_2001
  expect_error(ISRaD.report(x, "xxx"), regexp = "Unknown report type")
})
