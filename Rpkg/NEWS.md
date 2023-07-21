# Updated release for CRAN, mid July 2023
ISRaD 2.5.3

## Notes
* Updated code to use sf package instead of sp
* Updated code to use rnaturalearth in lieu of rworldmap
* Updated code to use terra in lieu of raster
* fixed marked UTF-8 strings
* fixed errors from use of 'order' on data frames
* added monthly resolved soil moisture data to ISRaD_extra
* replaced PET data with v3 of Global Aridity Index and PET database, and added aridity index from same source (Zomer et al., 2022, https://doi.org/10.1038/s41597-022-01493-1)
* Updated ISRaD_Extra_Info.xlsx
* Added updated atmospheric 14C record from Hua et al. (2021): 'Hua_2021'. This dataset is now referenced for calculating atmospheric 14C, delta-delta 14C values, and for normalizing 14C data from samples collected after 1940. The older dataset from Graven et al. (2017) is still in the package, as the data from 1850-1940 are used for spinning up the model in the function 'ISRaD.extra.norm14c_year', but the data object has been renamed 'Graven_2017' (formerly 'graven').  

# Updated release for CRAN, early February 2023
ISRaD 2.4.7

## Notes
* deprecated functions "ISRaD.extra.fill_fm" and "ISRaD.extra.fill_14c" have been removed; function "ISRaD.extra.fill_rc" replaces them
* function "ISRaD.extra.fill_deltadelta" has been split into two functions: "ISRaD.extra.calc_atm14c" and "ISRaD.extra.fill_deltadelta"
* new functions "ISRaD.extra.norm14c_year" returns 14c normalized to user-specified year and optionally returns 1 pool model fits
* new function "ISRaD.extra.fill_cn" fills missing CN ratios
* new function "ISRaD.extra.fill_country" fills country (and optionally continent) from profile coords
* function documentation updated

# Updated release with fraction data overhaul, early February 2022
ISRaD 2.0.0

## Notes
* backwards incompatible changes to master template file implemented in ISRaD v2.0.0

# Updated release for CRAN, early January 2021
ISRaD 1.7.8

## Notes
* "ISRaD.extra.geospatial" function now fills climate data from WorldClim v2, specifically 30" resolution, data averaged over the period 1970 to 2000, and fills soil moisture data from TerraClim, at 1/24 of a degree resolution (ca. 4 km), data averaged over the period 1981 to 2010
* WorldClim v1 data is no longer served in ISRaD_extra nor returned from the ISRaD.extra functions
* "convert_fm_d14c" function had an error in the unicode message that is now fixed

# New package version for CRAN, mid September 2020
ISRaD 1.5.6

## Notes
* "ISRaD.save.xlsx" deprecated as openxlsx was unstable
* "ISRaD.save.entry" introduced to replace "ISRaD.save.xlsx". New function does not retain formatting of template file
* All calls to openxlsx functions replaced with either readxl or writexl functions
* "ISRaD.read.entry" introduced to simplify reading in a single excel file in ISRaD format
* "convert_fm_d14c" is a new helper function for converting fraction modern to delta 14C and vice-versa
* Internal utility functions introduced to make code cleaner and more readable
* Basic test framework introduced for more robust performance

# Updated release for CRAN, late January 2020
ISRaD 1.2.3

# Updated release for CRAN, mid November 2019
ISRaD 1.1.2

# Updated release for CRAN, mid September 2019
ISRaD 1.0.0

# Updated release September 2019
ISRaD 0.1.4

# Updated release August 2019
ISRaD 0.1.3

# Initial release November 16, 2018
ISRaD 0.1.0
