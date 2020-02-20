
test_that("ISRaD.extra.fill_coords", {
  # Errors with bad input
  expect_error(ISRaD.extra.fill_coords(1))
  expect_error(ISRaD.extra.fill_coords(list(site = 1,
                                            profile = data.frame())))
  expect_error(ISRaD.extra.fill_coords(list(site = data.frame(),
                                            profile = 1)))
  
  # Create test data structure
  x <- list(metadata = data.frame(),
            site = data.frame(site_name = "a",
                              site_lat = 2,
                              site_long = 3),
            profile = data.frame(site_name = "a",
                                 pro_lat = NA,
                                 pro_long = 1),
            flux = data.frame(),
            layer = data.frame(),
            interstitial = data.frame(),
            fraction = data.frame(),
            incubation = data.frame()
  )
  
  # Fills based on NA lat
  y <- ISRaD.extra.fill_coords(x)
  expect_identical(y$profile$pro_lat, y$site$site_lat)
  expect_identical(y$profile$pro_long, y$site$site_long)
  
  # Fills based on NA long
  x$profile$pro_lat <- 1
  x$profile$pro_long <- NA
  y <- ISRaD.extra.fill_coords(x)
  expect_identical(y$profile$pro_long, y$site$site_long)
  
  # If site missing, NA is used
  x$profile <- data.frame(site_name = "a",
                          pro_lat = NA,
                          pro_long = 1)
  x$site <- data.frame(site_name = "b",
                       site_lat = 2,
                       site_long = 3)
  y <- ISRaD.extra.fill_coords(x)
  expect_true(is.na(y$profile$pro_lat))
  expect_true(is.na(y$profile$pro_long))
})
