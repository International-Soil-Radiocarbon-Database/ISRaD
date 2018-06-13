---
layout: splash
permalink: /
header:
  overlay_image: /assets/images/soil.jpg
  caption: 'International Soil Radiocarbon Database'
feature_row:
  - image_path: /assets/images/structure_new.png
    alt: "About"
    title: "About"
    excerpt: "ISRad history, community, publications, terms of use, steering committee and contact information"
    url: "/about/"
    btn_class: "btn--primary" 
    btn_label: "Learn More"
  - image_path: /assets/images/structure_new.png
    title: "Database"
    excerpt: "ISRaD data structure, current data summary, and latest database release"
    url: "/database/"
    btn_class: "btn--primary"
    btn_label: "Learn More"
  - image_path: /assets/images/mm-free-feature.png
    alt: "100% free"
    title: "Contribute"
    excerpt: "ISRaD template file, template information and user guide, and ISRaD data quality control webtool user gude"
    url: "/contribute/"
    btn_class: "btn--primary"
    btn_label: "Learn More"
---

{% include feature_row id="intro" type="center" %}

{% include feature_row %}
=======


![](assets/images/USGS.jpg)
![](assets/images/PowellCenter.jpeg)
![](assets/images/MPI-BGC_logo_EN.png)

## TEST

## Database structure
![](site_files/assets/images/structure_new.png)

## Database template

Original template:
[Template file](https://github.com/powellcenter-soilcarbon/soilcarbon/raw/master/inst/extdata/Master_template_orig.xlsx) (Variables with red column names are required)  
[Template instructions](/site_files/Template_info.html)

Template with flux, incubation, and interstitial data:
[Template file](https://github.com/powellcenter-soilcarbon/soilcarbon/raw/master/inst/extdata/Master_template_MPI_v10.xlsx) (Variables with red column names are required)  
[Template information](https://github.com/powellcenter-soilcarbon/soilcarbon/raw/master/inst/extdata/Template_info_MPI_v10.xlsx)

## Add data!

To contribute data to the soilcabon database, data files must pass a quality control step that ensures the file and it's contents are compatible with the structure and vocabulary of the database (see Template file and instructions above for explanation). 

#### [Check your data here](http://powellcenter-soilcarbon.ocpu.io/soilcarbon/www/)

### Current data
The current version of the publicly available Soil Radiocarbon Database includes data compiled through the efforts of two previous studies. If you access data from this repository, please cite the following references:

He, Y., Trumbore, S. E., Torn, M. S., Harden, J. W., Vaughn, L. J. S., Allison, S. D., & Randerson, J. T. Radiocarbon constraints imply reduced carbon uptake by soils during the 21st century. Science, 355(6306), 1419–1424. http://doi.org/10.1126/science.aag0262

Mathieu, J. A., Hatté, C., Balesdent, J., & Parent, É. (2015). Deep soil carbon dynamics are driven more by soil type than by climate: a worldwide meta-analysis of radiocarbon profiles. Global Change Biology, 21(11), 4278–4292. http://doi.org/10.1111/gcb.13012"

A detailed list of the data sources that are included can be found here:
[Datasets and doi numbers available and in progress](/site_files/make_current_dataset_list.html) 

[Making plots](/site_files/Plots.html)

![](site_files/assets/images/mat.png)
![](site_files/assets/images/map.png)



![](site_files/assets/images/layerplot.png)
![](site_files/assets/images/fractionplot.png)

## Contribute to soilcarbon package
[Instructions for making a pull request](pull-requests).

#### Helpful links:
[https://www.thinkful.com/learn/github-pull-request-tutorial/](https://www.thinkful.com/learn/github-pull-request-tutorial/)

[https://gist.github.com/Chaser324/ce0505fbed06b947d962](https://gist.github.com/Chaser324/ce0505fbed06b947d962)

The Soil Carbon Database has been developed in collaboration between the U.S. Geological Survey Powell Center and the Max Planck Institute for Biogeochemistry”

Contact: for questions about the soilcarbon package, Grey at greymonroe@gmail.com. 

