
test_that("lapply_df", {
  
  # Should return a data.frame
  expect_is(lapply_df(cars, length), "data.frame")
  
  # No factors
  x <- lapply_df(cars, function(x) paste(x, collapse = ""))
  expect_identical(class(x$speed), "character")
})


test_that("is_israd_database", {
  
  # Handles bad input
  expect_false(is_israd_database(NULL))
  
  # A list but not correct names
  x <- list()
  expect_false(is_israd_database(x))
  
  # A list with correct names but not data frame
  x <- list(metadata = data.frame(),
            site = data.frame(), 
            profile = data.frame(), 
            flux = data.frame(), 
            layer = 1,
            interstitial = data.frame(),
            fraction = data.frame(), 
            incubation = data.frame())
  expect_false(is_israd_database(x))
  
  # A good database
  x <- ISRaD::Gaudinski_2001
  expect_true(is_israd_database(x))
})
