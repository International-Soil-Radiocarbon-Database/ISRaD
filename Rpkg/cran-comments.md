## Test environments
* local OS: mac 10.13.4; R v3.6.0
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* Ubuntu Linux 16.04.6 LTS, R-release, GCC (Travis CI)

## Travis CI log
* Passes build
<https://travis-ci.com/International-Soil-Radiocarbon-Database/ISRaD>

## R CMD check results
There were no ERRORs, WARNINGs, or NOTEs.

# Examples
  Examples with CPU or elapsed time > 5s
                            user system elapsed
   ISRaD.getdata           1.849  0.267   7.416

  * The examples that consistently exceed 5s elapsed time are wrapped with \donttest

## Additional notes:
  * R CMD check run with "run_dont_test" set to TRUE and passed with no issues
  * I received an email about a parsing issue noted on 12-Dec-2020 which I have since fixed
