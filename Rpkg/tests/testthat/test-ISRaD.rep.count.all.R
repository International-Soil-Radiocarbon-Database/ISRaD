
test_that("ISRaD.rep.count.all", {
  # Errors with bad input
  expect_error(ISRaD.rep.count.all(1))

  # Should return a data.frame with one column per table
  database <- ISRaD::Gaudinski_2001
  x <- ISRaD.rep.count.all(database)
  expect_s3_class(x, "data.frame")
  expect_identical(length(database), ncol(x))
})
