
test_that("ISRaD.rep.entry.stats", {
  # Errors with bad input
  expect_error(ISRaD.rep.entry.stats(1))
  
  # Should return a data.frame with one column per table, plus entry_name and doi
  database <- ISRaD::Gaudinski_2001
  x <- ISRaD.rep.entry.stats(database)
  expect_s3_class(x, "data.frame")
  expect_true("entry_name" %in% names(x))
  expect_true("doi" %in% names(x))
  expect_true(all(names(database) %in% names(x)))
})
