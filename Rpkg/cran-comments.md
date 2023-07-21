## Test environments
* local OS: x86_64-apple-darwin15.6.0 (64-bit)
* Windows Server: x86_64-w64-mingw32 (64-bit)
* Fedora Linux, R-devel, clang, gfortran
* Ubuntu Linux 20.04.1 LTS, R-release, GCC

## R CMD check results
There were no ERRORs, or WARNINGs

There were 4 notes: 
1. "Maintainer: 'Jeffrey Beem-Miller <jbeem@bgc-jena.mpg.de>'

New submission

Package was archived on CRAN

Possibly misspelled words in DESCRIPTION:
  Biogeochemistry (13:52)
  ISRaD (12:6, 12:14, 14:42, 14:85, 15:66, 16:27)

CRAN repository db overrides:
  X-CRAN-Comment: Archived on 2023-04-02 as check issues were not
    corrected in time."
* The check issues have since been fixed, there are no spelling issues, package maintainer has not changed, version number has been updated

2. Found on Windows (Server 2022, R-devel 64-bit):

checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'

* R-hub issue #503 notes this is likely a bug in MiKTeX

3. Found on Windows (Server 2022, R-devel 64-bit):

checking for non-standard things in the check directory ... NOTE
Found the following files/directories:
  ''NULL''

* R-hub issue #560 notes this is specfic to R-hub

4. Found on Fedora Linux, R-devel, clang, gfortran and Ubuntu Linux 20.04.1 LTS, R-release, GCC

checking HTML version of manual ... NOTE
Skipping checking HTML validation: no command 'tidy' found

* See R-hub issue #560 for description of this recurring error

# Examples
Examples with CPU or elapsed time > 5s
                            user system elapsed
   ISRaD.getdata            1.941  0.849   9.204

* Other examples that consistently exceed 5s elapsed time are wrapped with \donttest

## Additional notes:
* R CMD check run with "run_dont_test" set to TRUE and passed with no issues
* fixed marked UTF-8 strings
* updated package version number since archived
