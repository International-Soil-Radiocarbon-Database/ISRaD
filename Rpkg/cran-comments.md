## Test environments
* local OS: x86_64-apple-darwin15.6.0 (64-bit)
* Windows Server: x86_64-w64-mingw32 (64-bit)

## R CMD check results
There were no ERRORs, WARNINGs

# NOTES:
1) CRAN incoming feasibility:
  Found three (possibly) invalid URLs (Status without verification: OK)
2) Non-standard file/directory found at top level:
  ‘cran-comments.md’
3) Examples with CPU or elapsed time > 5s
  1 example (see below)

# Examples
  Examples with CPU or elapsed time > 5s
                            user system elapsed
   ISRaD.getdata            1.941  0.849   9.204

  * Other examples that consistently exceed 5s elapsed time are wrapped with \donttest

## Additional notes:
  * R CMD check run with "run_dont_test" set to TRUE and passed with no issues
