
test_that("compile", {
  # Handles bad inputs
  expect_error(compile(dataset_directory = "xxx"))
  expect_error(compile(tempdir(), write_report = 1))
  expect_error(compile(tempdir(), write_out = 1))
  expect_error(compile(tempdir(), return_type = 1))
  expect_error(compile(tempdir(), checkdoi = 1))
  expect_error(compile(tempdir(), verbose = 1))

  # Run example
  database <- ISRaD::Gaudinski_2001
  td <- tempdir()
  outfile <- file.path(td, "Gaudinski_2001.xlsx")
  ISRaD.save.xlsx(
    database = database,
    template_file = system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD"),
    outfile = outfile
  )
  expect_true(file.exists(outfile))

  ISRaD.compiled <- compile(td,
    write_report = TRUE, write_out = TRUE,
    return_type = "list", checkdoi = FALSE, verbose = FALSE
  )
  expect_true(is_israd_database(ISRaD.compiled))
})
