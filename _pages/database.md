---
layout: splash
title: <span style="color:rgb(105,89,205)">**ISRaD Database**
header:
  overlay_image: assets/images/ISRaD_logos/ISRaD_USGS_MPI6.png
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

## Accessing ISRaD Data
There are various options to access the ISRaD database: 
*   The ISRaD datasets can be easily loaded into R following [this tutorial](/user_manual_Aug15_2019.html) 
*   The full hierarchical database is available in a single compiled .xlsx template
*   Flattened versions of subsets of the database are available as .csv files

## Raw versus Expanded data
There are two different file types for accessing the ISRaD dataset: 
*   **Raw data files** (with names begining in "ISRaD_data") contain only data ingested from the original source datasets.   
*   **Expanded or "extra" data files** (with names begnining in "ISRaD_extra") include the original raw data as well as additional parameters that have either been calculated or imported based on site coordinates, such as geospatially referenced climate information. A current list and descritption of the ISRaD_extra variables is available [here](https://raw.githubusercontent.com/International-Soil-Radiocarbon-Database/ISRaD/master/Rpkg/inst/extdata/ISRaD_Extra_Info.xlsx)

# [Download](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_database_files.zip)
 
This link downloads the latest development version of the ISRaD database. It contains the data files listed below. Descriptions of all variables are available in the [ISRaD Template Information File](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/Rpkg/inst/extdata/ISRaD_Template_Info.xlsx) and [ISRaD_extra Information File](https://raw.githubusercontent.com/International-Soil-Radiocarbon-Database/ISRaD/master/Rpkg/inst/extdata/ISRaD_Extra_Info.xlsx)

## Data Files 
### Hierarchical data:
*	**ISRaD_data_vX_date.xlsx** - Full hierarchical database with additional columns compiled in a single .xlsx template.  
*	**ISRaD_data_vX_date.rda** - Same but in R data format 
### Flattened data:
*   **ISRaD_data_flat_layer_vX_date.csv** - Layer data and associated information (Layer, Profile, Site, Metadata)
*   **ISRaD_data_flat_flux_vX_date.csv** - Flux data and associated information as .csv (Flux, Profile, Site, Metadata)
*   **ISRaD_data_flat_interstitial_vX_date.csv** - Interstitial data and associated information (Interstitial, Profile, Site, Metadata)
*   **ISRaD_data_flat_fraction_vX_date.csv** - Fraction data and associated information (Fraction, Layer, Profile, Site, Metadata) 
*   **ISRaD_data_flat_incubation_date.csv** - Incubation data and associated information (Incubation, Layer, Profile, Site, Metadata)

### Hierarchical *"ISRaD_extra"* data:
*	**ISRaD_extra_vX_date.xlsx** - ISRaD_extra is a filled data product, with additional columns and calculations added for the user. Full hierarchical database with additional columns compiled in a single .xlsx template.  
*	**ISRaD_extra_vX_date.rda** - Same but in R data format
 
### Flattened *"ISRaD_extra"* data:

*   **ISRaD_extra_flat_layer_vX_date.csv** - Layer data and associated information (Layer, Profile, Site, Metadata)
*   **ISRaD_extra_flat_flux_vX_date.csv** - Flux data and associated information as .csv (Flux, Profile, Site, Metadata)
*   **ISRaD_extra_flat_interstitial_vX_date.csv** - Interstitial data and associated information (Interstitial, Profile, Site, Metadata)
*   **ISRaD_extra_flat_fraction_vX_date.csv** - Fraction data and associated information (Fraction, Layer, Profile, Site, Metadata) 
*   **ISRaD_extra_flat_incubation_date.csv** - Incubation data and associated information (Incubation, Layer, Profile, Site, Metadata)

## Versioning
The names of the data files reflect the current version with the following format **(data name)(vX)(date).(format)**, where **data name** tells what data this is (ie. ISRaD_extra_flat_layer), **vX** refers to the latest official version number (X), **date** tells the date of the most recently updated development version, and **format** is the file type.


## Database R Package download (raw R Package for advanced users)

Learn more [here](https://international-soil-radiocarbon-database.github.io/ISRaD/rpackage/)
