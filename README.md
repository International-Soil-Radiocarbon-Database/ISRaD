[![Build Status](https://travis-ci.com/International-Soil-Radiocarbon-Database/ISRaD.svg?branch=master)](https://travis-ci.com/International-Soil-Radiocarbon-Database/ISRaD/)

# ISRaD
Repository for the development and release of ISRaD data and tools

Download compiled version of ISRaD [here](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/blob/master/ISRaD_data_files/database/ISRaD_database_files.zip)

Install the [ISRaD R package](https://CRAN.R-project.org/package=ISRaD) from [CRAN](https://cran.r-project.org/)
From R:
```
install.packages("ISRaD")
library(ISRaD)
```

*For more information: [soilradiocarbon.org](www.soilradiocarbon.org)*

# The ISRaD R package is now on CRAN! 
Note that as ISRaD data is stored here on github, rather than inside of the R package, you will always be able to access the latest data from versions v1.0.0 or greater of the ISRaD package. The version on CRAN is v1.2.3.

We are always working to improve the code and provide minor updates. So, if you're interested in using the latest (beta) version of ISRaD, you can download it directly from github. Open an R session and run the following code:

```
devtools::install_github("International-Soil-Radiocarbon-Database/ISRaD/Rpkg", ref="master")
```
