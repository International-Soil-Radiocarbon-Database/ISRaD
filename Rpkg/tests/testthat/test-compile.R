
test_that("compile", {
  # Handles bad inputs
  expect_error(compile(dataset_directory = "xxx"))
  expect_error(compile(tempdir(), write_report = 1))
  expect_error(compile(tempdir(), write_out = 1))
  expect_error(compile(tempdir(), return_type = 1))
  expect_error(compile(tempdir(), checkdoi = 1))
  expect_error(compile(tempdir(), verbose = 1))
})
