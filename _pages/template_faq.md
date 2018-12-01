---
layout: splash
permalink: /contribute/
title: "Contribute to ISRaD"
header:
  overlay_image: /assets/images/soil.jpg
---

Filling out a template can be confusing! This page provides detailed information and examples for each tab of the template. Click to see full details.

### General FAQ

<details><summary>  
<b> Radiocarbon Units </b>
</summary><p>

   * **_What units are accepted?_** 
   ISRaD accepts fraction modern and  Δ<sup>14</sup>C radiocarbon units. Only fill in the data reported in the paper. Unit conversions are included in "ISRaD_extra"
 
   * **_This paper only reports radiocarbon ages in years. What do I do?_** 
   If the data is reported as a *calibrated date*, it cannot be included in ISRaD. *Uncalibrated* radiocarbon ages can be converted to fraction modern values (see below).
   
   * **_How do I convert radiocarbon age (in years BP) into Fraction modern units?_**
   radiocarbon age = -8033*ln(F<sub>m</sub>). Some additional information on radiocarbon units and calucations is available [here](http://www.whoi.edu/nosams/radiocarbon-data-calculations)
   
   * **_How do I convert standard deviation in radiocarbon age (in years BP) into standard deviation in Fraction modern?_**
  Use the following formula (Stenström et al., 2011): error_F<sub>m</sub> = F<sub>m</sub> * error<sub>age</sub> / 8033 , 
where F<sub>m</sub> is fraction modern. 

   * **_Paper reports radiocarbon age and δ<sup>14</sup>C, what should I fill into the template?_**
   Convert radiocarbon age to Fraction modern using age= -8033*ln(F<sub>m</sub>) and ignore δ<sup>14</sup>C values. Be sure to mark down the year of observation which is important for the conversion of Fm to Δ<sup>14</sup>C.
   
   * **_Paper reports only δ<sup>14</sup>C and δ<sup>13</sup>C, what should I fill into the template?_**
  Calculate Δ<sup>14</sup>C using the following formula: 
  Δ<sup>14</sup>C = δ<sup>14</sup>C - (2*δ<sup>13</sup>C +50)(1 + δ<sup>14</sup>C / 1000)
  
   * **_The radiocarbon age is stated as  “Modern” but no other data is provided. What do I do?_**
  Leave the field blank and add a note that data is available but has to be mined for. Do *not* enter a fraction modern value of 1! This is misleading during data analysis!




</p>
</details>



<details><summary>  
<b> Data or Coordinates from Figures </b>
</summary><p>

 * **_Is it ok to digitize data/coordinates from a figure/map?_** 
   Yes, but please note it (see below). While the raw data from the author or supplementary information is preferable, digitized data is also welcome in ISRaD.
 * **_Should I mention somewhere in the template that the data (e.g., GPS coordinates and others) were obtained from figures?_**
 Yes, use the *metadata_note* field. Say for example “GPS coordinates and variables x,y and z were extracted from figures”.

 * **_Is there any rule on how many decimal places are reasonable to enter when data are digitized from a plot?_** 
   No, use your best guess about the appropriate number of decimal places based on expected precision of plot digitization and/or data acquisition.

</p>
</details>



<details><summary>  
<b> Updating templates from He et al. (2016) compilation </b>
</summary><p>

 * **_Why does this template look different?_** 
   These templates were automatically generated, and do not have the header formatting. You can copy-paste the values to the master template to continue working. This will also give you access to the drop down menus for controlled vocabulary.
   
 * **_Paper does not mention bulk density, but old template automatically generated from Yujie He’s compilation gives bulk density for few samples measured by radiocarbon. Should I keep them in the template?_**
 No. In some cases bulk density values were generated for studies that originally did not report them. ISRaD aims to report original data only.

 * **_These names don't match the paper. What do I do?_** 
  In many cases, site, profile and layer names were automatically generated. Please feel free to update them to match those found in the paper. 
  
 * **_The paper has additional fraction, flux, or incubation data, not reported in the current template. What should I do with it?_** 
   If you have time, please add it! Otherwise, please make a note of the availability of additional datasets within the paper in the *metadata_note* field.

</p>
</details>



<details><summary>  
<b> Metadata </b>
</summary><p>

 * **_The source study does not have a DOI, what should I do?_** 
 You have two options: (1) If the data are unpublished but you expect them to be published in the future (thus obtaining DOI), you can submit the template without DOI and then later submit a correction of the template with DOI. Fill in “israd” into the “doi” field in metadata tab. (2) If data are unpublished and you do not expect them to be published in the future, you can encourage authors to obtain a DOI for their data using Pangea, Zenodo, or Dataverse or ask your institution´s library for help.


</p>
</details>





<details><summary>  
<b> Depth Conventions </b>
</summary><p>

 * **_Where is zero?_** 
 Zero is defined as the mineral-organic interface. Positive depths increase into the mineral soil. Organic horizons have negative depths. Please convert your data to follow this convention. If data must be reported from the soil surface, use the “lyr_all_org_neg” column to flag this.
 
 * **_What is the "lyr_all_org_neg" column for?_** 
 This column is used to flag studies where depths are reported from the soil surface, if the depth of the mineral-organic interface is unknown. For example, this is frequently the case in peatlands.
 
 * **_The study does not report the bottom of the layer for the deepest layer. What should I do?_** 
 Write "Inf" as infinity in the lyr_bot field.

</p>
</details>


<details><summary>  
<b> Additional Data </b>
</summary><p>

 * **_The paper contains some auxiliary data (e.g. species composition, mineralogy etc.) that I don´t know how to enter or don't have time to do enter. What should I do?_** 
   Mention this in *metadata_note* field so that one day someone can come back to this. If you are interested in learning how to enter it, contact *info.israd@gmail.com*, or post a question on the [Github issues page](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/issues).

</p>
</details>




<details><summary>  
<b> Missing Data </b>
</summary><p>

 * **_The authors don't report the coordinates. What should I do?_** 
    You can digitize the coordinates from the figure, or find the site location on Google maps or similar. Please use the *metadata_note* field to indicate this. (e.g. “Cordinates were extracted from figures” or "Coordinates were estimated from site descriptions")

 * **_What should I do if the date of observation was not reported in the paper?_** 
   If paper has radiocarbon data but does not report the observation year, estimate it by subtracting 2 years from the year of publication and note in the *lyr_note* field or other relevant note field. (e.g.  “observation date estimated from year of publication”)

</p>
</details>



<details><summary>  
<b> Soil Order </b>
</summary><p>

 * **_How do I convert WRB soil classification to USDA, to obtain a USDA soil order?_** 
 FAO, USDA and other soil classification systems are not readily interchangeable, so this can be tricky. These tables can help:
(1) [FAO_USDA.pdf](https://www.researchgate.net/profile/Csaba_Csuzdi/post/How_to_convert_FAO_soil_class_into_USDA_soil_class/attachment/59d62fd079197b807798df0e/AS%3A359920387018752%401462823115202/download/FAO_USDA.pdf).  (2) [soil system conversion.pdf](https://www.researchgate.net/profile/Csaba_Csuzdi/post/How_to_convert_FAO_soil_class_into_USDA_soil_class/attachment/59d62fd079197b807798df10/AS%3A359920387018756%401462823115460/download/soil+system+conversion.pdf). 
The issue is also discussed [here](https://www.researchgate.net/post/How_to_convert_FAO_soil_class_into_USDA_soil_class).
Finally, if you feel uncomfortable with this conversion, mention this in the email submitting your template, and an expert reviewer can double check this field for you.
(https://www.researchgate.net/post/How_to_convert_FAO_soil_class_into_USDA_soil_class)


</p>
</details>



<details><summary>  
<b> Organic Matter Content </b>
</summary><p>

 * **_The paper reports organic matter content instead of organic carbon %, what should I do?_** 
 Convert to organic carbon using OC=OM/1.724 and mention this in the *lyr_note* or other relevant field.


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
<b> General Information </b>
</summary><p>
  
 * **_The source study does not have a DOI, what should I do?_** 
 You have two options: (1) If the data are unpublished but you expect them to be published in the future (thus obtaining DOI), you can submit the template without DOI and then later submit a correction of the template with DOI. Fill in “israd” into the “doi” field in metadata tab. (2) If data are unpublished and you do not expect them to be published in the future, you can encourage authors to obtain a DOI for their data using Pangea, Zenodo, or Dataverse or ask your institution´s library for help.

</p>
</details>


<details><summary>  
<b> Density Separation </b>
</summary><p>

 **A heavy liquid is used to float off organics, thereby separating them from mineral material. This can be done with or without disruption of aggregates by sonicating or shaking.**   
      
<img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/density_separation_diagram.png" width="375">    

 Example template: [Swanston_2005](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/Swanston_2005.xlsx)

</p>
</details>



<details><summary>  
<b> Sequential Density Separation </b>
</summary><p>
  
**A heavy liquid is used to float off organics, thereby separating them from mineral material. The mineral material is then further partitioned into fractions of increasing density using heavy liquids.**   
      
<img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/sequential_density_separation_diagram.png" width="700">    

Example template: [Sollins_2009](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/Sollins_2009.xlsx)

</p>
</details>



<details><summary>  
<b> Particle Size Separation </b>
</summary><p>
  
**Wet sieving is used to separate soils into common particle size classes: sand, silt, clay.**   
      
<img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/particle_size_separation_diagram.png" width="450">    

 Example template: [Desjardines_1994](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/Dejardins_1994.xlsx)

</p>
</details>



<details><summary>  
<b> Aggregate fractionation </b>
</summary><p>
  
**Wet sieving is used to separate aggregates by size and/or strength. Silt+clay sized fractions may be additionally isolated.**   
      
<img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/aggregate_fractionation_diagram.png" width="550">    

 Example template: [Monreal_1997](https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/Monreal_1997.xlsx)
 
</p>
</details>




<details><summary>  
<b> Other Fractionation Schemes </b>
</summary><p>
  
 * **_The source study does not have a DOI, what should I do?_** 
 You have two options: (1) If the data are unpublished but you expect them to be published in the future (thus obtaining DOI), you can submit the template without DOI and then later submit a correction of the template with DOI. Fill in “israd” into the “doi” field in metadata tab. (2) If data are unpublished and you do not expect them to be published in the future, you can encourage authors to obtain a DOI for their data using Pangea, Zenodo, or Dataverse or ask your institution´s library for help.

</p>
</details>



<details><summary>  
<b> Dummy Fractions </b>
</summary><p>
  
 **"Dummy fractions" are placeholder rows in the fraction tab. In some cases, they may be needed to convey the full complexity of the fractionation scheme.** Not sure if you need to create a dummy fraction? Check out these examples: 
 
 **(a) All mass accounted for:** Here, all the fractions in level 2 are unique and add up to level 1 – no dummy fraction needed.
 
 <img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/dummy_fractions_a.png" width="650">   

 **(b) Well-known schemes:** Here, all the fractions in level 2 and 3 are unique add up to level 1 – if the “Golchin” density fractionation were not common knowledge, you’d probably want a dummy fraction, but we don’t need one because the 3 fraction density separation is simple and all the end users should have knowledge of it.
 
  <img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/dummy_fractions_b.png" width="500"> 
 
**(c) Intermediate-fractions:** Here, the silt and clay fraction from level 3 needs to be distinguished from the silt and clay fraction from level 2 in a way that lets the end user know what each fraction was derived from. No measurements were made on the 53-250 um aggregate fraction (red circle) prior to further fractionation, so we need a dummy fraction to represent what the level 3 fractions came from.

 <img src="https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/gh-pages/assets/images/dummy_fractions_c.png" width="500">   


</p>
</details>



  
### Fluxes

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

</summary>
<p>
1. Templates
2. Templates
3. Templates 
</p>
</details>

### Interstitial

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

</summary>
<p>
1. Templates
2. Templates
3. Templates 
</p>
</details>
