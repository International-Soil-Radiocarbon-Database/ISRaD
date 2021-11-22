[![Build Status](https://travis-ci.com/International-Soil-Radiocarbon-Database/ISRaD.svg?branch=master)](https://travis-ci.com/International-Soil-Radiocarbon-Database/ISRaD/)
[![cran
version](https://www.r-pkg.org/badges/version/ISRaD)](https://cran.r-project.org/package=ISRaD)

# ISRaD
This is the central repository for the development and release of ISRaD data and tools.

For more details about the ISRaD project please read our peer-reviewed open-access manuscript: [An open-source database for the synthesis of soil radiocarbon data: International Soil Radiocarbon Database (ISRaD) version 1.0](https://doi.org/10.5194/essd-12-61-2020). You can also get an overview of the project and find out how you can get involved from our website: [soilradiocarbon.org](www.soilradiocarbon.org).

You can download the most recent compiled version of ISRaD (the database) [here](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/blob/master/ISRaD_data_files/database/ISRaD_database_files.zip) (continually updated).

The [ISRaD R package](https://CRAN.R-project.org/package=ISRaD) is on [CRAN](https://cran.r-project.org/).

*To install the package, start up an R session and run the following code:*
```
install.packages("ISRaD")
library(ISRaD)
```

# Technical notes 
ISRaD data is stored here on github, rather than inside of the R package. You will always be able to access the latest data from (versions v1.0.0 or greater of) the ISRaD package using the "ISRaD.getdata" function. The version of ISRaD on CRAN is v1.7.8 (2021-01-04).

To cite the repository, use the [citation file](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/blob/master/CITATION.cff).

We are always working to improve the code and provide minor updates. If you're interested in using the latest (beta) version of the ISRaD R package you can download it directly from github. Open an R session and run the following code:

```
devtools::install_github("International-Soil-Radiocarbon-Database/ISRaD/Rpkg", ref="master")
```
