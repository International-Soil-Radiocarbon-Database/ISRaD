---
layout: splash
permalink: /rpackage/
title: "ISRaD R Package"
header:
  overlay_image: /assets/images/soil.jpg
htmlwidgets: TRUE
---

# Frequently Asked Questions

## Template Entry

**The source study does not have a DOI, what should I do?**

> _If the data are unpublished but you expect them to be published in the future (thus obtaining DOI), you can submit the template without DOI and then later submit a correction of the template with DOI. If you take this approach please fill in “israd” into the “doi” field in metadata tab. Also note that data from this entry will not be compiled in the R-package data objects until a DOI is added._ 

**Is there any rule on how many decimal places are reasonable to enter when data are digitized from a plot?**

> _No, use your best guess about the appropriate number of decimal places based on expected precision of plot digitization and/or data acquisition._

**Should I mention somewhere in the template that the data (e.g., GPS coordinates and others) were obtained from figures?**

> _Yes, use `metadata_note`. Say for example “GPS coordinates and variables x,y and z were extracted from figures”._

**How do I convert standard deviation in radiocarbon age (in years BP) into standard deviation in Fraction modern?** 

> _Use the following formula (Stenström et al., 2011): error_Fm = Fm × (error_age/8033), where Fm is fraction modern._ 

**The paper reports radiocarbon age and δ14C, what should I fill into the template?**

> _Convert radiocarbon age to Fraction modern using age = -8033*ln(Fm) and ignore δ14C values. Be sure to record down the year of observation which is important for the conversion of Fm to Δ14C._

**Paper reports only δ14C and δ13C, what should I fill into the template?**

> _Calculate Δ14C using: Δ14C = δ14C - (2*δ13C +50)(1 + δ14C/1000)_

**What to do if the study does not report the bottom of the layer for the deepest layer?**

> _Denote the bottom depth as "Inf“ in the `lyr_bot` field._

**The paper contains some auxiliary data (e.g. species composition, mineralogy etc.) which is not included in the template, what should I do?**

> _There is a protocol for requesting that new variables be added to the database. At the very least, please note the additional variables reported in the study but not added to the template in the `metadata_note` field._

**The study reports organic matter content and not organic carbon %, what should I do?**

> _You should convert the organic matter values to organic carbon using OC = OM/1.724 and add "OC calculated from OM" in the `lyr_note` field._

**What do I do if there are some analyses for a composite of multiple layer samples (different depth interval) and some data for each of the layers? E.g. some analyses were made on each of layers 0-5 and 5-10 cm and some other were made on a composite 0-10 cm?**

> _In this case, you should create a new "composite" layer with a depth range of 0 to 10 cm. Additionally, it is critical that you denote this layer as a composite by marking "y" in the `lyr_composite` field._

**What do I do when radiocarbon age is stated as “Modern” but no other data is provided?**

> _Unfortunately this is not enough information, you should leave the radiocarbon field blank but you should also make a note (e.g., as applicable in `lyr_note` or `frc_note`) that "C14 data exist"._

**What do I do when the mandatory observation date was not reported in the paper?**

> _If paper has radiocarbon data but does not report the observation year, estimate it by subtracting 3 years from the year of publication and note in `lyr_note`, e.g. “observation date estimated from year of publication”_




