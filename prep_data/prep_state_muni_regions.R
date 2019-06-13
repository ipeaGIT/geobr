library(RCurl)
#library(tidyverse)
library(stringr)
library(sf)
library(janitor)
library(dplyr)
library(readr)
library(parallel)
library(data.table)



    



#### 0. Download original data sets from IBGE ftp -----------------

ftp <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais"







########  1. Unzip original data sets downloaded from IBGE -----------------

# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais"
setwd(root_dir) 


#### 1.1. GROUP 1/3 - Data available separately by state in a single resolution E -----------------
# 2000, 2001, 2010, 2013, 2014
  
# List all zip files for all years
  all_zipped_files <- list.files(full.names = T, recursive = T, pattern = ".zip")
  
# Select files of selected years
  # 540 files (4 geographies x 27 states x 5 years) 4*27*5
  files_1st_batch <- all_zipped_files[all_zipped_files %like% "2000|2001|2010|2013|2014"]
  
  # all_zipped_files <- list.files(full.names = T, recursive = T, pattern = glob2rx("*al*.zip*")) 
  # all_zipped_files <- list.files(full.names = T, recursive = T, pattern = glob2rx("*ac_*.zip*")) 

# function to Unzip files in their original sub-dir 
  unzip_fun <- function(f){
                            # f <- files_1st_batch[1]
                            unzip(f, exdir = file.path(root_dir, substr(f, 2, 20) ))
                          }

# create computing clusters
  cl <- parallel::makeCluster(detectCores())
  parallel::clusterExport(cl=cl, varlist= c("files_1st_batch", "root_dir"), envir=environment())

# apply function in parallel
  parallel::parLapply(cl, files_1st_batch, unzip_fun)
  stopCluster(cl)


rm(list=setdiff(ls(), c("root_dir","all_zipped_files")))
gc(reset = T)
  



#### 1.2 GROUP 2/3 - Data available separately by state in a single resolution and file -----------------
# 2015, 2016, 2017, 2018

# List all zip files for all years
  all_zipped_files

# Select files of selected years
  files_2nd_batch <- all_zipped_files[all_zipped_files %like% "2015|2016|2017|2018"]

# remove Brazil files
  files_2nd_batch <- files_2nd_batch[!(files_2nd_batch %like% "BR")]

# Select one file for each state
# 540 files (4 geographies x 27 states x 4 years) 4*27*4
  files_2nd_batch <- files_2nd_batch[nchar(files_2nd_batch) > 30]


# function to Unzip files in their original sub-dir 
  unzip_fun <- function(f){
    # f <- files_2nd_batch[14]
    unzip(f, exdir = file.path(root_dir, substr(f, 2, 23)) )
  }
  
# create computing clusters
  cl <- parallel::makeCluster(detectCores())
  parallel::clusterExport(cl=cl, varlist= c("files_2nd_batch", "root_dir"), envir=environment())
  
# apply function in parallel
  parallel::parLapply(cl, files_2nd_batch, unzip_fun)
  stopCluster(cl)
  
  rm(list=setdiff(ls(), c("root_dir","all_zipped_files")))
  gc(reset = T)
  
  
  
  
  
  
  
  
#### 1.3 GROUP 3/3 - Data available separately by state in a single resolution and file -----------------
# 2005, 2007
  
# List all zip files for all years
  all_zipped_files
  
# Select files of selected years
  files_3rd_batch <- all_zipped_files[all_zipped_files %like% "2005|2007"]
  
# Selc only zip files organized by UF at scale  1:2.500.000
  # 54 files (27 files x 2 years) 27*2
  files_3rd_batch <- files_3rd_batch[files_3rd_batch %like% "escala_2500mil/proj_geografica/arcview_shp/uf|escala_2500mil/proj_geografica_sirgas2000/uf"]
  
# function to Unzip files in their original sub-dir 
  unzip_fun <- function(f){
    # f <- files_3rd_batch[54]
    
    # subdir to unzip/save files
      dest_dir <- file.path(root_dir, substr(f, 2, 65))

    # unzip
      unzip(f, exdir = dest_dir )
  }
  
  # create computing clusters
  cl <- parallel::makeCluster(detectCores())
  parallel::clusterExport(cl=cl, varlist= c("files_3rd_batch", "root_dir"), envir=environment())
  
  # apply function in parallel
  parallel::parLapply(cl, files_3rd_batch, unzip_fun)
  stopCluster(cl)
  
  rm(list= ls())
  gc(reset = T)
  
  





  
#### 2. Create folders to save sf.rds files  -----------------
 
# Root directory
  root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais"
  setwd(root_dir)
  sub_dirs <- list.dirs(path =root_dir, recursive = F) 
  
# get all years in the directory 
  last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
  years <- lapply(sub_dirs, last4)
  years <-  unlist(years)
  
  # create directory to save original shape files in sf format
  dir.create(file.path("shapes_in_sf_all_years_original"), showWarnings = FALSE)
  
  # create directory to save cleaned shape files in sf format
  dir.create(file.path("shapes_in_sf_all_years_cleaned"), showWarnings = FALSE)
  
# create a subdirectory of states, municipalities, micro and meso regions
  dir.create(file.path("shapes_in_sf_all_years_original", "uf"), showWarnings = FALSE)
  dir.create(file.path("shapes_in_sf_all_years_original", "meso_regiao"), showWarnings = FALSE)
  dir.create(file.path("shapes_in_sf_all_years_original", "micro_regiao"), showWarnings = FALSE)
  dir.create(file.path("shapes_in_sf_all_years_original", "municipio"), showWarnings = FALSE)
  
  dir.create(file.path("shapes_in_sf_all_years_cleaned", "uf"), showWarnings = FALSE)
  dir.create(file.path("shapes_in_sf_all_years_cleaned", "meso_regiao"), showWarnings = FALSE)
  dir.create(file.path("shapes_in_sf_all_years_cleaned", "micro_regiao"), showWarnings = FALSE)
  dir.create(file.path("shapes_in_sf_all_years_cleaned", "municipio"), showWarnings = FALSE)
  
# create a subdirectory of years
  sub_dirs <- list.dirs(path ="./shapes_in_sf_all_years_original", recursive = F) 
  
  for (i in sub_dirs){
    for (y in years){ 
      dir.create(file.path(i, y), showWarnings = FALSE)
      }
  }
  
  sub_dirs <- list.dirs(path ="./shapes_in_sf_all_years_cleaned", recursive = F) 
  
  for (i in sub_dirs){
    for (y in years){ 
      dir.create(file.path(i, y), showWarnings = FALSE)
    }
  }
  
  rm(list= ls())
  gc(reset = T)
  
    
  
  
  
      
#### 3. Save original data sets downloaded from IBGE in compact .rds format-----------------

# Root directory
  root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais"
  setwd(root_dir) 
  
# List shapes for all years
  all_shapes <- list.files(full.names = T, recursive = T, pattern = ".shp")

  
shp_to_sf_rds <- function(x){

  
# get corresponding year of the file
  year <- substr(x, 13, 16 )
  
  # select file
    # x <- all_shapes[all_shapes %like% 2000][3]

  
# Encoding for different years
  if (year %like% "2000"){ 
    shape <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=IBM437") 
    }
  
  if (year %like% "2001|2005|2007|2010"){
    shape <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")
    }
    
  if (year %like% "2013|2014|2015|2016|2017|2018"){
    shape <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=UTF8")
    }
      
    
  # get destination subdirectory based on abbreviation of the geography
    last15 <- function(x){substr(x, nchar(x)-15, nchar(x))}   # function to get the last 4 digits of a string
    
    if ( last15(x) %like% "UF|uf"){ dest_dir <- paste0("./shapes_in_sf_all_years_original/uf/", year)           }
    if ( last15(x) %like% "ME|me"){ dest_dir <- paste0("./shapes_in_sf_all_years_original/meso_regiao/", year)  }
    if ( last15(x) %like% "MI|mi"){ dest_dir <- paste0("./shapes_in_sf_all_years_original/micro_regiao/", year) }
    if ( last15(x) %like% "MU|mu"){ dest_dir <- paste0("./shapes_in_sf_all_years_original/municipio/", year)    }
    
  # name of the file that will be saved
    if( year %like% "2000|2001|2010|2013|2014"){ file_name <- paste0(toupper(substr(x, 21, 24)), ".rds") }
    if( year %like% "2005"){ file_name <- paste0( toupper(substr(x, 67, 70)), ".rds") }
    if( year %like% "2007"){ file_name <- paste0( toupper(substr(x, 66, 69)), ".rds") }
    if( year %like% "2015|2016|2017|2018"){ file_name <- paste0( toupper(substr(x, 25, 28)), ".rds") }
    
  # save in .rds
    write_rds(shape, path = paste0(dest_dir,"/", file_name), compress="gz" )
    }


# Apply function to save original data sets in rds format

# create computing clusters
  cl <- parallel::makeCluster(detectCores())
  
  clusterEvalQ(cl, c(library(data.table), library(readr), library(sf)))
  parallel::clusterExport(cl=cl, varlist= c("all_shapes"), envir=environment())
  
  # apply function in parallel
  parallel::parLapply(cl, all_shapes, shp_to_sf_rds)
  stopCluster(cl)
  
  rm(list= ls())
  gc(reset = T)


  


    
  
  
###### 4. Cleaning UF files -------------------------------- 
  uf_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais//shapes_in_sf_all_years_original/uf"
  sub_dirs <- list.dirs(path =uf_dir, recursive = F) 
  
  
# create a function that will clean the sf files according to particularities of the data in each year
    clean_states <- function( e ){ #  e <- sub_dirs[sub_dirs %like% 2000]
    
    # get year of the folder
    last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
    year <- last4(e)
    
    # list all sf files in that year/folder
    sf_files <- list.files(e, full.names = T)
    
    # for each file 
    for (i in sf_files){ #  i <- sf_files[2]
      
      # read sf file
      temp_sf <- read_rds(i)
      
      if (year %like% "2000|2001"){
        # dplyr::rename and subset columns
        names(temp_sf) <- names(temp_sf) %>% tolower()
        temp_sf <- dplyr::rename(temp_sf, cod_uf = geocodigo, name_uf = nome)
        temp_sf <- dplyr::select(temp_sf, c('cod_uf', 'name_uf', 'geometry'))
      }
      
      if (year %like% "2010"){
        # dplyr::rename and subset columns
        names(temp_sf) <- names(temp_sf) %>% tolower()
        temp_sf <- dplyr::rename(temp_sf, cod_uf = cd_geocodu, name_uf = nm_estado)
        temp_sf <- dplyr::select(temp_sf, c('cod_uf', 'name_uf', 'geometry'))
      }
      
      if (year %like% "2013|2014|2015|2016|2017|2018"){
        # dplyr::rename and subset columns
        names(temp_sf) <- names(temp_sf) %>% tolower()
        temp_sf <- dplyr::rename(temp_sf, cod_uf = cd_geocuf, name_uf = nm_estado)
        temp_sf <- dplyr::select(temp_sf, c('cod_uf', 'name_uf', 'geometry'))
      }
      
      
      # Use UTF-8 encoding
        temp_sf$name_uf <- stringi::stri_encode(as.character((temp_sf$name_uf), "UTF-8"))
      
      # Capitalize the first letter 
        temp_sf$name_uf <- stringr::str_to_title(temp_sf$name_uf)
      
      # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
        temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }
      
      # Save cleaned sf in the cleaned directory
      i <- gsub("original", "cleaned", i)
      write_rds(temp_sf, path = i )
      }
  }

  
    
# Apply function to save original data sets in rds format

  # create computing clusters
    cl <- parallel::makeCluster(detectCores())
    
    clusterEvalQ(cl, c(library(data.table), library(dplyr), library(readr), library(stringr), library(sf)))
    parallel::clusterExport(cl=cl, varlist= c("sub_dirs"), envir=environment())
    
    # apply function in parallel
    parallel::parLapply(cl, sub_dirs, clean_states)
    stopCluster(cl)
    
    rm(list= ls())
    gc(reset = T)
    
    
    
    
    
###### 5. Cleaning MESO files -------------------------------- 
    meso_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais//shapes_in_sf_all_years_original/meso_regiao"
    sub_dirs <- list.dirs(path =meso_dir, recursive = F) 
    
    
# create a function that will clean the sf files according to particularities of the data in each year
  clean_meso <- function( e ){ #  e <- sub_dirs[1]
      
      # get year of the folder
      last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
      year <- last4(e)
      
      # list all sf files in that year/folder
      sf_files <- list.files(e, full.names = T)
      
      # for each file 
      for (i in sf_files){ #  i <- sf_files[1]
        
        # read sf file
        temp_sf <- read_rds(i)
        
      
      if (year %like% "2000|2001"){
          # dplyr::rename and subset columns
          names(temp_sf) <- names(temp_sf) %>% tolower()
          temp_sf <- dplyr::rename(temp_sf, cod_meso = geocodigo, name_meso = nome)
          temp_sf <- dplyr::select(temp_sf, c('cod_meso', 'name_meso', 'geometry'))
        }
        
       if (year %like% "2010"){
          # dplyr::rename and subset columns
          names(temp_sf) <- names(temp_sf) %>% tolower()
          temp_sf <- dplyr::rename(temp_sf, cod_meso = cd_geocodu, name_meso = nm_meso)
          temp_sf <- dplyr::select(temp_sf, c('cod_meso', 'name_meso', 'geometry'))
       }
        
        if (year %like% "2013|2014|2015|2016|2017|2018"){
          # dplyr::rename and subset columns
          names(temp_sf) <- names(temp_sf) %>% tolower()
          temp_sf <- dplyr::rename(temp_sf, cod_meso = cd_geocme, name_meso = nm_meso)
          temp_sf <- dplyr::select(temp_sf, c('cod_meso', 'name_meso', 'geometry'))
        }
        
      # Use UTF-8 encoding
        temp_sf$name_meso <- stringi::stri_encode(as.character(temp_sf$name_meso), "UTF-8")
        
      # Capitalize the first letter 
        temp_sf$name_meso <- stringr::str_to_title(temp_sf$name_meso)
        
      # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
        temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }
        
      # Save cleaned sf in the cleaned directory
        i <- gsub("original", "cleaned", i)
        write_rds(temp_sf, path = i )
      }
    }


  
# Apply function to save original data sets in rds format

  # create computing clusters
  cl <- parallel::makeCluster(detectCores())
  
  clusterEvalQ(cl, c(library(data.table), library(dplyr), library(readr), library(stringr), library(sf)))
  parallel::clusterExport(cl=cl, varlist= c("sub_dirs"), envir=environment())
  
  # apply function in parallel
  parallel::parLapply(cl, sub_dirs, clean_meso)
  stopCluster(cl)
  
  rm(list= ls())
  gc(reset = T)
  

  
  
###### 6. Cleaning MICRO files -------------------------------- 
  micro_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais//shapes_in_sf_all_years_original/micro_regiao"
  sub_dirs <- list.dirs(path=micro_dir, recursive = F) 
  
  
# create a function that will clean the sf files according to particularities of the data in each year
  clean_micro <- function( e ){ #  e <- sub_dirs[1]
    
    # get year of the folder
    last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
    year <- last4(e)
    
    # list all sf files in that year/folder
    sf_files <- list.files(e, full.names = T)
    
    # for each file 
    for (i in sf_files){ #  i <- sf_files[1]
      
      # read sf file
      temp_sf <- read_rds(i)
      
      
      if (year %like% "2000|2001"){
        # dplyr::rename and subset columns
        names(temp_sf) <- names(temp_sf) %>% tolower()
        temp_sf <- dplyr::rename(temp_sf, cod_micro = geocodigo, name_micro = nome)
        temp_sf <- dplyr::select(temp_sf, c('cod_micro', 'name_micro', 'geometry'))
      }
      
      
      if (year %like% "2010"){
        # dplyr::rename and subset columns
        names(temp_sf) <- names(temp_sf) %>% tolower()
        temp_sf <- dplyr::rename(temp_sf, cod_micro = cd_geocodu, name_micro = nm_micro)
        temp_sf <- dplyr::select(temp_sf, c('cod_micro', 'name_micro', 'geometry'))
      }
      
      
      if (year %like% "2013|2014|2015|2016|2017|2018"){
        # dplyr::rename and subset columns
        names(temp_sf) <- names(temp_sf) %>% tolower()
        temp_sf <- dplyr::rename(temp_sf, cod_micro = cd_geocmi, name_micro = nm_micro)
        temp_sf <- dplyr::select(temp_sf, c('cod_micro', 'name_micro', 'geometry'))
      }
      
    # Use UTF-8 encoding
      temp_sf$name_micro <- stringi::stri_encode(as.character(temp_sf$name_micro), "UTF-8")
      
    # Capitalize the first letter 
      temp_sf$name_micro <- stringr::str_to_title(temp_sf$name_micro)
      
    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
      temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }
      
      # Save cleaned sf in the cleaned directory
      i <- gsub("original", "cleaned", i)
      write_rds(temp_sf, path = i )
    }
  }
  

# Apply function to save original data sets in rds format
  
  # create computing clusters
  cl <- parallel::makeCluster(detectCores())
  
  clusterEvalQ(cl, c(library(data.table), library(dplyr), library(readr), library(stringr), library(sf)))
  parallel::clusterExport(cl=cl, varlist= c("sub_dirs"), envir=environment())
  
  # apply function in parallel
  parallel::parLapply(cl, sub_dirs, clean_micro)
  stopCluster(cl)
  
  rm(list= ls())
  gc(reset = T)
  
  
  
###### 7. Cleaning MUNI files -------------------------------- 
  muni_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais//shapes_in_sf_all_years_original/municipio"
  sub_dirs <- list.dirs(path=muni_dir, recursive = F) 
  
  
  # create a function that will clean the sf files according to particularities of the data in each year
  clean_muni <- function( e ){ #  e <- sub_dirs[sub_dirs %like% 2001]
    
    # get year of the folder
    last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
    year <- last4(e)
    
    # list all sf files in that year/folder
    sf_files <- list.files(e, full.names = T)
    
    # for each file 
    for (i in sf_files){ #  i <- sf_files[2]
      
      # read sf file
      temp_sf <- read_rds(i)
      
      
      if (year %like% "2000|2001"){
        # dplyr::rename and subset columns
        names(temp_sf) <- names(temp_sf) %>% tolower()
        temp_sf <- dplyr::rename(temp_sf, cod_muni = geocodigo, name_muni = nome )
        temp_sf <- dplyr::select(temp_sf, c('cod_muni', 'name_muni', 'geometry')) # 'latitudese', 'longitudes' da sede do municipio
        #names(temp_sf)[3:4] <- c("lat","long")
      }
      
      
      if (year %like% "2005"){
        # dplyr::rename and subset columns
        names(temp_sf) <- names(temp_sf) %>% tolower()
        temp_sf <- dplyr::rename(temp_sf, cod_muni = geocodigo, name_muni = nome )
        temp_sf <- dplyr::select(temp_sf, c('cod_muni', 'name_muni', 'latitude', 'longitude', 'geometry'))
        names(temp_sf)[3:4] <- c("lat","long")
        }
      
      
      if (year %like% "2007"){
        # dplyr::rename and subset columns
        names(temp_sf) <- names(temp_sf) %>% tolower()
        temp_sf <- dplyr::rename(temp_sf, cod_muni = geocodig_m, name_muni = nome_munic )
        temp_sf <- dplyr::select(temp_sf, c('cod_muni', 'name_muni', 'geometry'))
      }
      
      if (year %like% "2010"){
        # dplyr::rename and subset columns
        names(temp_sf) <- names(temp_sf) %>% tolower()
        temp_sf <- dplyr::rename(temp_sf, cod_muni = cd_geocodm, name_muni = nm_municip)
        temp_sf <- dplyr::select(temp_sf, c('cod_muni', 'name_muni', 'geometry'))
      }
      
      if (year %like% "2013|2014|2015|2016|2017|2018"){
        # dplyr::rename and subset columns
        names(temp_sf) <- names(temp_sf) %>% tolower()
        temp_sf <- dplyr::rename(temp_sf, cod_muni = cd_geocmu , name_muni = nm_municip)
        temp_sf <- dplyr::select(temp_sf, c('cod_muni', 'name_muni', 'geometry'))
      }
      
      # Manual test
      # y <- 2018
      # # sf_files <- list.files(sub_dirs, full.names = T)
      # temp_sf <- sf_files[sf_files %like% y][1] %>% read_rds()
      # as.data.frame(temp_sf) %>% head()
      # 
      # names(temp_sf) %>% tolower()  %in% "cd_geocmu" %>% sum()
      # names(temp_sf) %>% tolower()  %in% "nm_municip" %>% sum()
      
      
      # Use UTF-8 encoding
      temp_sf$name_muni <- stringi::stri_encode(as.character(temp_sf$name_muni), "UTF-8")
      
      # Capitalize the first letter 
      temp_sf$name_muni <- stringr::str_to_title(temp_sf$name_muni)
      
      # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
      temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }
      
      # Save cleaned sf in the cleaned directory
      i <- gsub("original", "cleaned", i)
      write_rds(temp_sf, path = i )
    }
  }
  
  
# Apply function to save original data sets in rds format
  
  # create computing clusters
  cl <- parallel::makeCluster(detectCores())
  
  clusterEvalQ(cl, c(library(data.table), library(dplyr), library(readr), library(stringr), library(sf)))
  parallel::clusterExport(cl=cl, varlist= c("sub_dirs"), envir=environment())
  
  # apply function in parallel
  parallel::parLapply(cl, sub_dirs, clean_muni)
  stopCluster(cl)
  
  rm(list= ls())
  gc(reset = T)
  
  
  
# DO NOT run
## remove all unzipped shape files
#   # list all unzipped shapes
#     f <- list.files(path = root_dir, full.names = T, recursive = T, pattern = ".shx|.shp|.prj|.dbf|.cpg")
#     file.remove(f)

  
  
###### 8. Correcting number of digits of meso 2010  -------------------------------- 
  
  # issue #20
  
  
  
  
  
  
