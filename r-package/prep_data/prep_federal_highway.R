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
destdir_original <- paste0("./federal_highway/sf_all_years_original/")
dir.create(destdir_original, recursive =T)

# Create Directory to save clean sf.rds files
destdir_clean <- paste0("./federal_highway/sf_all_years_cleaned/")
dir.create(destdir_clean, recursive =T)





###### 1. download the raw data from the original website source -----------------
setwd("L:/# DIRUR #/ASMEQ/geobr/data-raw/federal_highway/")
temp <- tempfile()
download.file(URLencode("https://servicos.dnit.gov.br/dnitcloud/index.php/s/oTpPRmYs5AAdiNr/download"),
              destfile = paste0(root_dir,"/federal_highway/sf_all_years_original/Repositorio.zip"), 
              method = "auto", mode="wb")
setwd("./sf_all_years_original")
unzip("./Repositorio.zip")

###### 1.1. Unzip data files if necessary -----------------

# list and unzip zipped files
setwd("L:/# DIRUR #/ASMEQ/geobr/data-raw/federal_highway/")
repo <- dir("./sf_all_years_original")
repozipfiles <- dir(paste0("./sf_all_years_original/",repo[1]))
SNV <- repozipfiles[3]
dir_repo <- paste0("./sf_all_years_original/",repo[1],"/",SNV,"/")
setwd(dir_repo)

a <- getwd()
zipfiles <- dir(a)
files <- gsub(".zip","",zipfiles)

for(i in 1:length(zipfiles)){
  unzip(zipfiles[i])
}



###### List original data sets -----------------

# list all files
raw_shapes <- list.files(".", pattern = ".shp", recursive = T, full.names = T)
raw_shapes <- raw_shapes[raw_shapes %nlike% '.xml']


### If there are various data sets for various dates, states etc etc. it ideal to create a
### function that will work over a list of all datasets and clean and save them accordingly

cleaning_data_fun <- function(f){ # f <- raw_shapes[2]

  setwd("L:/# DIRUR #/ASMEQ/geobr/data-raw/federal_highway/sf_all_years_original/Repositório/SNV Bases Geométricas (2013-Atual) (SHP)")
  
  ### read data
  temp_sf1 <- st_read(f, quiet = F, stringsAsFactors=F, options = "ENCODING=UTF8")
  head(temp_sf1)

  # rename files
  if(f %like% "RODOVIAS"){
    file <- paste0(substr(f,23,26),"01A")
  } else if(f %like% "Rodovias"){
    file <- "201606A"
  } else {
    file <- substr(f,7,13)
  }

  name <- paste0("federal_highway_",file)
  
  # create folder
  folder <- paste0("L:/# DIRUR #/ASMEQ/geobr/data-raw/federal_highway/sf_all_years_cleaned/",file)
  dir.create(folder)

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
               geom = geometry))
  } else if(file %in% "201503a") {
    temp_sf2 <- temp_sf1 %>%
      dplyr::select(c(ID = OBJECTID ,
               code_highway =  br,
               abbrev_state = uf,
               first_km = km_inicial,
               last_km = km_final,
               extension = extensao,
               geom = geometry))
  } else if(file %in% c("201606A")){
    temp_sf2 <- temp_sf1 %>%
      dplyr::select(c(ID = id_snv_old,
                      code_highway =  vl_br,
                      abbrev_state = sg_uf,
                      first_km = vl_km_inic,
                      last_km = vl_km_fina,
                      extension = vl_extensa,
                      geom = geometry))
  } else {
    temp_sf2 <- temp_sf1 %>%
      dplyr::select(c(ID = id_trecho_,
                      code_highway =  vl_br,
                      abbrev_state = sg_uf,
                      first_km = vl_km_inic,
                      last_km = vl_km_fina,
                      extension = vl_extensa,
                      geom = geometry))
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


  ###### 5. remove Z dimension of spatial data-----------------
  temp_sf5 <- temp_sf4 %>% st_sf() %>% st_zm( drop = T, what = "ZM")



  ###### 6. fix eventual topology issues in the data-----------------
  temp_sf6 <- sf::st_make_valid(temp_sf5)




  ###### 7. generate a lighter version of the dataset with simplified borders -----------------
  # skip this step if the dataset is made of points, regular spatial grids or rater data

  # simplify
  temp_sf7 <- simplify_temp_sf(temp_sf6)
  
  federal_dir <- paste0(root_dir,"/federal_highway")
  setwd(federal_dir)
  # a<- subset(temp_sf6, abbrev_state=='MG' )
  # sf::st_write(a, paste0("./sf_all_years_cleaned/", file,"/",name, "mg.gpkg"), delete_layer = TRUE)
  
  ###### 8. Clean data set and save it in geopackage format-----------------

  # save original and simplified datasets
  sf::st_write(temp_sf6, paste0("./sf_all_years_cleaned/", file,"/",name, ".gpkg"), delete_layer = TRUE)
  sf::st_write(temp_sf7, paste0("./sf_all_years_cleaned/", file,"/",name, " _simplified", ".gpkg"), delete_layer = TRUE)
}


# Apply funtion to all raw data sets

lapply(X=raw_shapes, FUN = cleaning_data_fun)
