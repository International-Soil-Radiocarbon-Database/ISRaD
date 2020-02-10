---
layout: splash
permalink: /rpackage/
title: <span style="color:white">**ISRaD R Package**
header:
  overlay_image: /assets/images/soil.jpg
---


## R Package
The ISRaD R package (version 1.2.3) is on CRAN and new users can install the package from inside an R session using the normal method (i.e. "install.packages("ISRaD)". Alternatively, for those users willing to risk working with beta code, you can install the development version of ISRaD from github ("install_github('International-Soil-Radiocarbon-Database/ISRaD/Rpkg')").

The R package provides useful tools for data manipulation, QA/QC, and making simple queries and reports. From R, the latest ISRaD data can be retrieved from the ISRaD github repository using the function "ISRaD.getdata". This will download the latest compiled version of the database to a user-specified directory. All data will be tagged with the R package number and the date when the data were compiled. Note that since the data reside on github, you will be able to retrieve and work with the latest data from any version of the ISRaD R package.

*(For non-R users, the compiled raw data can also be downloaded as a .zip file directly from github).* 

The ISRaD R package also provides a number of tools ("ISRaD.extra" functions) for calculating or filling in certain fields with missing data, as well as providing ancillary data from various geospatial data sources. When downloading data you can choose to download an additional version of the compiled database that already has these data filled and added, i.e. "ISRad_extra":

```
ISRaD.getdata(directory = "~", dataset = "full, extra = "TRUE", force_download = "TRUE")
```

For more information, please read the [user manual](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD.pdf).

## R package installation, data download and user manual:
### [Tutorial here](/user_manual_Aug15_2019.html)

### [Have a Request?](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/issues/170)
Want to see how to do something in R with the ISRaD data? The request lines are open! Make a post here describing what you'd like.
