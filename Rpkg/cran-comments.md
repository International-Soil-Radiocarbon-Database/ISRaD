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

  Found the following (possibly) invalid URLs:
  URL: https://soilradiocarbon.org/
    From: DESCRIPTION
    Status: Error
    Message: libcurl error code 35:
      	OpenSSL SSL_connect: SSL_ERROR_SYSCALL in connection to soilradiocarbon.org:443
  * The annual url fee needs to be paid for 2020 and will be within the next week

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

* The following requested changes have been made since prior submission:
  * Function examples are now executable; donttest calls removed if runtime <5s
  * Toy datasets now included for running examples
  * Calls to write to local machine removed or changed to tempdir()
  * Description updated to describe package more clearly and include url
  * pdf manual updated

## Additional notes:
  * R CMD check run with "run_dont_test" set to TRUE and passed with no issues
