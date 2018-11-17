---
layout: splash
permalink: /database/
title: "ISRaD database"
header:
  overlay_image: /assets/images/soil.jpg
htmlwidgets: TRUE
--- 

## User manuals
### [Old user manual (out of date)](/user_manual.html)

## Data Structure

The ISRaD database is built from templates that each describe a single data set.  Because we want to include many kinds of radicoarbon data including fractionation schemes as well as components like interstitial gases and dissolved organics, the template has separate tabs for each kind of information.  Most contributors will not fill in everything, but the main database structure builds on information from the template.

<figure>
	<img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/structure_new.png" width = "500">
</figure>

The main features include:
* General information
	* **Metadata** information identifying the data source (including doi) for proper attribution
	* **Site** provide location information (spatial coordinates)
* Information on how various properties (bulk density, C and N and their isotopes) are distributed with depth
	* **Profile**s are places sampled (usually by depth) within the general area of the site; they are not required (but of course encouraged!) to have separate spatial coordinates
	* **Surface fluxes** and **Interstitial** gases (CO2 or methane) and dissolved organic matter can also be added
* **Layer** is where bulk information about each sampled depth in the soil profile is summarized
	* Other properties that can be found within each layer influde
	* **Fractions** of organic matter extracted by a range of methods
	* Amount and isotoptic signature of CO2 produced during **Incubations** 
	
## Credits (up to date list of datasets currently in ISRaD on github)
[Credits](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/credits.md)


## In progress
Visit this google doc to see the status of different datasets. 
[List](https://docs.google.com/spreadsheets/d/1lezUOJjYnB7KtXGDDFO_PKWLtx_7NZ3WaOubP2zUX-g/edit?usp=sharing)

## Database download (raw database)

v0.2.0
Database objects 
[excel](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_Data/database/ISRaD_list.xlsx)


## Database R Package download (raw R Package for advanced users)

Current R-Package release
[Entire ISRaD R Package v0.2.0](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/archive/v0.2.0.zip)

Previous releases
[Entire ISRaD R Package v0.1.0](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/archive/v0.1.0.zip)
[ISRaD v0.0.1](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/archive/v0.0.1.zip)

