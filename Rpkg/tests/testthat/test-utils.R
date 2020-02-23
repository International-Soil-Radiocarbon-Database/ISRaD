
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


test_that("check_template_info_columns", {
  # Handles bad input
  expect_error(check_template_info_columns(1, list(), ""))
  expect_error(check_template_info_columns(list(), 1, ""))
  expect_error(check_template_info_columns(list(), list(), 1))
  
  # Identical columns
  template <- list(x = data.frame(a = 1, b = 2), y = data.frame(c = 3, d = 4))
  template_info <- list(x = data.frame(Column_Name = c("a", "b"), stringsAsFactors = FALSE),
                        y = data.frame(Column_Name = c("c", "d"), stringsAsFactors = FALSE))
  capture.output({
    expect_output(mismatch <- check_template_info_columns(template, template_info, ""))
    expect_false(mismatch)
    expect_silent(check_template_info_columns(template, template_info, "", verbose = FALSE))
  })
  
  # Columns in template but not info file
  template_info <- list(x = data.frame(Column_Name = c("a"), stringsAsFactors = FALSE),
                        y = data.frame(Column_Name = c("c", "d"), stringsAsFactors = FALSE))
  capture.output({
    expect_warning(mismatch <- check_template_info_columns(template, template_info, ""))
  })
  expect_true(mismatch)
  
  # Columns in info but not template file
  template <- list(x = data.frame(a = 1), y = data.frame(c = 3))
  capture.output({
    expect_warning(mismatch <- check_template_info_columns(template, template_info, ""))
  })
  expect_true(mismatch)
})

test_that("check_numeric_minmax", {
  # Handles bad input
  expect_error(check_numeric_minmax(1, 1))
  
  expect_silent(check_numeric_minmax(1, "1"))
  expect_silent(check_numeric_minmax("1", "1"))
  expect_warning(check_numeric_minmax("a", "1"))
  expect_warning(check_numeric_minmax(c("1", "a", "3"), "1"))
})
