## Test environments
* local OS: mac 10.13.4; R v3.6.0
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* Ubuntu Linux 16.04 LTS, R-release, GCC
* Fedora Linux, R-devel, clang, gfortran

## R CMD check results
There were no WARNINGs.

There was 1 ERROR when installing on the Fedora Linux, R-devel, clang, gfortran
platform:

  4207#> ------------------------- ANTICONF ERROR ---------------------------
  4208#> Configuration failed because openssl was not found. Try installing:
  4209#> * deb: libssl-dev (Debian, Ubuntu, etc)
  4210#> * rpm: openssl-devel (Fedora, CentOS, RHEL)
  4211#> * csw: libssl_dev (Solaris)
  4212#> * brew: openssl@1.1 (Mac OSX)
  4213#> If openssl is already installed, check that 'pkg-config' is in your
  4214#> PATH and PKG_CONFIG_PATH contains a openssl.pc file. If pkg-config
  4215#> is unavailable you can set INCLUDE_DIR and LIB_DIR manually via:
  4216#> R CMD INSTALL --configure-vars='INCLUDE_DIR=... LIB_DIR=...'

* I'm not sure how to fix this from my machine. I have an openssl.pc file that
  I use with Python, but I don't know how to incorporate this into the package,
  as it is in a different directory from my R package library.

There was 1 NOTE:

  Maintainer: 'Jeffrey Beem-Miller <jbeem@bgc-jena.mpg.de>'
  New submission
