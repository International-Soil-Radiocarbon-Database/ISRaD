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
  * Author field of DESCRIPTION file updated
  * Examples added to functions where appropriate
  * dontrun calls in examples have been removed when unnecessary
  * donttest calls added to several examples with long run times
  * Non-exported functions w/ examples now exported
  * All calls to "cat()" replaced with "if(verbose) cat()" or "message()"
