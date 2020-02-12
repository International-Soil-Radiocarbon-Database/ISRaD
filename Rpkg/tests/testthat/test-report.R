context("ISRaD.report.R")

test_that("ISRaD.report works", {
  
  # Should error on unknown report
  expect_error(ISRaD.report(report = "xxxxx"))
})
