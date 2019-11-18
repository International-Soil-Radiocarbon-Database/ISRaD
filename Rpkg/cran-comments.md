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

* The following requested changes have been made since prior submission:
  * Function examples are now executable; donttest calls removed
  * Toy datasets now included in package for running examples
  * Calls to write to local machine removed or changed to tempdir()
  * Description updated to describe package more clearly and include url
