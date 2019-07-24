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





#### 0. Download original data sets from IBGE ftp -----------------

# setores 2010
  ftp <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2010/setores_censitarios_shp/"

# setores 2000 rural
  ftp2 <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2000/setor_rural/projecao_geografica/censo_2000/e500_arcview_shp/uf/"

# setores 2000 urbano
  ftp3 <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2000/setor_urbano/"


### setor censitario censo 2010
filenames = getURL(ftp, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames = unlist(filenames)
filenames <- filenames[!grepl('leia_me', filenames)]

filesurl<-paste(ftp, filenames[9],"/", sep = "")
filesurl<-getURL(filesurl, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filesurl<-strsplit(filesurl, "\r\n")
filesurl<-unlist(filesurl)


#fazendo download dos dados zipados
for (filename in filenames) {
  filesurl<-paste(ftp, filename,"/", sep = "")
  filesurl<-getURL(filesurl, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filesurl<-strsplit(filesurl, "\r\n")
  filesurl<-unlist(filesurl)

  dir.fonte <- paste0("//Storage6/usuarios/# DIRUR #/ASMEQ/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2010/",filename)
  dir.create(dir.fonte,recursive = T)

  for (files in filesurl) {
    download.file(paste(ftp, filename,"/",files, sep = ""),paste(dir.fonte,"/",files,sep = ""))
  }
}

### setor censitario rural censo 2000
filenames = getURL(ftp2, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames = unlist(filenames)
filenames <- filenames[!grepl('leia_me', filenames)]


#fazendo download dos dados zipados
for (filename in filenames) {
  filesurl<-paste(ftp2, filename,"/", sep = "")
  filesurl<-getURL(filesurl, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filesurl<-strsplit(filesurl, "\r\n")
  filesurl<-unlist(filesurl)

  dir.fonte <- paste0("//Storage6/usuarios/# DIRUR #/ASMEQ/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2000/",filename)
  dir.create(dir.fonte,recursive = T)

  for (files in filesurl) {
    download.file(paste(ftp2, filename,"/",files, sep = ""),paste(dir.fonte,"/",files,sep = ""))
  }
}

### setor censitario urbano censo 2000

filenames = getURL(ftp3, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames = unlist(filenames)
filenames <- filenames[!grepl('leia_me', filenames)]


dir.fonte <- paste0("//Storage6/usuarios/# DIRUR #/ASMEQ/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2000/Urbano/")
filespasta<-list.files(dir.fonte)
filespasta<-unlist(filespasta)
difflies<-setdiff(filenames,filespasta)

#fazendo download dos dados zipados

for (filename in difflies) {
  filesurl<-paste(ftp3, filename,"/", sep = "")
  filesurl<-getURL(filesurl, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filesurl<-strsplit(filesurl, "\r\n")
  filesurl<-unlist(filesurl)

  dir.fonte <- paste0("//Storage6/usuarios/# DIRUR #/ASMEQ/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2000/Urbano/",filename)
  dir.create(dir.fonte,recursive = T)


  for (files in filesurl) {

    if ( grepl("3300704",files)) { download.file(paste(ftp3, filename,"/",files,"/",files,"_2000.zip", sep = ""),paste(dir.fonte,"/",files,".zip",sep = ""),quiet = T)
    }
    else if (grepl(".zip",files)){
      download.file(paste(ftp3, filename,"/",files, sep = ""),paste(dir.fonte,"/",files,sep = ""),quiet = T)
    } else {
      download.file(paste(ftp3, filename,"/",files,"/",files,".zip", sep = ""),paste(dir.fonte,"/",files,".zip",sep = ""),quiet = T)
    }
  }
}

########  1. Unzip original data sets downloaded from IBGE -----------------

# Root directory
root_dir <- "//Storage6/usuarios/# DIRUR #//ASMEQ//geobr//data-raw//setores_censitarios"
setwd(root_dir)

all_zipped_files<-list()

filenames = getURL(ftp, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames = unlist(filenames)
filenames <- filenames[!grepl('leia_me', filenames)]

for (filename in filenames) {

  filesurl<-paste(ftp, filename,"/", sep = "")
  filesurl<-getURL(filesurl, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filesurl<-strsplit(filesurl, "\r\n")
  filesurl<-unlist(filesurl)

dir.fonte <- paste0("//Storage6/usuarios/# DIRUR #/ASMEQ/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2010/",filename)

all_zipped_files <- c(all_zipped_files,list.files(dir.fonte,full.names = T, recursive = T, pattern = "_setores_censitarios.zip|go_setores _censitarios.zip"))
#
# for (files in filesurl) {
#   if(grepl("_setores_censitarios.zip",files)){
#     # unzip(paste(dir.fonte,"/",files,sep = ""),exdir = "//Storage6/usuarios/# DIRUR #/ASMEQ/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2010/unzip")
#   }
# }
}


### setor censitario rural censo 2000
filenames = getURL(ftp2, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames = unlist(filenames)
filenames <- filenames[!grepl('leia_me', filenames)]


for (filename in filenames) {

  filesurl<-paste(ftp2, filename,"/", sep = "")
  filesurl<-getURL(filesurl, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filesurl<-strsplit(filesurl, "\r\n")
  filesurl<-unlist(filesurl)

  dir.fonte <- paste0("//Storage6/usuarios/# DIRUR #/ASMEQ/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2000/Rural/",filename)

  all_zipped_files <- c(all_zipped_files,list.files(dir.fonte,full.names = T, recursive = T, pattern = "_setores_censitarios.zip"))
  #
  # for (files in filesurl) {
  #   if(grepl("_setores_censitarios.zip",files)){
  #     # unzip(paste(dir.fonte,"/",files,sep = ""),exdir = "//Storage6/usuarios/# DIRUR #/ASMEQ/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2010/unzip")
  #   }
  # }
}



filenames = getURL(ftp3, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames = unlist(filenames)
filenames <- filenames[!grepl('leia_me', filenames)]

filename <-filenames[1]

for (filename in filenames) {

  filesurl<-paste(ftp3, filename,"/", sep = "")
  filesurl<-getURL(filesurl, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filesurl<-strsplit(filesurl, "\r\n")
  filesurl<-unlist(filesurl)

  dir.fonte <- paste0("//Storage6/usuarios/# DIRUR #/ASMEQ/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2000/Urbano/",filename)

  all_zipped_files <- c(all_zipped_files,list.files(dir.fonte,full.names = T, recursive = T, pattern = ".zip"))
  #
  # for (files in filesurl) {
  #   if(grepl("_setores_censitarios.zip",files)){
  #     # unzip(paste(dir.fonte,"/",files,sep = ""),exdir = "//Storage6/usuarios/# DIRUR #/ASMEQ/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2010/unzip")
  #   }
  # }
}

#
# c<-0
# for (testes in all_zipped_files) {
#   if (grepl("Rural|Urbano",testes)) {
#     c<-c+1
#   }
# }

teste_zip<-unlist(all_zipped_files)

# function to Unzip files in their original sub-dir
unzip_fun <- function(f){
# f <- teste_zip[100]
  if (grepl("Rural|Urbano",f)) {
    zip_path <- unlist(stringr::str_split(f,"/"))
    zip_path <- tail(zip_path , n=4)
    zip_path <- head(zip_path , n=3)
    zip_path <- paste(zip_path ,collapse  = "/")
  } else {
    zip_path <- unlist(stringr::str_split(f,"/"))
    zip_path <- tail(zip_path , n=3)
    zip_path <- head(zip_path , n=2)
    zip_path <-paste(zip_path ,collapse  = "/")
  }
  dir.create(file.path(root_dir,zip_path), showWarnings = FALSE)
  unzip(f, exdir = file.path(root_dir,zip_path))
  }

# create computing clusters
cl <- parallel::makeCluster(detectCores())
parallel::clusterExport(cl=cl, varlist= c("teste_zip", "root_dir"), envir=environment())

# apply function in parallel
parallel::parLapply(cl, teste_zip, unzip_fun)
stopCluster(cl)


rm(list=setdiff(ls(), c("root_dir","teste_zip")))
gc(reset = T)





#### 2. Create folders to save sf.rds files  -----------------


# Root directory
root_dir <- "//Storage6/usuarios/# DIRUR #//ASMEQ//geobr//data-raw//setores_censitarios"
setwd(root_dir)
sub_dirs <- list.dirs(path =root_dir, recursive = F)


# get all years in the directory
last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
years <- lapply(sub_dirs, last4)
years <-  unlist(years)
years <-gsub("[^0-9]",NA,years)
years <-years[!is.na(years)]

# create directory to save original shape files in sf format
dir.create(file.path("shapes_in_sf_all_years_original"), showWarnings = FALSE)

# create directory to save cleaned shape files in sf format
dir.create(file.path("shapes_in_sf_all_years_cleaned"), showWarnings = FALSE)

# create a subdirectory of states, municipalities, micro and meso regions
dir.create(file.path("shapes_in_sf_all_years_original", "Rural"), showWarnings = FALSE)
dir.create(file.path("shapes_in_sf_all_years_original", "Urbano"), showWarnings = FALSE)

dir.create(file.path("shapes_in_sf_all_years_cleaned", "Rural"), showWarnings = FALSE)
dir.create(file.path("shapes_in_sf_all_years_cleaned", "Urbano"), showWarnings = FALSE)

# create a subdirectory of years
sub_dirs <- list.dirs(path ="./shapes_in_sf_all_years_original", recursive = F)

for (i in sub_dirs){
  for (y in years){
    if (y==2010) {dir.create(file.path("./shapes_in_sf_all_years_original", y), showWarnings = FALSE)
    } else {
      dir.create(file.path(i, y), showWarnings = FALSE)
    }
  }
}

sub_dirs <- list.dirs(path ="./shapes_in_sf_all_years_cleaned", recursive = F)

for (i in sub_dirs){
  for (y in years){
    if (y==2010) {dir.create(file.path("./shapes_in_sf_all_years_cleaned", y), showWarnings = FALSE)
    } else {
    dir.create(file.path(i, y), showWarnings = FALSE)
      }

  }
}

rm(list= ls())
gc(reset = T)






#### 3. Save original data sets downloaded from IBGE in compact .rds format-----------------

# Root directory
root_dir <- "//Storage6/usuarios/# DIRUR #//ASMEQ//geobr//data-raw//setores_censitarios"
setwd(root_dir)

# List shapes for all years
all_shapes <- list.files(full.names = T, recursive = T, pattern = ".shp|.SHP")
ead(all_shapes)

shp_to_sf_rds <- function(x){

  # x <- all_shapes[1]

  # get corresponding year of the file
  year <- unlist(stringr::str_split(x,"/"))
  year <- head(year , n=2)
  year <- tail(year , n=1)
  year <-gsub("[^0-9]","",year)
  year <-year[!is.na(year)]


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
  last15 <- function(x){substr(x, nchar(x)-30, nchar(x))}   # function to get the last 4 digits of a string

  if ( last15(x) %like% "Urbano"){ dest_dir <- paste0("./shapes_in_sf_all_years_original/Urbano/", year)  }
  else if ( last15(x) %like% "Rural"){ dest_dir <- paste0("./shapes_in_sf_all_years_original/Rural/", year) }
  else {dest_dir <- paste0("./shapes_in_sf_all_years_original/", year)    }

  # name of the file that will be saved
  if( year %like% "2000" & last15(x) %like% "Urbano"){ file_name <- paste0(toupper(
    substr(tail(unlist(stringr::str_split(x,"/")),n=1), 0, (nchar(tail(unlist(stringr::str_split(x,"/")),n=1))-4) )), ".rds") }
  if( year %like% "2000" & last15(x) %like% "Rural"){ file_name <- paste0(toupper(
    substr(tail(unlist(stringr::str_split(x,"/")),n=1),0,2)), ".rds") }
  if( year %like% "2010"){ file_name <- paste0( toupper(
    substr(tail(unlist(stringr::str_split(x,"/")),n=1),0,2)), ".rds") }

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








###### 4. Cleaning files --------------------------------

SC_dir <- "//Storage6/usuarios/# DIRUR #//ASMEQ//geobr//data-raw//setores_censitarios//shapes_in_sf_all_years_original/"
setwd(SC_dir)

# list all .rds files
  all_shapes <- list.files(full.names = T, recursive = T, pattern = ".rds")




# create a function that will clean the sf files according to particularities of the data in each year
clean_tracts <- function( sf_file ){

  # sf_file <- all_shapes[all_shapes %like% "2000" & all_shapes %like% "Urbano"]
  # sf_file <- all_shapes[all_shapes %like% "2010"]

  # sf_file <- sf_file[2]

  # read sf file
    temp_sf <- read_rds(sf_file)


  # get year of the file
    # last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
    # year <- last4(e)
    if( sf_file %like% "/2000/" ){ year <- 2000}
    if( sf_file %like% "/2007/" ){ year <- 2007}
    if( sf_file %like% "/2010/" ){ year <- 2010}


  # rural tracts of year 2000
    if ((year %like% "2000") & (sf_file %like% "Rural")){

      # sf_file <- all_shapes[all_shapes %like% "2000" & all_shapes %like% "Rural"]
      # sf_file <- sf_file[2]
      # temp_sf <- read_rds(sf_file)

      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- temp_sf %>% mutate(code_state=substr(geocodigo,1,2),code_muni=substr(geocodigo,1,7))
      temp_sf <- dplyr::rename(temp_sf, code_tract = geocodigo, zone = situacao)
      temp_sf <- dplyr::select(temp_sf, c('code_tract', 'zone', 'code_muni', 'code_state', 'geometry'))
    }


  # Urban tracts of year 2000
    if ((year %like% "2000") & (sf_file %like% "Urbano")){

      # sf_file <- all_shapes[all_shapes %like% "2000" & all_shapes %like% "Urbano"]
      # sf_file <- sf_file[2]
      # temp_sf <- read_rds(sf_file)

        names(temp_sf) <- names(temp_sf) %>% tolower()
        temp_sf <- temp_sf %>% mutate(code_state=substr(id_,1,2),code_muni=substr(id_,1,7))
        temp_sf <- dplyr::rename(temp_sf, code_tract = id_)
        temp_sf <- dplyr::select(temp_sf, c('code_tract', 'code_muni', 'code_state', 'geometry'))

      sf::st_crs(temp_sf) <- paste(sf::st_crs(temp_sf)[["proj4string"]], "+south")
      # temp_sf <- dplyr::rename(temp_sf, code_state = geocodigo, name_state = nome)
      # temp_sf <- dplyr::select(temp_sf, c('code_state', 'name_state', 'geometry'))
    }


  # Tracts of year 2010
    if (year %like% "2010"){

      # sf_file <- all_shapes[all_shapes %like% "2010"]
      # sf_file <- sf_file[2]
      # temp_sf <- read_rds(sf_file)

      # rename columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- temp_sf %>% mutate(code_state=substr(cd_geocodm,1,2))
      temp_sf <- dplyr::rename(temp_sf,
                               code_tract = cd_geocodi,
                               zone = tipo,
                               code_muni = cd_geocodm,
                               name_muni = nm_municip,
                               name_neighborhood=nm_bairro,
                               code_neighborhood=cd_geocodb,
                               code_subdistrict=cd_geocods,
                               name_subdistrict=nm_subdist,
                               code_district=cd_geocodd,
                               name_district=nm_distrit)
      # filter columns
      temp_sf <- dplyr::select(temp_sf,
                               'code_tract',
                               'zone',
                               'code_muni',
                               'name_muni',
                               'name_neighborhood',
                               'code_neighborhood',
                               'code_subdistrict',
                               'name_subdistrict',
                               'code_district',
                               'name_district',
                               'code_state',
                               'geometry')
            }


    # Adjust string columns
      cols.names <- grep("name",names(temp_sf),value = T)

      for (col in cols.names){

        # Use UTF-8 encoding
        temp_sf[[col]] <- stringi::stri_encode(as.character((temp_sf[[col]]), "UTF-8"))

        # Capitalize the first letter
        temp_sf[[col]] <- stringr::str_to_title(temp_sf[[col]])

      }


    # # Use UTF-8 encoding
    #
    # cols.names <- grep("_name",names(temp_sf),value = T)
    #
    # temp_sf$neighborhood_name <- stringi::stri_encode(as.character((temp_sf$neighborhood_name), "UTF-8"))
    # temp_sf$subdistrict_name <- stringi::stri_encode(as.character((temp_sf$subdistrict_name), "UTF-8"))
    # temp_sf$district_name <- stringi::stri_encode(as.character((temp_sf$district_name), "UTF-8"))
    # temp_sf$name_muni <- stringi::stri_encode(as.character((temp_sf$name_muni), "UTF-8"))
    # temp_sf$micro_name <- stringi::stri_encode(as.character((temp_sf$micro_name), "UTF-8"))
    # temp_sf$meso_name <- stringi::stri_encode(as.character((temp_sf$meso_name), "UTF-8"))
    #
    # # Capitalize the first letter
    # temp_sf$subdistrict_name <- stringr::str_to_title(temp_sf$subdistrict_name)
    # temp_sf$district_name <- stringr::str_to_title(temp_sf$district_name)
    # temp_sf$name_muni <- stringr::str_to_title(temp_sf$name_muni)
    # temp_sf$subdistrict_name <- stringr::str_to_title(temp_sf$subdistrict_name)
    # temp_sf$micro_name <- stringr::str_to_title(temp_sf$micro_name)
    # temp_sf$meso_name <- stringr::str_to_title(temp_sf$meso_name)

    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
      temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }
      # mapview::mapview(temp_sf)

    # Convert columns from factors to characters
      temp_sf %>% dplyr::mutate_if(is.factor, as.character) -> temp_sf

    # Make an invalid geometry valid # st_is_valid( sf)
      temp_sf <- lwgeom::st_make_valid(temp_sf)

    # keep code as.numeric()
      #temp_sf %>% dplyr::mutate_at(vars(matches("code_")), funs(as.numeric))
      temp_sf$code_state <- as.numeric(temp_sf$code_state)
      temp_sf$code_muni <- as.numeric(temp_sf$code_muni)


  # Determine directory to save cleaned sf
      if( sf_file %like% "2010"){ dest_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//setores_censitarios//shapes_in_sf_all_years_cleaned//2010//" }
      if( sf_file %like% "Urbano/2000"){ dest_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//setores_censitarios//shapes_in_sf_all_years_cleaned//Urbano//2000//" }
      if( sf_file %like% "Rural/2000"){ dest_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//setores_censitarios//shapes_in_sf_all_years_cleaned//Rural//2000//" }

  # name of the file that will be saved (the whole string between './' and '.rds')
    file_name <- gsub(".*/(.+).rds.*", "\\1", sf_file)

  # Save cleaned sf in the cleaned directory
    write_rds(temp_sf, path = paste0(dest_dir, file_name,".rds"), compress="gz" )

}



lapply(sub_dirs, clean_tracts)

# Apply function to save original data sets in rds format

# create computing clusters
cl <- parallel::makeCluster(detectCores())

clusterEvalQ(cl, c(library(data.table), library(dplyr), library(readr), library(stringr), library(sf)))
parallel::clusterExport(cl=cl, varlist= c("sub_dirs"), envir=environment())

# apply function in parallel
parallel::parLapply(cl, sub_dirs, clean_tracts)
stopCluster(cl)

rm(list= ls())
gc(reset = T)

# this
