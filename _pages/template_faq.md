---
layout: splash
permalink: /template_faq/
title: "Template FAQ"
header:
  overlay_image: /assets/images/soil.jpg
---

Filling out a template can be confusing! This page provides detailed information and examples for each tab of the template. Please click to see full details.

### General FAQ

<details><summary>  
<b> Metadata </b>
</summary><p>
  
* **_The source study does not have a DOI, what should I do?_** 
If the data are unpublished but you expect them to be published in the future (thus obtaining DOI), you can submit the template without DOI and then later submit a correction of the template with DOI. If you take this approach please fill in “israd” into the **_doi_** field in metadata tab. Also note that data from this entry will not be compiled in the R-package data objects until a DOI is added.
</p></details>

<details><summary>  
<b> Soil Order </b>
</summary><p>

 * **_How do I convert WRB soil classification to USDA, to obtain a USDA soil order?_** 
 FAO, USDA and other soil classification systems are not readily interchangeable, so this can be tricky. These tables can help:
(1) [FAO_USDA.pdf](https://www.researchgate.net/profile/Csaba_Csuzdi/post/How_to_convert_FAO_soil_class_into_USDA_soil_class/attachment/59d62fd079197b807798df0e/AS%3A359920387018752%401462823115202/download/FAO_USDA.pdf).  (2) [soil system conversion.pdf](https://www.researchgate.net/profile/Csaba_Csuzdi/post/How_to_convert_FAO_soil_class_into_USDA_soil_class/attachment/59d62fd079197b807798df10/AS%3A359920387018756%401462823115460/download/soil+system+conversion.pdf). 
The issue is also discussed [here](https://www.researchgate.net/post/How_to_convert_FAO_soil_class_into_USDA_soil_class).
Finally, if you feel uncomfortable with this conversion, mention this in the email submitting your template, and an expert reviewer can double check this field for you.
(https://www.researchgate.net/post/How_to_convert_FAO_soil_class_into_USDA_soil_class)
</p></details>


<details><summary>  
<b> Organic Matter Content </b>
</summary><p>

 * **_The paper reports organic matter content instead of organic carbon %, what should I do?_** 
 Convert to organic carbon using OC=OM/1.724 and mention this in the **_lyr_note_** or other relevant field.
</p></details>

<details><summary>  
<b> Data or Coordinates from Figures </b>
</summary><p>

 * **_Is it ok to digitize data/coordinates from a figure/map?_** 
Yes, but please make a note of it (see below). While the raw data from the author or supplementary information is preferable, digitized data is also welcome in ISRaD.
 * **_Should I mention somewhere in the template that the data (e.g., GPS coordinates and others) were obtained from figures?_**
 Yes, use the **_metadata_note_** field. Say for example “GPS coordinates and variables x,y and z were extracted from figures”.
 * **_Is there any rule on how many decimal places are reasonable to enter when data are digitized from a plot?_** 
No, use your best guess about the appropriate number of decimal places based on expected precision of plot digitization and/or data acquisition.
</p></details>

<details><summary>  
<b> Depth Conventions </b>
</summary><p>

 * **_Where is zero with regard to the ISRaD depth convention?_** 
 Zero is defined as the mineral-organic interface. Positive depths increase into the mineral soil. Organic horizons have negative depths. Please convert your data to follow this convention. If data must be reported from the soil surface, use the **_lyr_all_org_neg_** column to flag this. 
 * **_What is the "lyr_all_org_neg" column for?_** 
 This column is used to flag studies where depths are reported from the soil surface, if the depth of the mineral-organic interface is unknown. For example, this is frequently the case in peatlands.
 * **_The study does not report the bottom of the layer for the deepest layer. What should I do?_** 
 Write "Inf" as infinity in the **_lyr_bot_** field.
 * **_What do I do if there are some analyses for a composite of multiple layer samples (different depth interval) and some data for each of the layers? E.g. some analyses were made on each of layers 0-5 and 5-10 cm and some other were made on a composite 0-10 cm?_**
In this case, you should create a new "composite" layer with a depth range of 0 to 10 cm. Additionally, it is critical that you denote this layer as a composite by marking "y" in the **_lyr_composite_** field.
</p></details>

<details><summary>  
<b> Radiocarbon Units </b>
</summary><p> 
  
 * **_What radiocarbon units are accepted?_** 
   ISRaD accepts fraction modern and  Δ<sup>14</sup>C radiocarbon units. Only fill in the data reported in the paper. Unit conversions perfomed separately and included in *ISRaD_extra* data object, which is part of the ISRaD [R-package].   
 * **_This paper only reports radiocarbon ages in years. What do I do?_** 
   If the data is reported as a *calibrated date*, it cannot be included in ISRaD. *Uncalibrated* radiocarbon ages can be converted to fraction modern values (see below).  
 * **_How do I convert radiocarbon age (in years BP) into Fraction modern units?_**
   radiocarbon `age = -8033 * ln (F<sub>m</sub>)`. Some additional information on radiocarbon units and calucations is available [here](http://www.whoi.edu/nosams/radiocarbon-data-calculations)  
* **_How do I convert standard deviation in radiocarbon age (in years BP) into standard deviation in Fraction modern?_**
  Use the following formula (Stenström et al., 2011): `error_F<sub>m</sub> = F<sub>m</sub> * error<sub>age</sub> / 8033`, 
where F<sub>m</sub> is fraction modern.   
 * **_Paper reports radiocarbon age and δ<sup>14</sup>C, what should I fill into the template?_**
   Convert radiocarbon age to Fraction modern using `age = -8033 * ln (F<sub>m</sub>)` and ignore δ<sup>14</sup>C values. Be sure to mark down the year of observation which is important for the conversion of Fm to Δ<sup>14</sup>C.  
 * **_Paper reports only δ<sup>14</sup>C and δ<sup>13</sup>C, what should I fill into the template?_**
  Calculate Δ<sup>14</sup>C using the following formula: 
  `Δ<sup>14</sup>C = δ<sup>14</sup>C - (2*δ<sup>13</sup>C +50)(1 + δ<sup>14</sup>C / 1000)`    
 * **_The radiocarbon age is stated as  “Modern” but no other data is provided. What do I do?_**
  Leave the field blank and add a note that data is available but has to be mined for. Do *not* enter a fraction modern value of 1! This is misleading during data analysis!   
</p></details>

<details><summary>  
<b> Additional Data </b>
</summary><p>

 * **_The paper contains some auxiliary data (e.g. species composition, mineralogy etc.) that I don´t know how to enter or don't have time to do enter. What should I do?_** 
   Mention this in the **_metadata_note_** field so that one day someone can come back to this. If you are interested in learning how to enter it, contact *info.israd@gmail.com*, or post a question on the [Github issues page](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/issues).

</p></details>

<details><summary>  
<b> Missing Data </b>
</summary><p>

 * **_The authors don't report the coordinates. What should I do?_** 
    You can digitize the coordinates from the figure, or find the site location on Google maps or similar. Please use the **_metadata_note_** field to indicate this. (e.g. “Cordinates were extracted from figures” or "Coordinates were estimated from site descriptions")
 * **_What should I do if the date of observation was not reported in the paper?_** 
   If paper has radiocarbon data but does not report the observation year, estimate it by subtracting 3 years from the year of publication and note in the **_lyr_note_** field or other relevant note field. (e.g.  “observation date estimated from year of publication”)
 
 * **_Do I have to fill in all the columns in the template?_**
   No, only some columns are required. The required columns are indicated in the [Template Information File] (https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/inst/extdata/ISRaD_Template_Info.xlsx) (by “yes” in the “Required” column) and also using red font in the template. Although we encourage you to fill out as many fields as possible, it is perfectly ok if many columns are left empty and some columns are only partly filled in. Please leave the fields with missing data empty (i.e., do not fill in zeros or NAs).

* **_Can I delete or hide columns in the template (e.g., because I do not plan to fill them in and they are distracting me) or change order of columns in the template?_**
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
      
<img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/density_separation_diagram.png" width="375">    

Example template: [Swanston_2005](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/Swanston_2005.xlsx)
</p></details>

<details><summary>  
<b> Sequential Density Separation </b>
</summary><p>
  
 * **_What is a sequential density separation?_**  
A heavy liquid is used to float off the "light-fraction" organics, thereby separating them from mineral material. The remaining mineral material is then further partitioned into series of fractions isolated by incrementally increasing the density of the heavy liquid used for the separation.  
      
<img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/sequential_density_separation_diagram.png" width="700">    

Example template: [Sollins_2009](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/Sollins_2009.xlsx)
</p></details>

<details><summary>  
<b> Particle Size Separation </b>
</summary><p>
  
* **_What is particle size separation?_**   
A physcial fractionation method where wet- or dry-sieving is used to separate soils into common particle size classes: sand, silt, clay.   
      
<img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/particle_size_separation_diagram.png" width="450">    

 Example template: [Desjardines_1994](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/Dejardins_1994.xlsx)
</p></details>

<details><summary>  
<b> Aggregate fractionation </b>
</summary><p>
  
 * **_What is aggregate fractionation?_**   
A fractionation procedure where wet sieving is used to separate aggregates by size and/or strength. Silt+clay sized fractions may be additionally isolated.   
      
<img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/aggregate_fractionation_diagram.png" width="550">    

 Example template: [Monreal_1997](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/Monreal_1997.xlsx)
 
</p></details>

<details><summary>  
<b> Dummy Fractions </b>
</summary><p>
  
 * **_What are dummy fractions and when are they needed_**   
 "Dummy fractions" are placeholder rows in the fraction tab. There are two reasons that dummy fractions might be required: (1) To represent a mass of material generated from a fractionation procedure but that is unaccounted for in measurements or the reporting of data. In other words, we want to be able to sum our mass of material back to 100% of the bulk value. Sometimes a fraction of the sample mass is calculated by difference rather than measured directly. In that case, we should create a dummy fraction to account for that mass, which was not physcially isolated. (2) To allow for reconstruction of a complex fractionation procedure that cannot be reconstructed without the use of a dummy layer. Not sure if you need to create a dummy fraction? Check out these examples: 
 
 **(a) All mass accounted for.** 
 Here, all the fractions in level 2 are unique and add up to level 1 – no dummy fraction needed.
 
 <img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/dummy_fractions_a.png" width="650"> 
 
 
 **(b) Well-known schemes.** 
 Here, all the fractions in level 2 and 3 are unique and add up to level 1. If the “Golchin” density fractionation were not common knowledge, you’d probably want a dummy fraction, but we don’t need one because the 3 fraction density separation is simple and all the end users should have knowledge of it.
 
 <img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/dummy_fractions_b.png" width="500"> 
 
**(c) Intermediate-fractions.** 
Here, the silt and clay fraction from level 3 needs to be distinguished from the silt and clay fraction from level 2 in a way that lets the end user know what each fraction was derived from. No measurements were made on the 53-250 um aggregate fraction (red circle) prior to further fractionation, so we need a dummy fraction to represent what the level 3 fractions came from.

 <img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/dummy_fractions_c.png" width="500">   
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

<p> If you have a question that is not answered here, please feel free to reach out to us! The best way is to post your question or comment on the [GitHub issues page](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/issues). For this you need to [create an account on GitHub](https://github.com/join?source=experiment-header-dropdowns-home) if you don't have one but it is easy (and free). You can also send us an e-mail to israd@gmail.com or contact us on [Twitter](https://twitter.com/soilradiocarbon). </p>
