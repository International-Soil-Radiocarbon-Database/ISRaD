[![Build Status](https://travis-ci.com/International-Soil-Radiocarbon-Database/ISRaD.svg?branch=master)](https://travis-ci.com/International-Soil-Radiocarbon-Database/ISRaD/)
[![cran
version](https://www.r-pkg.org/badges/version/ISRaD)](https://cran.r-project.org/package=ISRaD)

# ISRaD
This is the central repository for the development and release of ISRaD data and tools.

Download compiled version of ISRaD (the database) [here](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/blob/master/ISRaD_data_files/database/ISRaD_database_files.zip).

The [ISRaD R package](https://CRAN.R-project.org/package=ISRaD) is on [CRAN](https://cran.r-project.org/).

*To install the package, start up an R session and run the following code:*
```
install.packages("ISRaD")
library(ISRaD)
```

*For more information, and to find out how to get involved, visit our website: [soilradiocarbon.org](www.soilradiocarbon.org)*

# Technical notes 
ISRaD data is stored here on github, rather than inside of the R package, so you will always be able to access the latest data from (versions v1.0.0 or greater of) the ISRaD package. The version on CRAN is v1.2.3.

We are always working to improve the code and provide minor updates. So, if you're interested in using the latest (beta) version of the ISRaD R package, you can download it directly from github. Open an R session and run the following code:

```
devtools::install_github("International-Soil-Radiocarbon-Database/ISRaD/Rpkg", ref="master")
```
