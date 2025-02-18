---
layout: splash
permalink: /template_faq/
title: <span style="color:white">**Template FAQ**
header:
  overlay_image: /assets/images/GradientSnip.jpg
---


Is your question related to using the database or contributing to it? Select by clicking.

<details><summary>
<b> Using the database </b>
</summary><p>

* **_What are all the variables included in the database?_** <br>
The complete list of variables in the database can be found [here](https://international-soil-radiocarbon-database.github.io/ISRaD/database_structure/).
  </p>
</details>

<details><summary>
<b> Contributing to the database </b>
</summary><p>



Filling out a template can be confusing! This page provides detailed information and examples for each tab of the template. Please click to see full details.

### General FAQ

<details><summary>
<b> Metadata </b>
</summary><p>

* **_The source study does not have a DOI, what should I do?_** <br>
If the data are unpublished but you expect them to be published in the future (thus obtaining DOI), you can submit the template without DOI and then later submit a correction of the template with DOI. If you take this approach please fill in “israd” into the **_doi_** field in metadata tab. Also note that data from this entry will not be compiled in the R-package data objects until a DOI is added.
</p></details>

<details><summary>
<b> Soil Order </b>
</summary><p>

 * How do I convert WRB soil classification to USDA, to obtain a USDA soil order? <br>
 FAO, USDA and other soil classification systems are not readily interchangeable, so this can be tricky. These tables can help:
(1) [FAO_USDA.pdf](https://www.researchgate.net/profile/Csaba_Csuzdi/post/How_to_convert_FAO_soil_class_into_USDA_soil_class/attachment/59d62fd079197b807798df0e/AS%3A359920387018752%401462823115202/download/FAO_USDA.pdf).  (2) [soil system conversion.pdf](https://www.researchgate.net/profile/Csaba_Csuzdi/post/How_to_convert_FAO_soil_class_into_USDA_soil_class/attachment/59d62fd079197b807798df10/AS%3A359920387018756%401462823115460/download/soil+system+conversion.pdf).
The issue is also discussed [here](https://www.researchgate.net/post/How_to_convert_FAO_soil_class_into_USDA_soil_class).
Finally, if you feel uncomfortable with this conversion, mention this in the email submitting your template, and an expert reviewer can double check this field for you.
(https://www.researchgate.net/post/How_to_convert_FAO_soil_class_into_USDA_soil_class)
</p></details>


<details><summary>
<b> Organic Matter Content </b>
</summary><p>

 * **_The paper reports organic matter content instead of organic carbon %, what should I do?_** <br>
 Convert to organic carbon using OC=OM/1.724 and mention this in the **_lyr_note_** or other relevant field.
</p></details>

<details><summary>
<b> Extracting Data or Coordinates from Figures </b>
</summary><p>

 * **_Is it ok to digitize data/coordinates from a figure/map?_**<br>
Yes, this may be done with various softwares or on-line tools, such as [WebPlotDigitizer](https://automeris.io/WebPlotDigitizer/).
However, it is important to note this in the template (see below). While the raw data from the author or supplementary information is preferable, digitized data is also welcome in ISRaD.

 * **_Should I mention somewhere in the template that the data (e.g., GPS coordinates and others) were obtained from figures?_**<br>
 Yes, use the **_metadata_note_** field. Say for example “GPS coordinates and variables x,y and z were extracted from figures”.

 * **_Is there any rule on how many decimal places are reasonable to enter when data are digitized from a plot?_** <br>
No, use your best guess about the appropriate number of decimal places based on expected precision of plot digitization and/or data acquisition.
</p></details>

<details><summary>
<b> Depth Conventions </b>
</summary><p>

 * **_Where is zero with regard to the ISRaD depth convention?_** <br>
 Zero is defined as the mineral-organic interface. Positive depths increase into the mineral soil. Organic horizons have negative depths. Please convert your data to follow this convention. If data must be reported from the soil surface, use the **_lyr_all_org_neg_** column to flag this.

 * **_What is the "lyr_all_org_neg" column for?_** <br>
 This column is used to flag studies where depths are reported from the soil surface, if the depth of the mineral-organic interface is unknown. For example, this is frequently the case in peatlands.

 * **_The study does not report the bottom of the layer for the deepest layer. What should I do?_**<br>
 Write "Inf" as infinity in the **_lyr_bot_** field.

 * **_What do I do if there are some analyses for a composite of multiple layer samples (different depth interval) and some data for each of the layers? E.g. some analyses were made on each of layers 0-5 and 5-10 cm and some other were made on a composite 0-10 cm?_**<br>
In this case, you should create a new "composite" layer with a depth range of 0 to 10 cm. Additionally, it is critical that you denote this layer as a composite by marking "y" in the **_lyr_composite_** field.
</p></details>

<details><summary>
<b> Radiocarbon Data </b>
</summary><p>

 * **_What radiocarbon units are accepted?_** <br>
   ISRaD accepts fraction modern and  Δ<sup>14</sup>C radiocarbon units. Only fill in the data reported in the paper. Unit conversions perfomed separately and included in *ISRaD_extra* data object, which is part of the ISRaD [R-package].

 * **_This paper only reports radiocarbon ages in years. What do I do?_** <br>
   If the data is reported as a *calibrated date*, it cannot be included in ISRaD. *Uncalibrated* radiocarbon ages can be converted to fraction modern values (see below).

 * **_How do I convert radiocarbon age (in years BP) into Fraction modern (F<sub>m</sub>) units?_**<br>
   > age = -8033 * ln (F<sub>m</sub>)

   Some additional information on radiocarbon units and calculations is available [here](http://www.whoi.edu/nosams/radiocarbon-data-calculations).
* **_How do I convert standard deviation in radiocarbon age (in years BP) into standard deviation in Fraction modern?_**<br>
  Use the following formula (Stenström et al., 2011):
  > error_F<sub>m</sub> = F<sub>m</sub> * error<sub>age</sub> / 8033,

where F<sub>m</sub> is fraction modern.
 * **_Paper reports radiocarbon age and δ<sup>14</sup>C, what should I fill into the template?_**<br>
   Convert radiocarbon age to Fraction modern using:
   > age = -8033 * ln (F<sub>m</sub>)

   and ignore δ<sup>14</sup>C values. Be sure to mark down the year of observation which is important for the conversion of Fm to Δ<sup>14</sup>C.
 * **_Paper reports only δ<sup>14</sup>C and δ<sup>13</sup>C, what should I fill into the template?_**<br>
  Calculate Δ<sup>14</sup>C using the following formula:
  > Δ<sup>14</sup>C = δ<sup>14</sup>C - (2*δ<sup>13</sup>C +50)(1 + δ<sup>14</sup>C / 1000)

 * **_The radiocarbon age is stated as  “Modern” but no other data is provided. What do I do?_**<br>
  Leave the field blank and add a note that data is available but has to be mined for. Do *not* enter a fraction modern value of 1! This is misleading during data analysis!

 * **_What is the difference between the Radiocarbon Analysis Year (e.g., column “lyr_rc_year”) and Observation Year (e.g., column “lyr_obs_date_y“)?_**<br>
    As explained in the [Template Information File](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/main/inst/extdata/ISRaD_Template_Info.xlsx), the Observation Date refers to the date at which the soil sample was collected whereas the Radiocarbon Analysis Year refers to the year at which the sample was actually analyzed for radiocarbon.

* **_What is the difference between the Δ<sup>14</sup>C Sigma (e.g., column „lyr_14c_sigma” suffix) and Δ<sup>14</sup>C SD (e.g., column „lyr_14c_sd”)?_**<br>
    As explained in the [Template Information File](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/main/inst/extdata/ISRaD_Template_Info.xlsx), lyr_14c_sigma is the standard deviation reported by the AMS facility as analytical error estimate. This is the most common case and applicable where the author has reported individual measurements. In cases where only the mean values are reported, the lyr_14c_sd field should be used. This is the sample standard deviation calculated from multiple (replicated) measurements. When possible please report individual measurements.

</p></details>

<details><summary>
<b> Vegetation and Land Cover </b>
</summary><p>

 * **_Why are there so many columns related to land cover and vegetation?_**
   In order to accommodate a range of classification schemes, we consider multiple categories of land cover and vegetation information. The combination of one or more categories (described below) along with the latitude allows the end user to classify profiles into more general or more specific categories. In addition, we encourage you to include as much detail as possible about land cover and vegetation in the Profile Vegetation Notes column.
 * **_What is Land Cover Type?_**
   This is the general land cover category; the options are bare, cultivated, forest, rangeland/grassland, shrubland, urban, wetland, and tundra. In some cases, this may be the only vegetation column that you will be able to fill in. This column is optional, and may be left blank if the land cover type is truly unknown, but users are asked to make sure this column is filled in.
 * **_What is Forest or Shrubland Phenology?_**
   Forest and shrubland vegetation types may or may not lose their leaves on an annual cycle. If trees or shrubs retain their leaves all year, either because the local climate allows year-round growth, or because trees are adapted to never lose leaves (e.g., most conifers), then they should be categorized as evergreen. Trees or shrubs that lose leaves annually should be categorized as deciduous. If a forest contains an equal amount of both types, it may be categorized as mixed. This column should be left blank for land cover types other than forest and shrubland, or if the phenology is truly unknown.
 * **_What is Forest Leaf Morphology?_**
   Forests may be caregorized as broadleaf, needleleaf, or mixed. Note that this is independent of phenology. This column should be left blank for land cover types other than forest, or if the leaf type is truly unknown.
 * **_What is Photosynthetic Pathway?_**
   This is the metabolic pathway employed by the local vegetation for photosynthesis. This is mainly applicable to grasses, which may use either the C3 or C4 pathway, and we expect this column will be left blank for all other land cover types. We also include the CAM pathway, in the unlikely event that a profile is best characterized with this type of vegetation. This column should be left blank if the photosynthetic pathway is unknown.
 * **_What should I put in the Profile Vegetation Notes?_**
   Please include as much detailed information as you are able about the local land cover conditions and vegetation. For example, species names, spatial distribution, and evidence of disturbance, could all prove valuable in future analyses, and we encourage you to provide as much detail as possible.
 * **_What if the land cover and vegetation information is the same for all of the profiles at a single site?_**
   Please copy/paste or use Excel's "fill handle" to enter the information into each of the profiles. Because each profile CAN have it's own vegetation characteristics, we want to have this information at the profile level, even if it's just the same thing over and over for each profile at the site.




</p></details>

<details><summary>
<b> Additional Data </b>
</summary><p>


 * **_The paper contains some auxiliary data (e.g. species composition, mineralogy etc.) that I don´t know how to enter or don't have time to do enter. What should I do?_** <br>
   Mention this in the **_metadata_note_** field so that one day someone can come back to this. If you are interested in learning how to enter it, post a question on the [Github issues page](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/issues) or contact *info.israd@gmail.com*.


</p></details>

<details><summary>
<b> Missing Data </b>
</summary><p>

 * **_The authors don't report the coordinates. What should I do?_** <br>
    You can digitize the coordinates from the figure, or find the site location on Google maps or similar. Please use the **_metadata_note_** field to indicate this (e.g. “Cordinates were extracted from figures” or "Coordinates were estimated from site descriptions").
 * **_What should I do if the date of observation was not reported in the paper?_** <br>
   If paper has radiocarbon data but does not report the observation year, estimate it by subtracting 3 years from the year of publication and note in the **_lyr_note_** field or other relevant note field. (e.g.  “observation date estimated from year of publication”)

 * **_Do I have to fill in all the columns in the template?_**<br>
   No, only some columns are required. The required columns are indicated in the [Template Information File](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/main/inst/extdata/ISRaD_Template_Info.xlsx) (by “yes” in the “Required” column) and also using red font in the template. Although we encourage you to fill out as many fields as possible, it is perfectly ok if many columns are left empty and some columns are only partly filled in. Please leave the fields with missing data empty (i.e., do not fill in zeros or NAs).

* **_Can I delete or hide columns in the template (e.g., because I do not plan to fill them in and they are distracting me) or change order of columns in the template?_**<br>
  Yes, deleting non-required columns (i.e., those not indicated in red) or changing order of any of the columns is fine and will not cause the template to fail QAQC.



</p>
</details>


### Incubations

<details>
<summary>

<i>
  Helpful info here
</i>

</summary>
<p>
1. Templates
2. Templates
3. Templates
</p>
</details>

### Fractions

<details><summary>
<b> Density Separation </b>
</summary><p>

 * **_What is a density separation?_**
 A physical fractionation scheme where heavy liquid is used to float off organics, thereby separating them from mineral material. This can be done with or without disruption of aggregates by sonicating or shaking.

<img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/Misc_Diagrams/density_separation_diagram.png" width="375">

Example template: [Swanston_2005](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/main/ISRaD_data_files/Swanston_2005.xlsx)
</p></details>

<details><summary>
<b> Sequential Density Separation </b>
</summary><p>

 * **_What is a sequential density separation?_**
A heavy liquid is used to float off the "light-fraction" organics, thereby separating them from mineral material. The remaining mineral material is then further partitioned into series of fractions isolated by incrementally increasing the density of the heavy liquid used for the separation.

<img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/Misc_Diagrams/sequential_density_separation_diagram.png" width="700">

Example template: [Sollins_2009](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/main/ISRaD_data_files/Sollins_2009.xlsx)
</p></details>

<details><summary>
<b> Particle Size Separation </b>
</summary><p>

* **_What is particle size separation?_**
A physcial fractionation method where wet- or dry-sieving is used to separate soils into common particle size classes: sand, silt, clay.

<img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/Misc_Diagrams/particle_size_separation_diagram.png" width="450">

 Example template: [Desjardines_1994](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/main/ISRaD_data_files/Dejardins_1994.xlsx)
</p></details>

<details><summary>
<b> Aggregate fractionation </b>
</summary><p>

 * **_What is aggregate fractionation?_**
A fractionation procedure where wet sieving is used to separate aggregates by size and/or strength. Silt+clay sized fractions may be additionally isolated.

<img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/Misc_Diagrams/aggregate_fractionation_diagram.png" width="550">

 Example template: [Monreal_1997](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/main/ISRaD_data_files/Monreal_1997.xlsx)

</p></details>

<details><summary>
<b> Dummy Fractions </b>
</summary><p>

 * **_What are dummy fractions and when are they needed_**
 "Dummy fractions" are placeholder rows in the fraction tab. There are two reasons that dummy fractions might be required: (1) To represent a mass of material generated from a fractionation procedure but that is unaccounted for in measurements or the reporting of data. In other words, we want to be able to sum our mass of material back to 100% of the bulk value. Sometimes a fraction of the sample mass is calculated by difference rather than measured directly. In that case, we should create a dummy fraction to account for that mass, which was not physcially isolated. (2) To allow for reconstruction of a complex fractionation procedure that cannot be reconstructed without the use of a dummy layer. Not sure if you need to create a dummy fraction? Check out these examples:

 **(a) All mass accounted for.**
 Here, all the fractions in level 2 are unique and add up to level 1 – no dummy fraction needed.

 <img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/Misc_Diagrams/dummy_fractions_a.png" width="650">


 **(b) Well-known schemes.**
 Here, all the fractions in level 2 and 3 are unique and add up to level 1. If the “Golchin” density fractionation were not common knowledge, you’d probably want a dummy fraction, but we don’t need one because the 3 fraction density separation is simple and all the end users should have knowledge of it.

 <img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/Misc_Diagrams/dummy_fractions_b.png" width="500">

**(c) Intermediate-fractions.**
Here, the silt and clay fraction from level 3 needs to be distinguished from the silt and clay fraction from level 2 in a way that lets the end user know what each fraction was derived from. No measurements were made on the 53-250 um aggregate fraction (red circle) prior to further fractionation, so we need a dummy fraction to represent what the level 3 fractions came from.

 <img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/Misc_Diagrams/dummy_fractions_c.png" width="500">
</p></details>


### Fluxes

<details><summary>
<i> Helpful info here </i>
</summary><p>

1. Templates
2. Templates
3. Templates

</p>
</details>

### Interstitial

<details><summary>

<i>
  Helpful info here
</i>

</summary>
<p>
1. Templates
2. Templates
3. Templates
</p>
</details>


### Special Cases
<details><summary>
<b> Updating templates that have been autofilled from past compilations </b>
</summary><p>

 * **_What are autofilled templates and why should I care?_**
Some of the entries in ISRaD were automatically generated during a batch ingestion of data from previous data compilations. For example, a large number of entries were ingested from the data synthesized for the He et al., 2016 publication, which itself utilized synthesized data from Mathieu et al. 2015. The ISRaD data ingestion process automatically partitions data contained in these compilations into separate files based on the original source. This allows users to more easily access these descrete datasets in order to add additional data, that may have been excluded during the preceeding synthesis efforts, and to double check that data was entered correctly. We encourage users that are familiar with the origial source material (e.g.,  you are an author of the study) to download these entries and confirm that the original data has been correctly entered. If you find errors or missing data, you can make changes and submit the updated files to _info.israd@gmail.com_.

 * **_Why do these templates look different?_**
   These templates were automatically generated, and do not have the header formatting. You can copy-paste the values to the master template to continue working. This will also give you access to the drop down menus for controlled vocabulary.
 * **_The original data source  does not mention bulk density, but the automatically generated template includes bulk density values. Should I keep them in the template?_**
 No. During past synthesis efforts, some bulk density values were estimated based on organic matter content. During our ingestion process, we may not have caught all of the estimated values. The philosphy of ISRaD is to only include orignial data in the templates.
 * **_The names in the template don't match the paper. What do I do?_**
  In many cases, site, profile and layer names were automatically generated. Please feel free to update them to match those found in the paper.
 * **_The paper has additional fraction, flux, or incubation data, not reported in the current template. What should I do with it?_**
   If you have time, please add it! Otherwise, please make a note of the availability of additional datasets within the paper in the **_metadata_note_** field.
</p>
</details>
 </details>

<br>

If you have a question that is not answered here, please feel free to reach out to us! The best way is to post your question or comment on the [GitHub issues page](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/issues). For this you need to [create an account on GitHub](https://github.com/join?source=experiment-header-dropdowns-home) if you don't have one but it is easy (and free). You can also send us an e-mail to israd@gmail.com or contact us on [Twitter](https://twitter.com/soilradiocarbon).
