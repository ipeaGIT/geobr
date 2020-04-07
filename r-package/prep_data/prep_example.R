##### Metadata:
#
# Data set: name of the data set
#
# Source: Agency that produces the data
#
# website: website to download the data from
#
# Update frequency: How often the data is updated
#
# Summary: one or two sentences to explain what the information in the dataset
#
# key-words:


### Libraries (use any library as necessary)

library(geobr)
library(RCurl)
library(stringr)
library(sf)
library(dplyr)
library(readr)
library(data.table)
library(magrittr)
library(lwgeom)
library(stringi)
library(mapview)
library(furrr)
# library(sp)


####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")


# If the data set is updated regularly, you should create a function that will have
# a `date` argument download the data

update <- 201910 # Example: October 2019



###### 0. Create directories to downlod and save the data -----------------

# Set a root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw"
setwd(root_dir)


# Create Directory to keep original downloaded files
destdir_raw <- "./new_data"
dir.create(destdir_raw)


# Create Directory to save clean sf.rds files
destdir_clean <- paste0("./new_data/sf_all_years_cleaned/", update)
dir.create(destdir_clean, recursive =T)





###### 1. download the raw data from the original website source -----------------





###### 1.1. Unzip data files if necessary -----------------

  # list and unzip zipped files
  zipfiles <- list.files(pattern = ".zip")
  unzip(zipfiles)




###### List original data sets -----------------

# list all files
  raw_shapes <- list.files(path= destdir_raw, full.names = T, pattern = ".shp")





### If there are various data sets for various dates, states etc etc. it ideal to create a
### function that will work over a list of all datasets and clean and save them accordingly


cleaning_data_fun <- function(f){

### read data
  temp_sf1 <- st_read(f, quiet = F, stringsAsFactors=F, options = "ENCODING=UTF8")



###### 2. rename column names -----------------

# Rename columns examples
  temp_sf2 <- temp_sf1 %>% dplyr::select(
                            code_muni = GEOCODIGO,
                            name_muni = NOME_MUNIC,
                            name_state = Nome_Estado,
                            abbrev_state = UF,
                            ...
                            geometry = geometry
                            )


###### 3. ensure the data uses spatial projection SIRGAS 2000 epsg (SRID): 4674-----------------

temp_sf3 <- harmonize_projection(temp_sf2)

st_crs(temp_sf3)$epsg
st_crs(temp_sf3)$input
st_crs(temp_sf3)$proj4string
st_crs(st_crs(temp_sf3)$wkt) == st_crs(temp_sf3)

###### 4. ensure every string column is as.character with UTF-8 encoding -----------------

# convert all factor columns to character
temp_sf4 <- temp_sf3 %>% mutate_if(is.factor, function(x){ x %>% as.character() } )

# convert all character columns to UTF-8
temp_sf4 <- temp_sf4 %>% mutate_if(is.character, function(x){ x %>% stringi::stri_encode("UTF-8") } )


###### 5. remove Z dimension of spatial data-----------------

# remove Z dimension of spatial data
temp_sf5 <- temp_sf4 %>% st_sf() %>% st_zm( drop = T, what = "ZM")



###### 6. fix eventual topology issues in the data-----------------

# Make any invalid geometry valid # st_is_valid( sf)
temp_sf6 <- lwgeom::st_make_valid(temp_sf5)



###### 7. generate a lighter version of the dataset with simplified borders -----------------
# skip this step if the dataset is made of points, regular spatial grids or rater data

# simplify
temp_sf7 <- st_transform(temp_sf6, crs=3857) %>% sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)


###### 8. Clean data set and save it in geopackage format-----------------

# save original and simplified datasets
sf::st_write(temp_sf6, path= paste0(destdir_clean, "/new_data_", update, ".gpkg"))
sf::st_write(temp_sf7, path= paste0(destdir_clean, "/new_data_", update," _simplified", ".gpkg"))
}


# Apply funtion to all raw data sets

lapply(X=raw_shapes, FUN = cleaning_data_fun)
