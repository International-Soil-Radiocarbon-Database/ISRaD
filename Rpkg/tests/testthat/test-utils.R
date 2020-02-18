
test_that("lapply_df", {
 
  # Should return a data.frame
  expect_is(lapply_df(cars, length), "data.frame")
  
  # No factors
  x <- lapply_df(cars, function(x) paste(x, collapse = ""))
  expect_identical(class(x$speed), "character")
})
