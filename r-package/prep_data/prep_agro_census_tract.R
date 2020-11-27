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
library(parallel)
# library(sp)


####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")


# If the data set is updated regularly, you should create a function that will have
# a `date` argument download the data

update <- 2017
# unecessary


###### 0. Create directories to downlod and save the data -----------------

# Set a root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw"
setwd(root_dir)


# Create Directory to keep original downloaded files
destdir_raw <- "./new_data"
dir.create(destdir_raw)


# Create Directory to save clean sf.rds files
destdir_clean <- paste0("./new_data/sf_all_years_cleaned/")
dir.create(destdir_clean, recursive =T)





###### 1. download the raw data from the original website source -----------------

ftp <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_agro_2017/UFs/"


filenames = getURL(ftp, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames = unlist(filenames)

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

  dir.fonte <- paste0("//Storage6/usuarios/# DIRUR #/ASMEQ/geobr//data-raw//setores_censitarios_agricultura/censo_2017/",filename)
  dir.create(dir.fonte,recursive = T)

  for (files in filesurl) {
    download.file(paste(ftp, filename,"/",files, sep = ""),paste(dir.fonte,"/",files,sep = ""))
  }
}


########  1. Unzip original data sets downloaded from IBGE -----------------

# Root directory
root_dir <- "//Storage6/usuarios/# DIRUR #//ASMEQ//geobr//data-raw//setores_censitarios_agricultura"
setwd(root_dir)


# list all zipped files
all_zipped_files <- list.files(pattern = ".zip", recursive = T, full.names = T)
all_zipped_files <- all_zipped_files[all_zipped_files %like% "_censitarios"]

teste_zip<-unlist(all_zipped_files)


# function to Unzip files in their original sub-dir
unzip_fun <- function(f){
  # f <- teste_zip[73]
  # f <- teste_zip[80]
  # f <- teste_zip[46]

  zip_path <- unlist(stringr::str_split(f,"/"))
  zip_path <- tail(zip_path , n=3)
  zip_path <- head(zip_path , n=2)
  zip_path <-paste(zip_path ,collapse  = "/")

  # unzip
  dir.create(file.path(root_dir,zip_path), showWarnings = FALSE)
  unzip(f, exdir = file.path(root_dir,zip_path))



}


# create computing clusters
cl <- parallel::makeCluster(detectCores())
parallel::clusterExport(cl=cl, varlist= c("teste_zip", "root_dir"), envir=environment())

# apply function in parallel
parallel::parLapply(cl, teste_zip, unzip_fun)
stopCluster(cl)


#rm(list=setdiff(ls(), c("root_dir","teste_zip")))
gc(reset = T)


#### 2. Create folders to save sf.rds files  -----------------


# Root directory
root_dir <- "//Storage6/usuarios/# DIRUR #//ASMEQ//geobr//data-raw//setores_censitarios_agricultura"
setwd(root_dir)
sub_dirs <- list.dirs(path =root_dir, recursive = F)


# create directory to save original and clean shape files in sf format
dir.create(file.path("shapes_in_sf_all_years_original"), showWarnings = FALSE)
dir.create(file.path("shapes_in_sf_all_years_cleaned"), showWarnings = FALSE)


# year 2017
dir.create(file.path("shapes_in_sf_all_years_original", "2017"), showWarnings = FALSE)
dir.create(file.path("shapes_in_sf_all_years_cleaned", "2017"), showWarnings = FALSE)

#rm(list= ls())
gc(reset = T)



#### 3. Save original data sets downloaded from IBGE in compact .rds format-----------------

# Root directory
root_dir <- "//Storage6/usuarios/# DIRUR #//ASMEQ//geobr//data-raw//setores_censitarios_agricultura"
setwd(root_dir)

# List shapes for all years
all_shapes <- list.files(full.names = T, recursive = T, pattern = ".shp|.SHP")
head(all_shapes)

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


  # Encoding
  shape <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")


  # get destination subdirectory based on abbreviation of the geography
  last30 <- function(x){substr(x, nchar(x)-30, nchar(x))}   # function to get the last 4 digits of a string

  dest_dir <- paste0("./shapes_in_sf_all_years_original/", year)

  # name of the file that will be saved
  if( year %like% "2017"){ file_name <- paste0( toupper(
    substr(tail(unlist(stringr::str_split(x,"/")),n=1),0,2)), ".rds") }

  # save in .rds
  write_rds(shape, file = paste0(dest_dir,"/", file_name), compress="gz" )
}


# Apply function to save original data sets in rds format

# create computing clusters
cl <- parallel::makeCluster(detectCores())

clusterEvalQ(cl, c(library(data.table), library(readr), library(sf)))
parallel::clusterExport(cl=cl, varlist= c("all_shapes"), envir=environment())

# apply function in parallel
parallel::parLapply(cl, all_shapes, shp_to_sf_rds)
stopCluster(cl)

#rm(list= ls())
gc(reset = T)







###### 4. Cleaning files --------------------------------

SC_dir <- "//Storage6/usuarios/# DIRUR #//ASMEQ//geobr//data-raw//setores_censitarios_agricultura//shapes_in_sf_all_years_original/"
setwd(SC_dir)

# list all .rds files
all_shapes <- list.files(full.names = T, recursive = T, pattern = ".rds")




# create a function that will clean the sf files according to particularities of the data in each year
clean_tracts <- function( sf_file ){

  # sf_file <- all_shapes[all_shapes %like% "2000" & all_shapes %like% "Urbano"]
  # sf_file <- all_shapes[all_shapes %like% "2010"]

  # sf_file <- sf_file[2]

  # read sf file
  #temp_sf <- read_rds(sf_file, quiet = T)
  temp_sf <- read_rds(sf_file)


  # get year of the file
  if( sf_file %like% "/2017/" ){ year <- 2017}


  # define urban/rural classification
  # 1 – Área urbanizada de vila ou cidade: Setor urbano situado em áreas legalmente definidas como urbanas, caracterizadas por construções, arruamentos e intensa ocupação humana; áreas afetadas por transformações decorrentes do desenvolvimento urbano e aquelas reservadas à expansão urbana;
  # 2 – Área não urbanizada de vila ou cidade: Setor urbano situado em áreas localizadas dentro do perímetro urbano de cidades e vilas reservadas à expansão urbana ou em processo de urbanização; áreas legalmente definidas como urbanas, mas caracterizadas por ocupação predominantemente de caráter rural;
  # 3 – Área urbanizada isolada: Setor urbano situado em áreas definidas por lei municipal e separadas da sede municipal ou distrital por área rural ou por um outro limite legal;
  # 4 – Rural - extensão urbana: Setor rural situado em assentamentos situados em área externa ao perímetro urbano legal, mas desenvolvidos a partir de uma cidade ou vila, ou por elas englobados em sua extensão;
  # 5 – Rural – povoado: Setor rural situado em aglomerado rural isolado sem caráter privado ou empresarial, ou seja, não vinculado a um único proprietário do solo (empresa agrícola, indústria, usina, etc.), cujos moradores exercem atividades econômicas no próprio aglomerado ou fora dele. Caracteriza-se pela existência de um número mínimo de serviços ou equipamentos para atendimento aos moradores do próprio aglomerado ou de áreas rurais próximas;
  # 6 – Rural – núcleo: Setor rural situado em aglomerado rural isolado, vinculado a um único proprietário do solo (empresa agrícola, indústria, usina, etc.), privado ou empresarial, dispondo ou não dos serviços ou equipamentos definidores dos povoados;
  # 7 – Rural - outros aglomerados: Setor rural situado em outros tipos de aglomerados rurais, que não dispõem, no todo ou em parte, dos serviços ou equipamentos definidores dos povoados, e que não estão vinculados a um único proprietário (empresa agrícola, indústria, usina, etc.);
  # 8 – Rural – exclusive os aglomerados rurais: Setor rural situado em área externa ao perímetro urbano, exclusive as áreas de aglomerado rural.

  # Tracts of year 2017
  if (year %like% "2017"){

    # sf_file <- all_shapes[all_shapes %like% "2010"]
    # sf_file <- sf_file[2]
    # temp_sf <- read_rds(sf_file)

    # rename columns
    names(temp_sf) <- names(temp_sf) %>% tolower()
    #temp_sf <- temp_sf %>% mutate(code_state=substr(cd_uf,1,2))
    temp_sf <- dplyr::rename(temp_sf,
                             code_tract = cd_setor,
                             code_sit = cd_sit,
                             code_state = cd_uf,
                             code_muni = cd_mun,
                             name_muni = nm_mun,
                             name_meso=nm_meso,
                             code_meso=cd_meso,
                             name_micro=nm_micro,
                             code_micro=cd_micro,
                             code_subdistrict=cd_subdist,
                             name_subdistrict=nm_subdist,
                             code_district=cd_dist,
                             name_district=nm_dist)
    # filter columns
    temp_sf <- dplyr::select(temp_sf,
                             'code_tract',
                             'code_sit',
                             'code_muni',
                             'name_muni',
                             'name_meso',
                             'code_meso',
                             'name_micro',
                             'code_micro',
                             'code_subdistrict',
                             'name_subdistrict',
                             'code_district',
                             'name_district',
                             'code_state',
                             'area_ha',,
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

  # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
  temp_sf <- harmonize_projection(temp_sf)
  # mapview::mapview(temp_sf)

  # Convert columns from factors to characters
  temp_sf %>% dplyr::mutate_if(is.factor, as.character) -> temp_sf

  # Make an invalid geometry valid # st_is_valid( sf)
  temp_sf <- sf::st_make_valid(temp_sf)

  ###### convert to MULTIPOLYGON
  temp_sf <- to_multipolygon(temp_sf)

  # keep code as.numeric()
  #temp_sf %>% dplyr::mutate_at(vars(matches("code_")), funs(as.numeric))
  temp_sf$code_state <- as.numeric(temp_sf$code_state)
  temp_sf$code_muni <- as.numeric(temp_sf$code_muni)


  # Determine directory to save cleaned sf
  if( sf_file %like% "/2017/"){ dest_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//setores_censitarios_agricultura//shapes_in_sf_all_years_cleaned//2017//" }

  # name of the file that will be saved (the whole string between './' and '.rds')
  file_name <- gsub(".*/(.+).rds.*", "\\1", sf_file)

  # Save cleaned sf in the cleaned directory

  temp_sf7 <- st_transform(temp_sf, crs=3857) %>% sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)


  readr::write_rds(temp_sf,paste0(dest_dir, file_name,"sca.rds"), compress="gz")
  sf::st_write(temp_sf, dsn= paste0(dest_dir, file_name,"sca.gpkg"))
  sf::st_write(temp_sf7, dsn= paste0(dest_dir, file_name,"sca_simplified", ".gpkg"))

}



# Apply function to save original data sets in rds format

# create computing clusters
cl <- parallel::makeCluster(detectCores())

clusterEvalQ(cl, c(library(data.table), library(dplyr), library(readr), library(stringr), library(sf)))
parallel::clusterExport(cl=cl, varlist= c("all_shapes","harmonize_projection","to_multipolygon"), envir=environment())

# apply function in parallel
parallel::parLapply(cl, all_shapes, clean_tracts)
stopCluster(cl)

#rm(list= ls())
gc(reset = T)

