
test_that("ISRaD.flatten", {
  
  # Handles bad input
  expect_error(ISRaD.flatten(1, "xxx"))
  expect_error(ISRaD.flatten(list(), 1))
  
  # Errors on unknown table
  database <- ISRaD::Gaudinski_2001
  expect_error(ISRaD.flatten(database, "xxx"), regexp = "Unknown table type")
})
