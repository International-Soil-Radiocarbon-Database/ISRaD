## Test environments
* local OS: x86_64-apple-darwin15.6.0 (64-bit)
* Windows Server: x86_64-w64-mingw32 (64-bit)

## R CMD check results
There were no ERRORs, or WARNINGs

There was 1 note: "Maintainer: 'Jeffrey Beem-Miller <jbeem@bgc-jena.mpg.de>'

New submission

Package was archived on CRAN

Possibly misspelled words in DESCRIPTION:
  Biogeochemistry (13:52)
  ISRaD (12:6, 12:14, 14:42, 14:85, 15:66, 16:27)

CRAN repository db overrides:
  X-CRAN-Comment: Archived on 2023-04-02 as check issues were not
    corrected in time."
* The check issues have since been fixed, there are no spelling issues, package maintainer has not changed

# Examples
  Examples with CPU or elapsed time > 5s
                            user system elapsed
   ISRaD.getdata            1.941  0.849   9.204

  * Other examples that consistently exceed 5s elapsed time are wrapped with \donttest

## Additional notes:
  * R CMD check run with "run_dont_test" set to TRUE and passed with no issues
  * fixed marked UTF-8 strings
