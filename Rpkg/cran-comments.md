## Test environments
* local OS: mac 10.13.4; R v3.6.0
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* Ubuntu Linux 16.04.6 LTS, R-release, GCC (Travis CI)

# Note that rhub builder did not seem to be running the checks on Ubuntu or Fedora

## Travis CI log
* Passes build
<https://travis-ci.com/International-Soil-Radiocarbon-Database/ISRaD>

## R CMD check results
There were no ERRORs or WARNINGs.

There were 2 NOTES:

checking for future file timestamps ... NOTE
  unable to verify current time
* this seems to be a known devtools issue that will hopefully be resolved soon

checking top-level files ... NOTE
  Non-standard file/directory found at top level:
    ‘cran-comments.md’
* this is to provide info to CRAN about the build

# Examples
  Examples with CPU or elapsed time > 5s
                            user system elapsed
   ISRaD.extra            12.808  1.657  45.209
   ISRaD.extra.geospatial  5.040  0.056   5.102
   ISRaD.getdata           1.851  0.269   5.909

  * The examples that exceed 5s elapsed time are wrapped with \donttest

## Additional notes:
  * R CMD check run with "run_dont_test" set to TRUE and passed with no issues
