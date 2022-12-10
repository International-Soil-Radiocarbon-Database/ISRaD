---
layout: splash
permalink: /database/
title: <span style="color:white">**ISRaD Database**</span>
header:
  overlay_image: /assets/images/GoodPhotos/Soilprofiles.jpg
htmlwidgets: TRUE
---
## Accessing ISRaD Data
*   Using R, the compiled database or individual ISRaD datasets can be downloaded (in .xlsx, .csv, and .rda format) and easily loaded into an R session following [this tutorial](/user_manual_Aug15_2019.html). For more information see the [R package](https://international-soil-radiocarbon-database.github.io/ISRaD/rpackage/) page of this website.
*   For non-R users, ISRaD data is available in .xlsx and .csv formats. Download [here](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/main/ISRaD_data_files/database/ISRaD_database_files.zip) (contents of the zip archive are described in detail in the **Data Files** section below).

## Terms of Use and Citing ISRaD
Anyone may share or adapt the ISRaD dataset, provided they do so in accordance with the [Creative Commons Attribution 4.0 International Public License](https://creativecommons.org/licenses/by/4.0/legalcode), also referred to as CC BY. In addition, we strongly encourage ISRaD users to follow two simple guidelines for use:

1. **Cite Publication and Version:** When utilizing the resources provided by ISRaD, including the complete dataset, individually curated entries, or value-added calculations included in the R-package, users should cite the source publication ([Lawrence, et al. 2020](https://earth-syst-sci-data.net/12/61/2020/)) and reference the version of ISRaD data that was used for their work (e.g. ISRaD_data_v1.2.3.2020-01-30). Additionally, if users leverage individual data entries from the database, they should also cite the original source dataset and/or paper.

2. **Contribute data:** When users interpret their own data in the context of data accessed from ISRaD, they should submit those new data for inclusion in ISRaD after they have published their results and/or obtained a DOI for their dataset. New entries should be submitted to: info.israd@gmail.com

## Raw versus "Extra" data
There are two different versions of the compiled database:
*   **Raw data files** (with names beginning in "ISRaD_data") contain only data ingested from the original source datasets.
*   **Expanded or "extra" data files** (with names begnining in "ISRaD_extra") include the original raw data as well as additional variables that have either been calculated from existing data or imported based on geospatial coordinates, such as geospatially referenced land cover, climate, and soil data.

Descriptions of all ISRaD variables are available in the [ISRaD Template Information](https://soilradiocarbon.org/database_structure/) and [ISRaD_extra Information](https://soilradiocarbon.org/extra_structure/) files.

## Data Files
The following files are included in the [ISRaD_database_files.zip](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/blob/main/ISRaD_data_files/database/ISRaD_database_files.zip) archive
### Hierarchical data:
*	*ISRaD_data_vX.date.xlsx* - Full hierarchical database compiled in a single .xlsx workbook
*	*ISRaD_data_vX.date.rda* - Same but in (binary) R data format
### Flattened data:
*   *ISRaD_data_flat_layer_vX.date.csv* - Layer data and associated information (Layer, Profile, Site, Metadata)
*   *ISRaD_data_flat_flux_vX.date.csv* - Flux data and associated information (Flux, Profile, Site, Metadata)
*   *ISRaD_data_flat_interstitial_vX.date.csv* - Interstitial data and associated information (Interstitial, Profile, Site, Metadata)
*   *ISRaD_data_flat_fraction_vX.date.csv* - Fraction data and associated information (Fraction, Layer, Profile, Site, Metadata)
*   *ISRaD_data_flat_incubation_vX.date.csv* - Incubation data and associated information (Incubation, Layer, Profile, Site, Metadata)

### Hierarchical *"ISRaD_extra"* data:
*	*ISRaD_extra_vX.date.xlsx* - Same as *ISRaD_data_vX.date.xlsx*, but with additional calculated/filled data fields
*	*ISRaD_extra_vX.date.rda* - Same but in (binary) R data format

### Flattened *"ISRaD_extra"* data:

*   *ISRaD_extra_flat_layer_vX.date.csv* - Layer data and associated information (Layer, Profile, Site, Metadata)
*   *ISRaD_extra_flat_flux_vX.date.csv* - Flux data and associated information (Flux, Profile, Site, Metadata)
*   *ISRaD_extra_flat_interstitial_vX.date.csv* - Interstitial data and associated information (Interstitial, Profile, Site, Metadata)
*   *ISRaD_extra_flat_fraction_vX.date.csv* - Fraction data and associated information (Fraction, Layer, Profile, Site, Metadata)
*   *ISRaD_extra_flat_incubation_vX.date.csv* - Incubation data and associated information (Incubation, Layer, Profile, Site, Metadata)

### Readme file:

*	*readme.txt* - Metadata and information about zip archive contents.

## Versioning
The names of the data files reflect the version of ISRaD used and the date on which the database was compiled. Names are constructed in the format **(data name)_(vX).(date).(format)**, where **data name** tells what data this is (ie. ISRaD_extra_flat_layer), **vX** refers to the official ISRaD version number (e.g. "v1.2.3"), **date** gives the date when the data were compiled (yyyy-mm-dd), and **format** is the file type.

## Data Structure

The ISRaD database is compiled from individual template files, each of which describes a single data set (i.e. linked to a DOI).

In ISRaD we strive to incorporate radicoarbon data collected at many different spatial and temporal scales: from laboratory fractionations to gaseous fluxes and dissolved organics observed in the field. The ISRaD database is structured accordingly as a list of hierarchically-linked tables designed for recording these different kinds of data.

![ISRaDdataStructure]({{"/assets/images/structure_new.png"}})

ISRaD data tables (in descending hierarchical order):
* General information
	* **Metadata** identify the source of the data (DOI, citation)
	* **Site** data provide location information (spatial coordinates)
	* **Profile**s are places sampled within the general area of the site (e.g. soil profiles, flux chambers, etc.). Finer scale spatial coordinates should be reported if available. Report general data on vegetation, soil taxonomy, and local climate (mean annual temperature and precipitation) at the profile level.
* Data associated with an individual **Profile**
	* **Flux** and **Interstitial** measurements, e.g. CO<sub>2</sub>, methane, dissolved organic matter, etc.
	* **Layer** %C, %N, bulk density, etc. data from *individual depth layers* of a soil **profile**.
* Data associated with a specific **layer** are reported in the following tables:
	* **Fractions** of soil as defined by physical, chemical, or biological methods
	* Amount and isotoptic signature of CO<sub>2</sub> or methane produced during laboratory **Incubations**

### Detailed database structure:
An overview of variables included in ISRaD can be found [here](https://international-soil-radiocarbon-database.github.io/ISRaD/database_structure/).

## Current ISRaD Data
### List of datasets in ISRaD:
* Complete list [here](https://soilradiocarbon.org/credits/)

### In progress datasets:
* Visit [this google doc](https://docs.google.com/spreadsheets/d/1lezUOJjYnB7KtXGDDFO_PKWLtx_7NZ3WaOubP2zUX-g/edit?usp=sharing) to see the status of different datasets


Photo credit to Dr. Asmeret Asefaw Berhe.
