---
layout: splash
permalink: /contribute/
title: <span style="color:white">**Contribute to ISRaD**</span>
header:
  overlay_image: /assets/images/GradientSnip.jpg
---

Thank you for your interest in contributing data to ISRaD!
By contributing to ISRaD you are joining an international community of researchers and ensuring that your data has a lasting impact.

## Ways to Contribute

1. Add data (see below)
1. Contribute code and example scripts. Visit our [Github development page](https://github.com/International-Soil-Radiocarbon-Database/ISRaD)
1. [Post an issue](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/issues) to report problems or ideas for improvement

## Key Links

1. [ISRaD Template File](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/main/Rpkg/inst/extdata/ISRaD_Master_Template.xlsx)
1. [ISRaD Template Information File](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/main/Rpkg/inst/extdata/ISRaD_Template_Info.xlsx) and [ISRaD_extra Information File](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/main/Rpkg/inst/extdata/ISRaD_Extra_Info.xlsx)
1. [Frequenty Asked Questions (FAQ)](https://international-soil-radiocarbon-database.github.io/ISRaD/template_faq/)
1. [Online QAQC Tool]({{"https://soilradiocarbon.shinyapps.io/shinyapp/"}})
1. Contact: [info.israd@gmail.com]({{"mailto:info.israd@gmail.com"}})

## How to Add Data to ISRaD:

1. Check existing data
1. Read key information
1. Download and fill out ISRaD Template File
1. Test your data file using ISRaD online quality control tool
1. Submit to ISRaD

## 1. Explore existing data sources

Adding new data is great! We also welcome additions, improvements & corrections to existing datasets which are already included in ISRaD. Some in progress datasets could use your help too. Find the status of your dataset before you start:
* **Up-to-date list**: Check out the [latest list](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/blob/main/ISRaD_data_files/database/credits.md) of compiled studies in the development version of ISRaD
* **Complete entries**: View and download [individual complete template spreadsheets](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/tree/main/ISRaD_data_files)
* **In progress entries**: View and download [individual in-progress template spreadsheets](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/tree/main/ISRaD_data_files_in_progress)
* **Wishlist**: [List of studies](https://docs.google.com/spreadsheets/d/1lezUOJjYnB7KtXGDDFO_PKWLtx_7NZ3WaOubP2zUX-g/edit#gid=1009481555) you'd like to see added
* Currently working to add or update a template? Add your name to [this list](https://docs.google.com/spreadsheets/d/1lezUOJjYnB7KtXGDDFO_PKWLtx_7NZ3WaOubP2zUX-g/edit#gid=1750356077) to avoid duplicated efforts

## 2. Getting started and key information for entering or working with ISRaD

* **Template** – This is a structured spreadsheet for data entry. Download it [here](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/main/Rpkg/inst/extdata/ISRaD_Master_Template.xlsx).
* **Hierarchy** – The [ISRaD data structure](https://international-soil-radiocarbon-database.github.io/ISRaD/database/) is hierarchical. Each level of the hierarchy is represented by a tab in the template spreadsheet.
* **Original vs derived data** – ISRaD aggregates original data. In most cases, derived values and calculations are not stored within ISRaD
* **Required Fields** – These are indicated in red. Other fields are optional - enter those relevant to your dataset.
* **Controlled vocabulary** – We use this to standardize the data entry process. These are captured with dropdown menus, and are also listed on the “controlled vocabulary” tab.
* **Defining Site vs Profile (vs Plot)** – Use Site & Profile tabs to capture the spatial structure of your data. Samples collected in a similar location (within approx. 5km of each other) should be grouped under the same “Site” designation. More detailed sampling locations should be listed as “Profiles”. Each site must have a unique set of coordinates for the general location. Profiles can also have more specific coordinates (optional).
* **Depth Convention** – Zero is defined as the mineral-organic interface. Positive depths increase into the mineral soil. Organic horizons have negative depths. Please convert your data to follow this convention. If data must be reported from the soil surface, use the “lyr_all_org_neg” column to flag this.
* **Peatlands** – If depths are reported from the peat surface, use the “lyr_all_org_neg” column to flag this. Macrofossil data should be entered on the fraction tab. Use "lyr_basal" to indicate the bottom of the peat layer.
* **Control/Treatment** – Please designate if this data is from a manipulation experiment (e.g. fertilizer application, warming study, etc). Naturally burned areas and agricultural sites are considered “Control” unless additionally manipulated.
* **Coordinates** – Follow [this convention](https://en.wikipedia.org/wiki/File:Latitude_and_Longitude_of_the_Earth.svg). Don’t forget the negatives! Unsure? [Test your coordinates](https://www.google.com/maps/) to make sure they are not in the ocean.
* **Naming Convention & Unique Names** – You can choose any names for your sites, profiles, etc. Names can repeat, but each sequence of names “Site/Profile/Layer/etc” must be unique. (e.g. “HarvardForest/Profile1/AHorizon” and “HarvardForest/Profile2/AHorizon” are acceptable combinations, although “AHorizon” is a repeated layer name.)
* **Lots of other things** – Please review the "Contributing to the database" section of our [Frequenty Asked Questions (FAQ)](https://international-soil-radiocarbon-database.github.io/ISRaD/template_faq/) page.

## 3. Fill out ISRaD template

1. Fill out [ISRaD template file](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/main/Rpkg/inst/extdata/ISRaD_Master_Template.xlsx) with your data.
1. Consult the [ISRaD template information file](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/main/Rpkg/inst/extdata/ISRaD_Template_Info.xlsx) as you work, for column definitions, units, and controlled vocabulary.
1. Reminders & conventions:
   * Name your file: "author_year.xlsx"
   * Do not delete the top two description rows.
   * Follow requirements and controlled values/vocab in the ISRaD Template Information File.
1. Look at your file...
   * Do names match between tabs? (e.g. any "site_name" referenced is listed in "Site" tab)
   * Did you fill in required columns (red) and use controlled vocabulary?
   * If yes, you're ready to use the ISRaD online quality control tool.


## 4. Using ISRaD online quality control tool

1. [Open the online tool]({{"https://soilradiocarbon.shinyapps.io/shinyapp/"}})
1. Upload your file
1. Run check
1. If the upload and check was successful, a link to the ISRaD quality control report file will be generated for viewing and download.
1. Open the ISRaD quality control report
1. Make sure there are no WARNING messages.
1. If there are any WARNING messages, make necessary changes to ISRaD Data File, and repeat the quality control check steps above.
1. If there are any NOTES, take a look at them and make sure you are okay with them.
1. Once your ISRaD Data File passes the ISRaD quality control report with no WARNINGS, you can submit for ingestion to the ISRaD database.

*Please direct any questions, comments, or suggestions regarding the ISRaD online quality control tool to <a href="mailto:info.israd@gmail.com">info.israd@gmail.com</a>.*

## 5. Submitting your ISRaD Data File

Email to [info.israd@gmail.com]({{"mailto:info.israd@gmail.com"}}):
1. Your ISRaD Data File (Required)
1. ISRaD quality control report with no WARNINGS (Required)
1. If data is from previously published work, include publication link or pdf.
1. Your data will be manually reviewed by a volunteer expert. Feel free to include information and details, or comments and concerns, in your email that you think will be useful. Let us know if this is a new template, or if you have made updates to an existing template.
1. It is also very valuable for review process and addressing any future issues if you submit the original data tables (ie. supplemental table files from publication, or simply saying "We extracted data from Table 1, Table S3.") used to create ISRaD Data File when possible.
1. You will get an email once your submission has been accepted for inclusion in ISRaD. Nice work!

## Feedback? Questions?
We welcome and encourage your questions and/or suggestions.

If you have questions pertaining to template entry, please start by reviewing our [Frequenty Asked Questions (FAQ)](https://international-soil-radiocarbon-database.github.io/ISRaD/template_faq/) page.

If you can't find an answer to your question in the FAQ or you have a speicific suggestion for improvement or there is a problem you would like to report: please post an issue in our [Github issues](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/issues) page. No special permissions are required to post, although you do need to create a Github account if you don't have one already.

You can also email us at *[send us an email]({{"mailto:info.israd@gmail.com"}})* and we will do our best to get back to you.
