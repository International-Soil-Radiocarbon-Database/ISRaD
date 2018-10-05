# ISRaD Quickstart Guide

This guide will get you up and running with the basic functionality of ISRaD. It will explain several methods for obtaining and working with the ISRaD data, and describe how to seamlessly fold your own data into the existing database framework. Detailed descriptions of all software functions and data elements may be found in the ISRaD User Guide.

## What is ISRaD?

In order to use ISRaD, it is important to understand what the database consists of:

ISRaD begins with a collection of data extracted from a large number of published studies and unpublished contributions. Extracted data are standardized to a common template and stored as a Microsoft Excel spreadsheet (.xlsx), with one spreadsheet file per publication/contribution.

ISRaD also consists of software--written in the R programming language--that checks Excel spreadsheets for consistency, collates them into the full database as an object in the R language, and outputs the R object into a single large Excel spreadsheet or comma-separated values (.csv) file.

Thus, each versioned release of ISRaD comprises the individual data template files, the collated data file(s), and the software that created the latter from the former. These elements are hosted in a repository on [github.com](https://github.com/International-Soil-Radiocarbon-Database/ISRaD).

## Ways of working with ISRaD

Depending on your goals, there are multuple ways of obtaining and working with software and data from ISRaD. However, there are two questions that can determine your needs:

* Will I use only the existing data in ISRaD, or do I want to add additional data?

* Do I want to work with the data in R, or in some other language or program?

### Scenario 1: use existing data outside of R

In this case, you don't need to clone the entire github repository. You can simply download the compiled Excel spreadsheet or comma-separated file from the github repository web interface in ISRaD/ISRaD_Data/database/. You can open these files in the program of your choice. Note that the comma-separated file has been flattened across the ISRaD data hierarchy, so the file size can be quite large, compared to the Excel spreadsheet that lists different levels of the hierarchy separately.

### Scenario 2: use existing data within R

In this case, you still do not need to clone the repository using git. Instead, you can pull the R objects directly from github within R ising the following:

```
library(devtools)
install_github("International-Soil-Radiocarbon-Database/ISRaD")
```


### Scenario 3: add new data existing data within R

### Scenario 4: add new data outside of R
