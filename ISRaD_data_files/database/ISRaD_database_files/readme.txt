## Readme for ISRaD_database_files

# Versioning
File names contain the version number which is the date that the file was generated. 

# "ISRaD_data" vs "ISRaD_extra"
"ISRaD_data" files contain the raw database compiled from previous studies
"ISRaD_extra" includes several new variables created from the raw data and additional features, such as filling in latitude and longitude for profiles using information at the site level.

# "flat" files
The data is offered in several formats. Unlike the other data objects in the folder which are structured according to the ISRaD hierarchy in an Excel sheet, the flat files are a "flat" CSV file. These flat files are for users who only want data at a certain level. For example, if you are interested only in fraction data, the flat_fraction CSV file contains this data in an easy to use format and includes information from the previous levels (ie. site, profile, and layer levels as well).

# Reading data into R
The ISRaD R package includes an easy to use function to read the data into R. You just need to specify the directory where ISRaD_database_files is located and a few parameters to indicate which data you would like to load.

ISRaD.getdata

