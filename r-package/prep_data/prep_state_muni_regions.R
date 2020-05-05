library(RCurl)
#library(tidyverse)
library(stringr)
library(sf)
library(janitor)
library(dplyr)
library(readr)
library(parallel)
library(data.table)
library(xlsx)
library(magrittr)
library(devtools)
library(lwgeom)
library(stringi)
library(geobr)




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

# rm(list= ls())
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

# rm(list= ls())
gc(reset = T)






#### 3. Save original data sets downloaded from IBGE in compact .rds format-----------------

# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais"
setwd(root_dir)

# List shapes for all years
all_shapes <- list.files(full.names = T, recursive = T, pattern = ".shp$")


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

# rm(list= ls())
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
      temp_sf <- dplyr::rename(temp_sf, code_state = geocodigo, name_state = nome)
      temp_sf <- dplyr::select(temp_sf, c('code_state', 'name_state', 'geometry'))
    }

    if (year %like% "2010"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_state = cd_geocodu, name_state = nm_estado)
      temp_sf <- dplyr::select(temp_sf, c('code_state', 'name_state', 'geometry'))
    }

    if (year %like% "2013|2014|2015|2016|2017|2018"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_state = cd_geocuf, name_state = nm_estado)
      temp_sf <- dplyr::select(temp_sf, c('code_state', 'name_state', 'geometry'))
    }

    # add State abbreviation
    temp_sf <- temp_sf %>% mutate(abbrev_state =  ifelse(code_state== 11, "RO",
                                                         ifelse(code_state== 12, "AC",
                                                                ifelse(code_state== 13, "AM",
                                                                       ifelse(code_state== 14, "RR",
                                                                              ifelse(code_state== 15, "PA",
                                                                                     ifelse(code_state== 16, "AP",
                                                                                            ifelse(code_state== 17, "TO",
                                                                                                   ifelse(code_state== 21, "MA",
                                                                                                          ifelse(code_state== 22, "PI",
                                                                                                                 ifelse(code_state== 23, "CE",
                                                                                                                        ifelse(code_state== 24, "RN",
                                                                                                                               ifelse(code_state== 25, "PB",
                                                                                                                                      ifelse(code_state== 26, "PE",
                                                                                                                                             ifelse(code_state== 27, "AL",
                                                                                                                                                    ifelse(code_state== 28, "SE",
                                                                                                                                                           ifelse(code_state== 29, "BA",
                                                                                                                                                                  ifelse(code_state== 31, "MG",
                                                                                                                                                                         ifelse(code_state== 32, "ES",
                                                                                                                                                                                ifelse(code_state== 33, "RJ",
                                                                                                                                                                                       ifelse(code_state== 35, "SP",
                                                                                                                                                                                              ifelse(code_state== 41, "PR",
                                                                                                                                                                                                     ifelse(code_state== 42, "SC",
                                                                                                                                                                                                            ifelse(code_state== 43, "RS",
                                                                                                                                                                                                                   ifelse(code_state== 50, "MS",
                                                                                                                                                                                                                          ifelse(code_state== 51, "MT",
                                                                                                                                                                                                                                 ifelse(code_state== 52, "GO",
                                                                                                                                                                                                                                        ifelse(code_state== 53, "DF",NA))))))))))))))))))))))))))))

    # Add Region codes and names
    temp_sf$code_region <- substr(temp_sf$code_state, 1,1) %>% as.numeric()
    temp_sf <- temp_sf %>% dplyr::mutate(name_region = ifelse(code_region==1, 'Norte',
                                                              ifelse(code_region==2, 'Nordeste',
                                                                     ifelse(code_region==3, 'Sudeste',
                                                                            ifelse(code_region==4, 'Sul',
                                                                                   ifelse(code_region==5, 'Centro Oeste', NA))))))
    # reorder columns
    temp_sf <- dplyr::select(temp_sf, 'code_state', 'abbrev_state', 'name_state', 'code_region', 'name_region', 'geometry')

    # Use UTF-8 encoding
    temp_sf$name_state <- stringi::stri_encode(as.character((temp_sf$name_state), "UTF-8"))

    # Capitalize the first letter
    temp_sf$name_state <- stringr::str_to_title(temp_sf$name_state)

    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
    temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }

    # Convert columns from factors to characters
    temp_sf %>% dplyr::mutate_if(is.factor, as.character) -> temp_sf

    # Make any invalid geometry valid # st_is_valid( sf)
    temp_sf <- lwgeom::st_make_valid(temp_sf)

    # keep code as.numeric()
    temp_sf$code_state <- as.numeric(temp_sf$code_state)

    # simplify
    temp_sf_simplified <- st_transform(temp_sf, crs=3857) %>% sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)

    # Save cleaned sf in the cleaned directory
    i <- gsub("original", "cleaned", i)
    # write_rds(temp_sf, path = i, compress="gz" )

    i <- gsub(".rds", ".gpkg", i)

    sf::st_write(temp_sf, i )

    i <- gsub(".gpkg", "_simplified.gpkg", i)

    sf::st_write(temp_sf_simplified, i )

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

# rm(list= ls())
gc(reset = T)

# #####fixing state repetition---------
#
#
# # Root directory
# root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais"
# setwd(root_dir)
#
#
# # create directory to save cleaned shape files in sf format
# # dir.create(file.path("./shapes_in_sf_all_years_cleaned/country"), showWarnings = T)
#
#
# # List years for which we have data
# dirs <- list.dirs("./shapes_in_sf_all_years_cleaned/uf")[-1]
# years <- stringi::stri_sub(dirs,-4,-1)
#
# hist_dirs <- list.dirs("../historical_state_muni_1872_1991/shapes_in_sf_all_years_cleaned/uf")[-1]
# hist_years <- stringi::stri_sub(hist_dirs,-4,-1)
#
# # all years
# years <- c(years, hist_years) %>% sort()
# years <- years[!(years %in% c("aned","inal"))]
# years <- years[!(years %in% c(2005, 2007))]
#
#
# # count <-0
# # coutlist<-NULL
# # for (y in years) {
# #   sf_states <- read_state(year= y , code_state = "all",simplified = FALSE)
# #
# #   vars<-names(sf_states)[-length(names(sf_states))]
# #
# #   sf_states <- sf_states %>% group_by_at(vars) %>%  summarise()
# #   if(nrow(sf_states)>27){
# #     count <- count + 1
# #     coutlist<-c(coutlist,y)
# #   }
# # }
#
# for (y in years) { #y<- 2000
#   sf_states <- read_state(year= y , code_state = "all",simplified = FALSE)
#
#   if (y==2001) {
#     sf_states <- sf_states %>% mutate(name_state=ifelse(name_state=="Espirito Santo","Espírito Santo",as.character(name_state) ))
#   }
#
#   if (y==2000) {
#     sf_states <- sf_states %>% filter(!name_state=="0")
#   }
#
#
#   vars<-names(sf_states)[-length(names(sf_states))]
#
#   sf_states <- sf_states %>% group_by_at(vars) %>%  summarise()
#
#
#   original_crs <- st_crs(sf_states)
#
#   if (y<2000) {
#     temp_sf_simplified <- st_transform(sf_states, crs=3857) %>% sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)
#
#     dest_dir <- paste0("./shapes_in_sf_all_years_cleaned/state/",y)
#     dir.create(dest_dir, showWarnings = FALSE)
#
#     # g) save as an sf file
#     # readr::write_rds(outerBounds, path = paste0(dest_dir,"/state_",y,".rds"), compress="gz" )
#
#     sf::st_write(sf_states, paste0(dest_dir,"/states_",y,".gpkg"),append = FALSE,delete_dsn =T,delete_layer=T )
#
#     sf::st_write(temp_sf_simplified, paste0(dest_dir,"/states_",y,"_simplified.gpkg"),append = FALSE,delete_dsn =T,delete_layer=T )
#
#   }else{
#
#     for (cd in as.character(sf_states$code_state) ) {
#       sf_states_uf <- sf_states %>% filter(code_state == cd)
#
#       temp_sf_simplified <- st_transform(sf_states_uf, crs=3857) %>% sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)
#
#       dest_dir <- paste0("./shapes_in_sf_all_years_cleaned/state/",y)
#       dir.create(dest_dir, showWarnings = FALSE)
#
#       # g) save as an sf file
#       # readr::write_rds(outerBounds, path = paste0(dest_dir,"/state_",y,".rds"), compress="gz" )
#
#       sf::st_write(sf_states_uf, paste0(dest_dir,"/",cd,"UF",".gpkg"),append = FALSE,delete_dsn =T,delete_layer=T )
#
#       sf::st_write(temp_sf_simplified, paste0(dest_dir,"/",cd,"UF","_simplified.gpkg"),append = FALSE,delete_dsn =T,delete_layer=T )
#
#     }
#
#   }
#
# }
#


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
      temp_sf <- dplyr::rename(temp_sf, code_meso = geocodigo, name_meso = nome)
      temp_sf <- dplyr::select(temp_sf, c('code_meso', 'name_meso', 'geometry'))
    }

    if (year %like% "2010"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_meso = cd_geocodu, name_meso = nm_meso)
      temp_sf <- dplyr::select(temp_sf, c('code_meso', 'name_meso', 'geometry'))
    }

    if (year %like% "2013|2014|2015|2016|2017|2018"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_meso = cd_geocme, name_meso = nm_meso)
      temp_sf <- dplyr::select(temp_sf, c('code_meso', 'name_meso', 'geometry'))
    }

    # Use UTF-8 encoding
    temp_sf$name_meso <- stringi::stri_encode(as.character(temp_sf$name_meso), "UTF-8")

    # Capitalize the first letter
    temp_sf$name_meso <- stringr::str_to_title(temp_sf$name_meso)

    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
    temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }

    # Convert columns from factors to characters
    temp_sf %>% dplyr::mutate_if(is.factor, as.character) -> temp_sf

    # Make an invalid geometry valid # st_is_valid( sf)
    temp_sf <- lwgeom::st_make_valid(temp_sf)

    # keep code as.numeric()
    temp_sf$code_meso <- as.numeric(temp_sf$code_meso)

    # simplify
    temp_sf_simplified <- st_transform(temp_sf, crs=3857) %>% sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)

    # Save cleaned sf in the cleaned directory
    i <- gsub("original", "cleaned", i)
    # write_rds(temp_sf, path = i, compress="gz" )

    i <- gsub(".rds", ".gpkg", i)

    sf::st_write(temp_sf, i )

    i <- gsub(".gpkg", "_simplified.gpkg", i)

    sf::st_write(temp_sf_simplified, i )
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

# rm(list= ls())
gc(reset = T)




###### 6. Cleaning MICRO files --------------------------------
micro_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais//shapes_in_sf_all_years_original/micro_regiao"
sub_dirs <- list.dirs(path=micro_dir, recursive = F)


# create a function that will clean the sf files according to particularities of the data in each year0
# clean_micro <- function( e ){ #  e <- sub_dirs[5]
for( e in sub_dirs ){
  options(encoding = "UTF-8")

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
      temp_sf <- dplyr::rename(temp_sf, code_micro = geocodigo, name_micro = nome)
      temp_sf <- dplyr::select(temp_sf, c('code_micro', 'name_micro', 'geometry'))
    }


    if (year %like% "2010"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_micro = cd_geocodu, name_micro = nm_micro)
      temp_sf <- dplyr::select(temp_sf, c('code_micro', 'name_micro', 'geometry'))
      temp_sf <- temp_sf %>%  dplyr::mutate(name_micro = ifelse(name_micro == "Moji Das Cruzes","Mogi Das Cruzes",
                                                   ifelse(name_micro == "Piraçununga","Pirassununga",
                                                          ifelse(name_micro == "Moji-Mirim","Moji Mirim",
                                                                 ifelse(name_micro == "São Miguel D'oeste","	São Miguel Do Oeste",
                                                                        ifelse(name_micro == "Serras Do Sudeste","Serras De Sudeste",
                                                                               ifelse(name_micro == "Vão do Paraná","Vão do Paranã",name_micro)))))))
    }

    if (year %like% "2013|2014|2015|2016|2017|2018"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_micro = cd_geocmi, name_micro = nm_micro)
      temp_sf <- dplyr::select(temp_sf, c('code_micro', 'name_micro', 'geometry'))
    }

    # Use UTF-8 encoding
    temp_sf$name_micro <- stringi::stri_encode(as.character(temp_sf$name_micro), "UTF-8")

    # Capitalize the first letter
    temp_sf$name_micro <- stringr::str_to_title(temp_sf$name_micro)

    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
    temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }

    # Convert columns from factors to characters
    temp_sf %>% dplyr::mutate_if(is.factor, as.character) -> temp_sf

    # Make an invalid geometry valid # st_is_valid( sf)
    temp_sf <- lwgeom::st_make_valid(temp_sf)

    # keep code as.numeric()
    temp_sf$code_micro <- as.numeric(temp_sf$code_micro)

    # simplify
    temp_sf_simplified <- st_transform(temp_sf, crs=3857) %>% sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)

    # Save cleaned sf in the cleaned directory
    i <- gsub("original", "cleaned", i)
    # write_rds(temp_sf, path = i, compress="gz" )

    i <- gsub(".rds", ".gpkg", i)

    sf::st_write(temp_sf, i,append = FALSE,delete_dsn =T,delete_layer=T )

    i <- gsub(".gpkg", "_simplified.gpkg", i)

    sf::st_write(temp_sf_simplified, i ,append = FALSE,delete_dsn =T,delete_layer=T)
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

# rm(list= ls())
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
      temp_sf <- dplyr::rename(temp_sf, code_muni = geocodigo, name_muni = nome )
      temp_sf <- dplyr::select(temp_sf, c('code_muni', 'name_muni', 'geometry')) # 'latitudese', 'longitudes' da sede do municipio
      #names(temp_sf)[3:4] <- c("lat","long")
    }


    if (year %like% "2005"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_muni = geocodigo, name_muni = nome )
      temp_sf <- dplyr::select(temp_sf, c('code_muni', 'name_muni', 'latitude', 'longitude', 'geometry'))
      names(temp_sf)[3:4] <- c("lat","long")
    }


    if (year %like% "2007"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_muni = geocodig_m, name_muni = nome_munic )
      temp_sf <- dplyr::select(temp_sf, c('code_muni', 'name_muni', 'geometry'))
    }

    if (year %like% "2010"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_muni = cd_geocodm, name_muni = nm_municip)
      temp_sf <- dplyr::select(temp_sf, c('code_muni', 'name_muni', 'geometry'))
    }

    if (year %like% "2013|2014|2015|2016|2017|2018"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_muni = cd_geocmu , name_muni = nm_municip)
      temp_sf <- dplyr::select(temp_sf, c('code_muni', 'name_muni', 'geometry'))
    }

    # Manual test
    # y <- 2018
    # # sf_files <- list.files(sub_dirs, full.names = T)
    # temp_sf <- sf_files[sf_files %like% y][1] %>% read_rds()
    # as.data.frame(temp_sf) %>% head()
    #
    # names(temp_sf) %>% tolower()  %in% "cd_geocmu" %>% sum()
    # names(temp_sf) %>% tolower()  %in% "nm_municip" %>% sum()

    if ( any(st_is_valid(temp_sf))==FALSE ) {
      temp_sf <- st_make_valid(temp_sf)
    }

    if (i == "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais//shapes_in_sf_all_years_original/municipio/2000/42MU.rds") {
      temp_sf <- temp_sf[-c(278),]
    }

    # add State code and name
    temp_sf$code_state <- substr(temp_sf$code_muni, 1, 2)
    temp_sf <- temp_sf %>% mutate(abbrev_state = ifelse(code_state== 11, "RO",
                                                        ifelse(code_state== 12, "AC",
                                                               ifelse(code_state== 13, "AM",
                                                                      ifelse(code_state== 14, "RR",
                                                                             ifelse(code_state== 15, "PA",
                                                                                    ifelse(code_state== 16, "AP",
                                                                                           ifelse(code_state== 17, "TO",
                                                                                                  ifelse(code_state== 21, "MA",
                                                                                                         ifelse(code_state== 22, "PI",
                                                                                                                ifelse(code_state== 23, "CE",
                                                                                                                       ifelse(code_state== 24, "RN",
                                                                                                                              ifelse(code_state== 25, "PB",
                                                                                                                                     ifelse(code_state== 26, "PE",
                                                                                                                                            ifelse(code_state== 27, "AL",
                                                                                                                                                   ifelse(code_state== 28, "SE",
                                                                                                                                                          ifelse(code_state== 29, "BA",
                                                                                                                                                                 ifelse(code_state== 31, "MG",
                                                                                                                                                                        ifelse(code_state== 32, "ES",
                                                                                                                                                                               ifelse(code_state== 33, "RJ",
                                                                                                                                                                                      ifelse(code_state== 35, "SP",
                                                                                                                                                                                             ifelse(code_state== 41, "PR",
                                                                                                                                                                                                    ifelse(code_state== 42, "SC",
                                                                                                                                                                                                           ifelse(code_state== 43, "RS",
                                                                                                                                                                                                                  ifelse(code_state== 50, "MS",
                                                                                                                                                                                                                         ifelse(code_state== 51, "MT",
                                                                                                                                                                                                                                ifelse(code_state== 52, "GO",
                                                                                                                                                                                                                                       ifelse(code_state== 53, "DF",NA))))))))))))))))))))))))))))

    # reorder columns
    temp_sf <- dplyr::select(temp_sf, 'code_muni', 'name_muni', 'code_state', 'abbrev_state', 'geometry')


    temp_sf <-  temp_sf %>% group_by(code_muni,name_muni,code_state, abbrev_state) %>% summarise() %>% ungroup()

    # Use UTF-8 encoding
    temp_sf$name_muni <- stringi::stri_encode(as.character(temp_sf$name_muni), "UTF-8")

    # Capitalize the first letter
    temp_sf$name_muni <- stringr::str_to_title(temp_sf$name_muni)

    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
    temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }

    # Convert columns from factors to characters
    temp_sf %>% dplyr::mutate_if(is.factor, as.character) -> temp_sf

    # keep code as.numeric()
    temp_sf$code_muni <- as.numeric(temp_sf$code_muni)

    # Make an invalid geometry valid # st_is_valid( sf)
    temp_sf <- lwgeom::st_make_valid(temp_sf)

    # simplify
    temp_sf_simplified <- st_transform(temp_sf, crs=3857) %>% sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)

    # Save cleaned sf in the cleaned directory
    i <- gsub("original", "cleaned", i)
    # write_rds(temp_sf, path = i, compress="gz" )

    i <- gsub(".rds", ".gpkg", i)

    sf::st_write(temp_sf, i )

    i <- gsub(".gpkg", "_simplified.gpkg", i)

    sf::st_write(temp_sf_simplified, i )
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

# rm(list= ls())
gc(reset = T)

#####fixing municipality repetition---------


# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais"
setwd(root_dir)


# create directory to save cleaned shape files in sf format
# dir.create(file.path("./shapes_in_sf_all_years_cleaned/country"), showWarnings = T)


# List years for which we have data
dirs <- list.dirs("./shapes_in_sf_all_years_cleaned/uf")[-1]
years <- stringi::stri_sub(dirs,-4,-1)

hist_dirs <- list.dirs("../historical_state_muni_1872_1991/shapes_in_sf_all_years_cleaned/uf")[-1]
hist_years <- stringi::stri_sub(hist_dirs,-4,-1)

# all years
years <- c(years, hist_years) %>% sort()
years <- years[!(years %in% c("aned","inal"))]
years <- years[!(years %in% c(2005, 2007))]


# count <-0
# coutlist<-NULL
# for (y in years) {
#   sf_states <- read_state(year= y , code_state = "all",simplified = FALSE)
#
#   vars<-names(sf_states)[-length(names(sf_states))]
#
#   sf_states <- sf_states %>% group_by_at(vars) %>%  summarise()
#   if(nrow(sf_states)>27){
#     count <- count + 1
#     coutlist<-c(coutlist,y)
#   }
# }

  for (y in years) { #y<- 2000
    sf_states <- read_municipality(year= y , code_muni = "all",simplified = FALSE)

    if (y==1991) {
      sf_states[4585,1] <- 3304557
      sf_states[4585,2] <- "Rio de Janeiro"
      sf_states[4586,1] <- 3304557
      sf_states[4586,2] <- "Rio de Janeiro"
      sf_states <- sf_states %>% filter(!code_muni==0)
      sf_states <- sf_states %>% filter(!is.na(name_muni))

      }


    if (y==2000) {
      sf_states <- sf_states %>% filter(!name_muni=="0")
    }


    vars<-names(sf_states)[-length(names(sf_states))]

    sf_states <- sf_states %>% group_by_at(vars) %>%  summarise()


    original_crs <- st_crs(sf_states)

  if (y<2000) {
  temp_sf_simplified <- st_transform(sf_states, crs=3857) %>% sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)

  dest_dir <- paste0("./shapes_in_sf_all_years_cleaned/municipio/",y)
  dir.create(dest_dir, showWarnings = FALSE)

  # g) save as an sf file
  # readr::write_rds(outerBounds, path = paste0(dest_dir,"/state_",y,".rds"), compress="gz" )

  sf::st_write(sf_states, paste0(dest_dir,"/municipios_",y,".gpkg"),append = FALSE,delete_dsn =T,delete_layer=T )

  sf::st_write(temp_sf_simplified, paste0(dest_dir,"/municipios_",y,"_simplified.gpkg"),append = FALSE,delete_dsn =T,delete_layer=T )

  }else{

  for (cd in unique(as.character(sf_states$code_state) ) ) {
    sf_states_uf <- sf_states %>% filter(code_state == cd)

    temp_sf_simplified <- st_transform(sf_states_uf, crs=3857) %>% sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)

    dest_dir <- paste0("./shapes_in_sf_all_years_cleaned/municipio/",y)
    dir.create(dest_dir, showWarnings = FALSE)

    # g) save as an sf file
    # readr::write_rds(outerBounds, path = paste0(dest_dir,"/state_",y,".rds"), compress="gz" )

    sf::st_write(sf_states_uf, paste0(dest_dir,"/",cd,"MU",".gpkg"),append = FALSE,delete_dsn =T,delete_layer=T )

    sf::st_write(temp_sf_simplified, paste0(dest_dir,"/",cd,"MU","_simplified.gpkg"),append = FALSE,delete_dsn =T,delete_layer=T )

  }

}

  }


# DO NOT run
## remove all unzipped shape files
#   # list all unzipped shapes
#     f <- list.files(path = root_dir, full.names = T, recursive = T, pattern = ".shx|.shp|.prj|.dbf|.cpg")
#     file.remove(f)



###### 8. Correcting number of digits of meso an micro regions in 2010  --------------------------------
# issue #20


#### 8.1 Meso regions

# Dirs
meso_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais//shapes_in_sf_all_years_cleaned/meso_regiao"
sub_dirs <- list.dirs(path =meso_dir, recursive = F)

# dirs of 2010 (problematic data) ad 2013 (reference data)
sub_dir_2010 <- sub_dirs[sub_dirs %like% 2010]
sub_dir_2013 <- sub_dirs[sub_dirs %like% 2013]


# list sf files in each dir
sf_files_2010 <- list.files(sub_dir_2010, full.names = T, pattern = ".gpkg")
sf_files_2013 <- list.files(sub_dir_2013, full.names = T, pattern = ".gpkg")


# Create function to correct number of digits of meso regions in 2010

# use data of 2013 to add code and name of meso regions in the 2010 data
correct_meso_digits <- function(a2010_sf_meso_file){ # a2010_sf_meso_file <- sf_files_2010[5]

  # Get UF of the file
  get_uf <- function(x){if (grepl("simplified",x)) {
    substr(x, nchar(x)-19, nchar(x)-18)
  } else {substr(x, nchar(x)-8, nchar(x)-7)}
  }
  uf <- get_uf(a2010_sf_meso_file)



  # read 2010 file
  temp2010 <- st_read(a2010_sf_meso_file)

  # read 2013 file


  temp2013 <- sf_files_2013[ if (grepl("simplified",a2010_sf_meso_file)) {
    (sf_files_2013 %like% paste0("/",uf)) & (sf_files_2013 %like% "simplified")
  } else {
    (sf_files_2013 %like% paste0("/",uf)) & !(sf_files_2013 %like% "simplified")
  }]
  temp2013 <- st_read(temp2013)

  # keep only code and name columns
  table2013 <- temp2013 %>% as.data.frame()
  table2013 <- dplyr::select(table2013, code_meso, name_meso)

  # update code_meso
  sf2010 <- left_join(temp2010, table2013, by="name_meso")
  sf2010 <- dplyr::select(sf2010, code_meso=code_meso.y, name_meso, geom)

  # Save file
  st_write(sf2010,a2010_sf_meso_file,append = FALSE,delete_dsn =T,delete_layer=T)
}

# Apply function
lapply(sf_files_2010, correct_meso_digits)



#### 8.2 Micro regions
# use data of 2013 to add code and name of micro regions in the 2010 data

# Dirs
micro_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais//shapes_in_sf_all_years_cleaned/micro_regiao"
sub_dirs <- list.dirs(path =micro_dir, recursive = F)

# dirs of 2010 (problematic data) ad 2013 (reference data)
sub_dir_2010 <- sub_dirs[sub_dirs %like% 2010]
sub_dir_2013 <- sub_dirs[sub_dirs %like% 2013]


# list sf files in each dir
sf_files_2010 <- list.files(sub_dir_2010, full.names = T, pattern = ".gpkg")
sf_files_2013 <- list.files(sub_dir_2013, full.names = T, pattern = ".gpkg")


# Create function to correct number of digits of meso regions in 2010, based on 2013 data

correct_micro_digits <- function(a2010_sf_micro_file){ # a2010_sf_micro_file <- sf_files_2010[1]

  # Get UF of the file
  get_uf <- function(x){if (grepl("simplified",x)) {
    substr(x, nchar(x)-19, nchar(x)-18)
  } else {substr(x, nchar(x)-8, nchar(x)-7)}
  }
  uf <- get_uf(a2010_sf_micro_file)

  # read 2010 file
  temp2010 <- st_read(a2010_sf_micro_file)

  # read 2013 file
  temp2013 <- sf_files_2013[if (grepl("simplified",a2010_sf_micro_file)) {
    (sf_files_2013 %like% paste0("/",uf)) & (sf_files_2013 %like% "simplified")
  } else {
    (sf_files_2013 %like% paste0("/",uf)) & !(sf_files_2013 %like% "simplified")
  }]
  temp2013 <- st_read(temp2013)

  # keep only code and name columns
  table2013 <- temp2013 %>% as.data.frame()
  table2013 <- dplyr::select(table2013, code_micro, name_micro)

  # update code_micro
  sf2010 <- left_join(temp2010, table2013, by="name_micro")
  sf2010 <- dplyr::select(sf2010, code_micro=code_micro.y, name_micro, geom)

  # Save file
  # write_rds(sf2010, path = a2010_sf_micro_file, compress="gz" )
  st_write(sf2010,a2010_sf_micro_file,append = FALSE,delete_dsn =T,delete_layer=T)
}

# Apply function
lapply(sf_files_2010, correct_micro_digits)











###### 9. Creating base 2010 file  --------------------------------

# Read correspondence table from the Census 2019
table_2010 <- xlsx::read.xlsx2(file="L:/# DIRUR #/ASMEQ/geobr/data-raw/Divisao_Territorial_do_Brasil/Unidades da Federacao, Mesorregioes, microrregioes e municipios 2010.xls",
                               sheetIndex = 1, startRow = 3, stringsAsFactors=F)


# Remove accents from colnames
names(table_2010) <- stringi::stri_trans_general(str = names(table_2010), id = "Latin-ASCII")


# change col names according to convetions ingeobr package
table_2010 <- dplyr::select(table_2010
                            , code_muni = 'Municipio'
                            , name_muni = 'Nome_Municipio'
                            , code_micro = 'Micror.regiao'
                            , name_micro = 'Nome_Microrregiao'
                            , code_meso = 'Mesor.regiao'
                            , name_meso = 'Nome_Mesorregiao'
                            , code_state = 'UF'
                            , name_state = 'Nome_UF'
)


# Add State abbreviations
setDT(table_2010)
table_2010[ code_state== 11, abbrev_state :=	"RO" ]
table_2010[ code_state== 12, abbrev_state :=	"AC" ]
table_2010[ code_state== 13, abbrev_state :=	"AM" ]
table_2010[ code_state== 14, abbrev_state :=	"RR" ]
table_2010[ code_state== 15, abbrev_state :=	"PA" ]
table_2010[ code_state== 16, abbrev_state :=	"AP" ]
table_2010[ code_state== 17, abbrev_state :=	"TO" ]
table_2010[ code_state== 21, abbrev_state :=	"MA" ]
table_2010[ code_state== 22, abbrev_state :=	"PI" ]
table_2010[ code_state== 23, abbrev_state :=	"CE" ]
table_2010[ code_state== 24, abbrev_state :=	"RN" ]
table_2010[ code_state== 25, abbrev_state :=	"PB" ]
table_2010[ code_state== 26, abbrev_state :=	"PE" ]
table_2010[ code_state== 27, abbrev_state :=	"AL" ]
table_2010[ code_state== 28, abbrev_state :=	"SE" ]
table_2010[ code_state== 29, abbrev_state :=	"BA" ]
table_2010[ code_state== 31, abbrev_state :=	"MG" ]
table_2010[ code_state== 32, abbrev_state :=	"ES" ]
table_2010[ code_state== 33, abbrev_state :=	"RJ" ]
table_2010[ code_state== 35, abbrev_state :=	"SP" ]
table_2010[ code_state== 41, abbrev_state :=	"PR" ]
table_2010[ code_state== 42, abbrev_state :=	"SC" ]
table_2010[ code_state== 43, abbrev_state :=	"RS" ]
table_2010[ code_state== 50, abbrev_state :=	"MS" ]
table_2010[ code_state== 51, abbrev_state :=	"MT" ]
table_2010[ code_state== 52, abbrev_state :=	"GO" ]
table_2010[ code_state== 53, abbrev_state :=	"DF" ]




# Add Region codes and names
table_2010$code_region <- substr(table_2010$code_state, 1,1)
table_2010 <- table_2010 %>% mutate(name_region = ifelse(code_region==1, 'Norte',
                                                         ifelse(code_region==2, 'Nordeste',
                                                                ifelse(code_region==3, 'Sudeste',
                                                                       ifelse(code_region==4, 'Sul',
                                                                              ifelse(code_region==5, 'Centro Oeste', NA))))))



# Convert code columns to numeric
table_2010$code_region <- as.numeric(table_2010$code_region)
table_2010$code_state <- as.numeric(table_2010$code_state)
table_2010$code_meso <- as.numeric(table_2010$code_meso)
table_2010$code_micro <- as.numeric(table_2010$code_micro)
table_2010$code_muni <- as.numeric(table_2010$code_muni)




### Add geometry

# read clean muni data of 2010
muni_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais//shapes_in_sf_all_years_cleaned/municipio"
muni_files <- list.files(muni_dir, full.names = T, recursive = T, pattern = ".gpkg")

# All muni 2010 files
muni_files_2010 <- muni_files[muni_files %like% 2010]

muni_files_2010_full <- muni_files_2010[!(muni_files_2010 %like% "simplified")]

# All muni 2010 files simplified
muni_files_2010_sp <- muni_files_2010[(muni_files_2010 %like% "simplified")]


# Read all
sf_2010_full <- lapply(X=muni_files_2010_full, FUN= st_read)
sf_2010_full <- do.call('rbind', sf_2010_full)

# Read all simplified
sf_2010_sp <- lapply(X=muni_files_2010_sp, FUN= st_read)
sf_2010_sp <- do.call('rbind', sf_2010_sp)


# Add geometry
# brazil_2010 <- dplyr::left_join(sf_2010, table_2010, by='code_muni')
brazil_2010_full <- dplyr::left_join(sf_2010_full, table_2010, by='code_muni')


# fix names
brazil_2010_full$name_muni.x <- NULL
brazil_2010_full <- dplyr::rename(brazil_2010_full, name_muni = 'name_muni.y')
head(brazil_2010_full)

del_name <- grep(".x$",names(brazil_2010_full), value = T)
keep_name <- grep(".y$",names(brazil_2010_full), value = T)

brazil_2010_full <- brazil_2010_full %>% select(-del_name)
setnames(brazil_2010_full,keep_name,substr(keep_name,0,nchar(keep_name)-2))


# remove two lagoons
brazil_2010_full <- subset(brazil_2010_full, !is.na(code_state))



# Add geometry
# brazil_2010 <- dplyr::left_join(sf_2010, table_2010, by='code_muni')
brazil_2010_sp <- dplyr::left_join(sf_2010_sp, table_2010, by='code_muni')


# fix names
brazil_2010_sp$name_muni.x <- NULL
brazil_2010_sp <- dplyr::rename(brazil_2010_sp, name_muni = 'name_muni.y')
head(brazil_2010_sp)

del_name <- grep(".x$",names(brazil_2010_sp), value = T)
keep_name <- grep(".y$",names(brazil_2010_sp), value = T)

brazil_2010_sp <- brazil_2010_sp %>% select(-del_name)
setnames(brazil_2010_sp,keep_name,substr(keep_name,0,nchar(keep_name)-2))


# remove two lagoons
brazil_2010_sp <- subset(brazil_2010_sp, !is.na(code_state))

# save .Rdata
save(brazil_2010, file = "../data/brazil_2010.RData", compress='gzip', compression_level=1)



# # Save file with usethis::use_data
#   assign("brazil_2010", brazil_2010)
#   usethis::use_data(brazil_2010, name="brazil_2010.RData", compress='gzip', compression_level=1)
