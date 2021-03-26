##### Metadata:
#
# Data set: Brazilian Federal Highways
#
# Source: National Department of Transport - DNIT.
#
# website: http://servicos.dnit.gov.br/dnitcloud/index.php/s/oTpPRmYs5AAdiNr
#
# Update frequency: At least three times a year
#
# Summary: Detail information about Federal Highways
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

#update <- "202101A" # Example: October 2019


###### 0. Create directories to downlod and save the data -----------------

# Set a root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw"
setwd(root_dir)


# Create Directory to keep original downloaded files
destdir_raw <- "./federal_highway"
dir.create(destdir_raw)

# Create Directory to save clean sf.rds files
destdir_clean <- paste0("./federal_highway/sf_all_years_original/")
dir.create(destdir_clean, recursive =T)

# Create Directory to save clean sf.rds files
destdir_clean <- paste0("./federal_highway/sf_all_years_cleaned/")
dir.create(destdir_clean, recursive =T)





###### 1. download the raw data from the original website source -----------------
setwd("L:/# DIRUR #/ASMEQ/geobr/data-raw/federal_highway/")
temp <- tempfile()
download.file("https://servicos.dnit.gov.br/dnitcloud/index.php/s/oTpPRmYs5AAdiNr/download",temp, mode="wb")
unzip(temp)
#setwd(root_dir)

###### 1.1. Unzip data files if necessary -----------------

# list and unzip zipped files
zipfiles <- list.files(path = 'L:/# DIRUR #/ASMEQ/geobr/data-raw/federal_highway/RepositÃ³rio/SNV Bases GeomÃ©tricas (2013-Atual) (SHP)/', full.names = T, pattern = "*.zip")
files <- list.files(path = 'L:/# DIRUR #/ASMEQ/geobr/data-raw/federal_highway/RepositÃ³rio/SNV Bases GeomÃ©tricas (2013-Atual) (SHP)/', full.names = F, pattern = "*.zip")
files <- gsub(".zip","",files)

for(i in 1:length(zipfiles)){
  # create a subdirectory of years
  dir.create(file.path(paste0("./sf_all_years_original/",files[i])))
  dir.create(file.path(paste0("./sf_all_years_cleaned/",files[i])))

  dir.dest<- file.path(paste0("./sf_all_years_original/",files[i]))
  setwd(dir.dest)
  unzip(zipfiles[i])

  setwd("L:/# DIRUR #/ASMEQ/geobr/data-raw/federal_highway/")
}



###### List original data sets -----------------

# list all files
raw_shapes <- list.files("./sf_all_years_original/", pattern = ".shp", recursive = T, full.names = T)
raw_shapes <- raw_shapes2[raw_shapes2 %nlike% '.xml']


### If there are various data sets for various dates, states etc etc. it ideal to create a
### function that will work over a list of all datasets and clean and save them accordingly

cleaning_data_fun <- function(f){ # f <- raw_shapes[1]

  ### read data
  temp_sf1 <- st_read(f, quiet = F, stringsAsFactors=F, options = "ENCODING=UTF8")
  head(temp_sf1)

  file <- substr(f,25,31)
  file

  name <- paste0("federal_highway_",file)

  ###### 2. rename column names -----------------


  # ? temp_sf1$length2 <- st_length(temp_sf1) *1000
  # summary(temp_sf1$length2)
  # summary(temp_sf1$Shape_len)
  # summary(temp_sf1$Extens.e3.o)


  # Rename columns examples
  if(file %in% "201301A"){
    temp_sf2 <- temp_sf1 %>%
      dplyr::select(c(ID = OBJECTID  ,
               code_highway =  BR,
               abbrev_state = UF,
               first_km = km_inicial,
               last_km = km_final,
               extension = Extens.e3.o,
               geometry= geometry))
  } else if(file %in% c("201503A")) {
    temp_sf2 <- temp_sf1 %>%
      dplyr::select(c(ID = OBJECTID ,
               code_highway =  br,
               abbrev_state = uf,
               first_km = km_inicial,
               last_km = km_final,
               extension = extensao,
               geometry))
  } else {
    if(file %in% c("201606A")){
      colnames(temp_sf1)[1] <- "id_trecho_"
    }

    temp_sf2 <- temp_sf1 %>%
      dplyr::select(c(ID = id_trecho_,
               code_highway =  vl_br,
               abbrev_state = sg_uf,
               first_km = vl_km_inic,
               last_km = vl_km_fina,
               extension = vl_extensa,
               geometry))
  }




  ###### 3. ensure the data uses spatial projection SIRGAS 2000 epsg (SRID): 4674-----------------

  temp_sf3 <- harmonize_projection(temp_sf2)

  st_crs(temp_sf3)$epsg
  st_crs(temp_sf3)$input
  st_crs(temp_sf3)$proj4string
  st_crs(st_crs(temp_sf3)$wkt) == st_crs(temp_sf3)


  ###### 4. ensure every string column is as.character with UTF-8 encoding -----------------
  options(encoding = "UTF-8")
  temp_sf4 <- use_encoding_utf8(temp_sf3)
  head(temp_sf4)

  # keep code as.numeric()
  #numeric_columns <- names(temp_sf4)[ names(temp_sf4) %like% 'code_' ]

  #for (col in numeric_columns){
  #  temp_sf4[[col]] <- as.numeric((temp_sf4[[col]]))
  #}


  ###### 5. remove Z dimension of spatial data-----------------
  temp_sf5 <- temp_sf4 %>% st_sf() %>% st_zm( drop = T, what = "ZM")



  ###### 6. fix eventual topology issues in the data-----------------
  temp_sf6 <- sf::st_make_valid(temp_sf5)




  ###### 7. generate a lighter version of the dataset with simplified borders -----------------
  # skip this step if the dataset is made of points, regular spatial grids or rater data

  # simplify
  temp_sf7 <- simplify_temp_sf(temp_sf6)


a<- subset(temp_sf6, abbrev_state=='MG' )
sf::st_write(a, paste0("./sf_all_years_cleaned/", file,"/",name, "mg.gpkg"), delete_layer = TRUE)

  ###### 8. Clean data set and save it in geopackage format-----------------

  # save original and simplified datasets
  sf::st_write(temp_sf6, paste0("./sf_all_years_cleaned/", file,"/",name, ".gpkg"), delete_layer = TRUE)
  sf::st_write(temp_sf7, paste0("./sf_all_years_cleaned/", file,"/",name, " _simplified", ".gpkg"), delete_layer = TRUE)
}


# Apply funtion to all raw data sets

lapply(X=raw_shapes, FUN = cleaning_data_fun)
