## Test environments
* local OS: mac 10.13.4; R v3.6.0
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* Ubuntu Linux 16.04 LTS, R-release, GCC
* Fedora Linux, R-devel, clang, gfortran

## R CMD check results
There were no ERRORs or WARNINGs.

There was 1 NOTE:

  Maintainer: 'Jeffrey Beem-Miller <jbeem@bgc-jena.mpg.de>'
  New submission

## r-hub builder
Building ISRaD with r-hub (using check_rhub() fails because gdal is not available on the r-hub build system. The rgdal package is a dependency of the raster package, which is a dependency of ISRaD. rgdal documentations explains in detail how to install gdal on all platforms, so this seems more an rgdal issue than an ISRaD issue.

* The following requested changes have been made since prior submission:
  * Function examples are now executable; donttest calls removed if runtime <5s
  * Toy datasets now included for running examples
  * Calls to write to local machine removed or changed to tempdir()
  * Description updated to describe package more clearly and include url
