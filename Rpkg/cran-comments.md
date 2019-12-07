## Test environments
* local OS: mac 10.13.4; R v3.6.0
* Windows Server x86_64-w64-mingw32 (64-bit), R release
* Ubuntu Linux 16.04.6 LTS, R-release, GCC (Travis CI)

## Travis CI log
* Passes build
<https://travis-ci.com/International-Soil-Radiocarbon-Database/ISRaD>

## R CMD check results
There were no ERRORs or WARNINGs.

There was 1 NOTE:

  Maintainer: 'Jeffrey Beem-Miller <jbeem@bgc-jena.mpg.de>'
  New submission

  Possibly mis-spelled words in DESCRIPTION:
  Biogeochemistry (5:298)
  ISRaD (5:169, 5:177, 5:376, 5:419, 5:486, 5:533)
  * These are not misspelled

## r-hub builder
Building ISRaD with r-hub (using check_rhub() fails because gdal is not available on the r-hub build system. The rgdal package is a dependency of the raster package, which is a dependency of ISRaD. rgdal documentations explains in detail how to install gdal on all platforms, so this seems more an rgdal issue than an ISRaD issue.

* The following requested changes have been made since prior submission:
  * Function examples are now executable; donttest calls removed if runtime <5s
  * Toy datasets now included for running examples
  * Calls to write to local machine removed or changed to tempdir()
  * Description updated to describe package more clearly and include url
  * pdf manual updated

## Additional notes:
  * R CMD check run with "run_dont_test" set to TRUE and passed with no issues
