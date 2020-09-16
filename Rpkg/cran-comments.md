## Test environments
* local OS: mac 10.13.4; R v3.6.0
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* Fedora Linux, R-devel, clang, gfortran
* Ubuntu Linux 16.04.6 LTS, R-release, GCC (Travis CI)

## Travis CI log
* Passes build
<https://travis-ci.com/International-Soil-Radiocarbon-Database/ISRaD>

## R CMD check results
There were no ERRORs or WARNINGs.

There were 2 NOTES:

  Maintainer: 'Jeffrey Beem-Miller <jbeem@bgc-jena.mpg.de>'
  New submission

  Possibly mis-spelled words in DESCRIPTION:
  Biogeochemistry (5:298)
  ISRaD (5:169, 5:177, 5:376, 5:419, 5:486, 5:533)
  * These are not misspelled

  checking examples ...
  Examples with CPU (user + system) or elapsed time > 5s
                     user system elapsed
  checkTemplateFiles 0.58   2.56    6.10
  ISRaD.getdata      1.07   0.36   13.75
  ** found \donttest examples: check also with --run-donttest
  * These examples do not always exceed 5s elapsed time.
  * The examples wrapped with \donttest always exceed 5s elapsed time (often substantially).

## r-hub builder
Building ISRaD with r-hub (using check_rhub() fails on Ubuntu because gdal is not available on the r-hub build system. The rgdal package is a dependency of the raster package, which is a dependency of ISRaD. rgdal documentations explains in detail how to install gdal on all platforms, so this seems more an rgdal issue than an ISRaD issue.

* The main motivation for this update was to remove the dependency on openxlsx, which was slated to be archived.
* There are a few new functions, a basic test framework, and improvements to code readability and efficiency (e.g. internal utility functions, code styled, etc.)

## Additional notes:
  * R CMD check run with "run_dont_test" set to TRUE and passed with no issues
