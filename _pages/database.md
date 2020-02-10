---
layout: splash
permalink: /database/
title: <span style="color:white">**ISRaD Database**
header:
  overlay_image: /assets/images/GoodPhotos/Soilprofiles.jpg
htmlwidgets: TRUE
---
## Accessing ISRaD Data
There are various options for accessing ISRaD data:
*   The compiled database or individual ISRaD datasets can be easily loaded into R following [this tutorial](/user_manual_Aug15_2019.html). For more information see the [R package](https://international-soil-radiocarbon-database.github.io/ISRaD/rpackage/) page of this website. 
*   ISRaD is also available in .xlsx workbook and .csv formats. Download a zip file [here](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_database_files.zip) (contents of the zip file are described in detail in the **Data Files** section below).

## Raw versus "Extra" data
There are two different versions of the compiled database:
*   **Raw data files** (with names begining in "ISRaD_data") contain only data ingested from the original source datasets.
*   **Expanded or "extra" data files** (with names begnining in "ISRaD_extra") include the original raw data as well as additional parameters that have either been calculated from existing data, or imported based on geospatial coordinates, e.g. geospatially referenced climate data. ISRaD_extra variables are listed and described in detail [here](https://raw.githubusercontent.com/International-Soil-Radiocarbon-Database/ISRaD/master/Rpkg/inst/extdata/ISRaD_Extra_Info.xlsx)

Descriptions of all ISRaD variables are available in the [ISRaD Template Information File](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/Rpkg/inst/extdata/ISRaD_Template_Info.xlsx) and [ISRaD_extra Information File](https://raw.githubusercontent.com/International-Soil-Radiocarbon-Database/ISRaD/master/Rpkg/inst/extdata/ISRaD_Extra_Info.xlsx)

## Data Files
The following files are included in the [ISRaD_database_files.zip](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/blob/master/ISRaD_data_files/database/ISRaD_database_files.zip) archive:
### Hierarchical data:
*	*ISRaD_data_vX_date.xlsx* - Full hierarchical database with additional columns compiled in a single .xlsx template.
*	*ISRaD_data_vX_date.rda* - Same but in R data format
### Flattened data:
*   *ISRaD_data_flat_layer_vX_date.csv* - Layer data and associated information (Layer, Profile, Site, Metadata)
*   *ISRaD_data_flat_flux_vX_date.csv* - Flux data and associated information as .csv (Flux, Profile, Site, Metadata)
*   *ISRaD_data_flat_interstitial_vX_date.csv* - Interstitial data and associated information (Interstitial, Profile, Site, Metadata)
*   *ISRaD_data_flat_fraction_vX_date.csv* - Fraction data and associated information (Fraction, Layer, Profile, Site, Metadata)
*   *ISRaD_data_flat_incubation_date.csv* - Incubation data and associated information (Incubation, Layer, Profile, Site, Metadata)

### Hierarchical *"ISRaD_extra"* data:
*	*ISRaD_extra_vX_date.xlsx* - ISRaD_extra is a filled data product, with additional columns and calculations added for the user. Full hierarchical database with additional columns compiled in a single .xlsx template.
*	*ISRaD_extra_vX_date.rda* - Same but in R data format

### Flattened *"ISRaD_extra"* data:

*   *ISRaD_extra_flat_layer_vX_date.csv* - Layer data and associated information (Layer, Profile, Site, Metadata)
*   *ISRaD_extra_flat_flux_vX_date.csv* - Flux data and associated information as .csv (Flux, Profile, Site, Metadata)
*   *ISRaD_extra_flat_interstitial_vX_date.csv* - Interstitial data and associated information (Interstitial, Profile, Site, Metadata)
*   *ISRaD_extra_flat_fraction_vX_date.csv* - Fraction data and associated information (Fraction, Layer, Profile, Site, Metadata)
*   *ISRaD_extra_flat_incubation_date.csv* - Incubation data and associated information (Incubation, Layer, Profile, Site, Metadata)

## Versioning
The names of the data files reflect the current version and modification date in the format **(data name)(vX)(date).(format)**, where **data name** tells what data this is (ie. ISRaD_extra_flat_layer), **vX** refers to the official ISRaD version number (e.g. "v1.2.3"), **date** gives the date when the data were compiled, and **format** is the file type.

## Data Structure

The ISRaD database is compiled from individual template files, each of which describes a single data set (i.e. linked to a DOI). In ISRaD we strive to incorporate radicoarbon data collected at many different spatial and temporal scales: from laboratory fractionations to gaseous fluxes and dissolved organics observed in the field. Accordingly, the ISRaD database is structured as a list of hierarchically linked tables designed for recording these different kinds of data.


<figure>
	<img src="/assets/images/structure_new.png" width = "500">
</figure>

ISRaD data tables (in descending hierarchical order):
* General information
	* **Metadata** information identifies the source of the data (DOI, citation)
	* **Site** data provides location information (spatial coordinates)
	* **Profile**s are places sampled within the general area of the site (e.g. soil profiles, flux chambers, etc.). If available, more fine scale spatial coordinates should be reported. General data on vegetation, soil taxonomy, and local climate (mean annual temperature and precipitation) are reported at the profile level.
* Data associated with an individual *Profile*
	* **Flux** and **Interstitial** measurements, e.g. CO<sub>2</sub>, methane, dissolved organic matter, etc.
	* **Layer** C, N, bulk density, etc. data from *individual depth layers* of a soil profile. 
* Data associated with a specific *layer* can be reported the following tables:
	* **Fractions** of soil as defined by physical, chemical, or biological methods
	* Amount and isotoptic signature of CO<sub>2</sub> or methane produced during laboratory **Incubations**

### Detailed database structure:
Overview of variables included in the database can be found [here](https://international-soil-radiocarbon-database.github.io/ISRaD/database_structure/).

## Current ISRaD Data
### List of datasets in ISRaD (development version):
* Complete list [here](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/blob/master/ISRaD_data_files/database/credits.md)

### In progress datasets:
* Visit [this google doc](https://docs.google.com/spreadsheets/d/1lezUOJjYnB7KtXGDDFO_PKWLtx_7NZ3WaOubP2zUX-g/edit?usp=sharing) to see the status of different datasets


Photo credit to Dr. Asmeret Berhe.
