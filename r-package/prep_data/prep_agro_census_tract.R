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
library(future)
# library(sp)


####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")


# If the data set is updated regularly, you should create a function that will have
# a `date` argument download the data

update <- 2017


###### 0. Create directories to downlod and save the data -----------------

# Set a root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw"
setwd(root_dir)


# Create Directory to keep original downloaded files
destdir_raw <- ".//census_tract_agro"
dir.create(destdir_raw)

destdir_raw <- paste0(destdir_raw,"//",update)
dir.create(destdir_raw )

# Create Directory to save clean sf.rds files
destdir_clean <- ".//census_tract_agro"
destdir_clean <- paste0(destdir_clean, "/all_years_cleaned/")
dir.create(destdir_clean, recursive =T)

destdir_clean <- paste0(destdir_clean,"/",update)
dir.create(destdir_clean )




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

  file_dir <- paste0(destdir_raw,"/",filename)
  dir.create(path = file_dir, recursive = T)


  for (files in filesurl[5]) {
    download.file(paste(ftp, filename,"/",files, sep = ""),paste(file_dir,"/",files,sep = ""))
  }
}


########  1. Unzip original data sets downloaded from IBGE -----------------

# Root directory
setwd(destdir_raw)

# list all zipped files
all_zipped_files <- list.files(path = destdir_raw, pattern = ".zip", recursive = T, full.names = T)


# function to Unzip files in their original sub-dir
unzip_fun <- function(f){
  # f <- all_zipped_files[1]

  zip_path <- unlist(stringr::str_split(f,"/"))
  zip_path <- tail(zip_path , n=3)
  zip_path <- head(zip_path , n=2)
  zip_path <-paste(zip_path ,collapse  = "/")

  # unzip
  unzip(f, exdir = file.path(zip_path))
}


# apply function in parallel
future::plan(multiprocess)
future_map(.x = all_zipped_files, .f = unzip_fun)
gc(reset = T)





###### 4. Cleaning files --------------------------------

setwd(destdir_raw)
setwd('../')

# List shapes for all years
all_shapes <- list.files(full.names = T, recursive = T, pattern = ".shp|.SHP")
head(all_shapes)



clean_tracts <- function(x){  # x <- all_shapes[1]

# Read original shape file
  temp_sf <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")


###### 2. rename column names -----------------

# rename and filter columns
names(temp_sf) <- names(temp_sf) %>% tolower()
temp_sf2 <- dplyr::select(temp_sf,
                         code_tract = cd_setor,
                         zone = cd_sit,
                         area_ha = area_ha,
                         code_muni = cd_mun,
                         name_muni = nm_mun,
                         code_subdistrict=cd_subdist,
                         name_subdistrict=nm_subdist,
                         code_district=cd_dist,
                         name_district=nm_dist,
                         code_micro=cd_micro,
                         name_micro=nm_micro,
                         code_meso=cd_meso,
                         name_meso=nm_meso,
                         code_state = cd_uf,
                         name_state = nm_uf,
                         geometry=geometry)


    # define urban/rural classification
    # 1 – Área urbanizada de vila ou cidade: Setor urbano situado em áreas legalmente definidas como urbanas, caracterizadas por construções, arruamentos e intensa ocupação humana; áreas afetadas por transformações decorrentes do desenvolvimento urbano e aquelas reservadas à expansão urbana;
    # 2 – Área não urbanizada de vila ou cidade: Setor urbano situado em áreas localizadas dentro do perímetro urbano de cidades e vilas reservadas à expansão urbana ou em processo de urbanização; áreas legalmente definidas como urbanas, mas caracterizadas por ocupação predominantemente de caráter rural;
    # 3 – Área urbanizada isolada: Setor urbano situado em áreas definidas por lei municipal e separadas da sede municipal ou distrital por área rural ou por um outro limite legal;
    # 4 – Rural - extensão urbana: Setor rural situado em assentamentos situados em área externa ao perímetro urbano legal, mas desenvolvidos a partir de uma cidade ou vila, ou por elas englobados em sua extensão;
    # 5 – Rural – povoado: Setor rural situado em aglomerado rural isolado sem caráter privado ou empresarial, ou seja, não vinculado a um único proprietário do solo (empresa agrícola, indústria, usina, etc.), cujos moradores exercem atividades econômicas no próprio aglomerado ou fora dele. Caracteriza-se pela existência de um número mínimo de serviços ou equipamentos para atendimento aos moradores do próprio aglomerado ou de áreas rurais próximas;
    # 6 – Rural – núcleo: Setor rural situado em aglomerado rural isolado, vinculado a um único proprietário do solo (empresa agrícola, indústria, usina, etc.), privado ou empresarial, dispondo ou não dos serviços ou equipamentos definidores dos povoados;
    # 7 – Rural - outros aglomerados: Setor rural situado em outros tipos de aglomerados rurais, que não dispõem, no todo ou em parte, dos serviços ou equipamentos definidores dos povoados, e que não estão vinculados a um único proprietário (empresa agrícola, indústria, usina, etc.);
    # 8 – Rural – exclusive os aglomerados rurais: Setor rural situado em área externa ao perímetro urbano, exclusive as áreas de aglomerado rural.


###### 3. ensure the data uses spatial projection SIRGAS 2000 epsg (SRID): 4674-----------------
temp_sf3 <- harmonize_projection(temp_sf2)



###### 4. ensure every string column is as.character with UTF-8 encoding -----------------
temp_sf4 <- use_encoding_utf8(temp_sf3)

# keep code as.numeric()
for (col in cols.names){
  temp_sf4[[col]] <- as.numeric((temp_sf4[[col]]))
}


###### 5. remove Z dimension of spatial data-----------------
temp_sf5 <- temp_sf4 %>% st_sf() %>% st_zm( drop = T, what = "ZM")



###### 6. fix eventual topology issues in the data-----------------
temp_sf6 <- sf::st_make_valid(temp_sf5)



###### convert to MULTIPOLYGON -----------------
temp_sf7 <- to_multipolygon(temp_sf6)



###### 7. generate a lighter version of the dataset with simplified borders -----------------
# skip this step if the dataset is made of points, regular spatial grids or rater data

# simplify
temp_sf8 <- simplify_temp_sf(temp_sf7)


# Determine directory to save cleaned sf
# get corresponding state
uf_code <- temp_sf8$code_state[1]
dest_dir <- paste0('./','all_years_cleaned', '/', update)
# dir.create(dest_dir)

sf::st_write(temp_sf7, dsn= paste0(dest_dir,'/', uf_code,".gpkg"), overwrite = T)
sf::st_write(temp_sf8, dsn= paste0(dest_dir,'/', uf_code,"_simplified.gpkg"), overwrite = T)
}



# Apply function to save original data sets in rds format

# apply function in parallel
future::plan(multiprocess)
future_map(.x = all_shapes, .f = clean_tracts)
gc(reset = T)
