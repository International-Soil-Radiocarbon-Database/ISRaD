---
layout: splash
permalink: /database/
title: "ISRaD database"
header:
  overlay_image: /assets/images/soil.jpg
htmlwidgets: TRUE
--- 

## Data Structure

The ISRaD database is built from templates that each describe a single data set.  Because we want to include many kinds of radicoarbon data including fractionation schemes as well as components like interstitial gases and dissolved organics, the template has separate tabs for each kind of information.  Most contributors will not fill in everything, but the main database structure builds on information from the template.

<figure>
	<img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/structure_new.png" width = "500">
</figure>

The main features include:
* General information
	* **Metadata** information identifying the data source (including DOI) for proper attribution
	* **Site** provides location information (spatial coordinates)
* Information on how various properties (bulk density, C and N and their isotopes) are distributed with depth
	* **Profile**s are places sampled (usually by depth) within the general area of the site; they are not required (but of course encouraged!) to have separate spatial coordinates
	* **Surface fluxes** and **Interstitial** gases (CO<sub>2</sub> or methane) and dissolved organic matter can also be added
* **Layer** is where bulk information about each sampled depth in the soil profile is summarized. Other properties that can be found within each layer include:
	* **Fractions** of organic matter extracted by a range of methods
	* Amount and isotoptic signature of CO<sub>2</sub> produced during **Incubations** 

### Detailed database structure:
Overview of variables included in the database can be found [here](https://international-soil-radiocarbon-database.github.io/ISRaD/database_structure/).

## Current ISRaD Data
### List of datasets in ISRaD (development version):
* Complete list [here](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/blob/master/ISRaD_data_files/database/credits.md)


### In progress datasets:
* Visit [this google doc](https://docs.google.com/spreadsheets/d/1lezUOJjYnB7KtXGDDFO_PKWLtx_7NZ3WaOubP2zUX-g/edit?usp=sharing) to see the status of different datasets 

## Using ISRaD Data
There are various options to access the ISRaD database: 
*   The ISRaD R package provides the full database, and functions to work with the data
*   The full hierarchical database is available in a single compiled .xlsx template (below)
*   Flattened versions of subsets of the database are available as .csv files (below)

## Data Files 
The links below download the latest development version of the ISRaD database
### Hierarchical data:
*   [Download](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_list.xlsx)
 full hierarchical database compiled in a single .xlsx template 
### Flattened data:
*   [Download](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_data_flat_layer.csv) **Layer data** and associated information (Layer, Profile, Site, Metadata)
*   [Download](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_data_flat_flux.csv) **Flux data** and associated information as .csv (Flux, Profile, Site, Metadata)
*   [Download](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_data_flat_interstitial.csv) **Interstitial data** and associated information (Interstitial, Profile, Site, Metadata)
*   [Download](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_data_flat_fraction.csv) **Fraction data** and associated information (Fraction, Layer, Profile, Site, Metadata) 
*   [Download](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_data_flat_incubation.csv) **Incubation data** and associated information (Incubation, Layer, Profile, Site, Metadata)

### Hierarchical *"ISRaD_extra"* data:
*ISRaD_extra* is a filled data product, with additional columns and calculations added for the user.
*   [Download](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_extra_list.xlsx)
 full hierarchical database with additional columns compiled in a single .xlsx template
### Flattened *"ISRaD_extra"* data:
*   [Download](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_extra_flat_layer.csv) **Layer data** and associated information (Layer, Profile, Site, Metadata)
*   [Download](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_extra_flat_flux.csv) **Flux data** and associated information as .csv (Flux, Profile, Site, Metadata)
*   [Download](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_extra_flat_interstitial.csv) **Interstitial data** and associated information (Interstitial, Profile, Site, Metadata)
*   [Download](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_extra_flat_fraction.csv) **Fraction data** and associated information (Fraction, Layer, Profile, Site, Metadata) 
*   [Download](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_extra_flat_incubation.csv) **Incubation data** and associated information (Incubation, Layer, Profile, Site, Metadata)


## Database R Package download (raw R Package for advanced users)

Learn more [here](https://international-soil-radiocarbon-database.github.io/ISRaD/rpackage/)
