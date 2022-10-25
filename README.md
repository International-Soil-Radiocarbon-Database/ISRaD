[![Build Status](https://travis-ci.com/International-Soil-Radiocarbon-Database/ISRaD.svg?branch=main)](https://travis-ci.com/International-Soil-Radiocarbon-Database/ISRaD/)
[![cran
version](https://www.r-pkg.org/badges/version/ISRaD)](https://cran.r-project.org/package=ISRaD)

# ISRaD
This is the central repository for the development and release of ISRaD data and tools. For more information about the ISRaD project please read our peer-reviewed open-access manuscript: 

["An open-source database for the synthesis of soil radiocarbon data: International Soil Radiocarbon Database (ISRaD) version 1.0"](https://doi.org/10.5194/essd-12-61-2020) 

You can also visit our website ([soilradiocarbon.org](www.soilradiocarbon.org)) for an overview of the project and to find out how you can get involved.

## ISRaD data
The most recent compiled version of ISRaD (the database) is available [here](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/blob/main/ISRaD_data_files/database/ISRaD_database_files.zip).

## ISRaD R package
The [ISRaD R package](https://CRAN.R-project.org/package=ISRaD) is on [CRAN](https://cran.r-project.org/).

*To install the package, start up an R session and run the following code:*
```
install.packages("ISRaD")
library(ISRaD)
```

# Technical notes 
ISRaD data is stored here on github, rather than inside of the R package. You will always be able to access the latest data from (versions v1.0.0 or greater of) the ISRaD package using the "ISRaD.getdata" function. The version of ISRaD on CRAN is v1.7.8 (2021-01-04).

We are always working to improve the code and provide minor updates. If you're interested in using the latest (beta) version of the ISRaD R package you can download it directly from github. Open an R session and run the following code:

```
devtools::install_github("International-Soil-Radiocarbon-Database/ISRaD/Rpkg", ref="main")
```

## Citations
To cite the database, please cite our [original manuscript](https://doi.org/10.5194/essd-12-61-2020) as well as the respository (click the "cite this repository" link above to view or download the citation for the most recent data release in your preferred format).
