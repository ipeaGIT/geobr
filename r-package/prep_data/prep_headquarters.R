library(RCurl)
library(tidyverse)
library(stringr)
library(sf)
library(magrittr)
library(data.table)
library(parallel)
library(lwgeom)


# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw"
setwd(root_dir)
head_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//headquarters"
dir.create(head_dir)
#### 0. Download original data sets from IBGE ftp -----------------

# ftp with original data

#bases históricas
url_h <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/evolucao_da_divisao_territorial_do_brasil/evolucao_da_divisao_territorial_do_brasil_1872_2010/municipios_1872_1991/divisao_territorial_1872_1991/"

#base atual
# url_a <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/localidades/Shapefile_SHP/"

# List files/folders available

years = getURL(url_h, ftp.use.epsv = FALSE, dirlistonly = TRUE)
years <- strsplit(years, "\r\n")
years = unlist(years)
# years = years[grepl("capital|sede",years)]


for (i in years){

  # list files
  subdir <- paste0(url_h, i,"/")
  files = getURL(subdir, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  files <- strsplit(files, "\r\n")
  files = unlist(files)
  files <- files[grepl("capital|sede",files)]


  # create folder to download and store raw data of each year
  dir.create(paste0(head_dir,"//",i))


  # Download zipped files
  for (filename in files) {
    url = paste(subdir, filename, sep = "")
    download.file(url,destfile = paste0("./headquarters/",i,"/",filename))#, mode = "wb")
  }
}

# Download current file (2010)
# file_a <- getURL(url_a, ftp.use.epsv = FALSE, dirlistonly = TRUE)
# file_a <- strsplit(file_a, "\r\n")
# file_a = unlist(file_a)
# file_a <- file_a[grepl(".shp",file_a)]
#
# dir_2010 <- paste0(head_dir,"//",2010)
# dir.create(dir_2010)
# setwd(head_dir)
# download.file(paste0(url_a, file_a, sep = ""),destfile = paste0("./2010","/",file_a), mode = "wb")



########  1. Unzip original data sets downloaded from IBGE -----------------
setwd(head_dir)


# List all zip files for all years
all_zipped_files <- list.files(full.names = T, recursive = T, pattern = ".zip")



# Select only files with capital and headquarter
all_zipped_files <- all_zipped_files[all_zipped_files %like% "capital|sede"]


# function to Unzip files in their original sub-dir
unzip_fun <- function(f){
  unzip(f, exdir = file.path(head_dir, substr(f, 3, 6)))
}


# create computing clusters
cl <- parallel::makeCluster(detectCores())
parallel::clusterExport(cl=cl, varlist= c("all_zipped_files", "head_dir"), envir=environment())

# apply function in parallel
parallel::parLapply(cl, all_zipped_files, unzip_fun)
stopCluster(cl)




#### 2. Create folders to save sf.rds files  -----------------


# create directory to save cleaned shape files in sf format
dir.create(file.path("shapes_in_sf_all_years_cleaned"), showWarnings = FALSE)

# create a subdirectory years
#years <- c(years,"2010")

for (i in years){
  dir.create(file.path("shapes_in_sf_all_years_cleaned", i), showWarnings = FALSE)
}


#setwd(root_dir)
# pegar apenas os shapes dessa lista
# ou vai entrar no fo anterior ou vamos criar um novo for/function

for (i in years){ #i=1970
  dir_years <- paste0(head_dir,"//",i)
  setwd(dir_years)
  dados <- list.files(pattern = "*.shp", full.names = T)

  # retirando os arquivos .xml
  dados <- dados[!grepl(".xml",dados)]

  for (z in 1:3){
#i=1
    # Lendo os shapes
    setwd(paste0(head_dir,"//",i))
    temp_sf <- st_read(dados[z], quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")

    # colocando o nome das colunas em letras minúsculas
    names(temp_sf) <- names(temp_sf) %>% tolower()

    # arrumando o nome e a posição das colunas
    if("codigo" %in% names(temp_sf)){
      temp_sf <- dplyr::rename(temp_sf, code_muni = codigo, name_muni = nome )
    } else if ("br91poly_i" %in% names(temp_sf)){
      temp_sf <- dplyr::rename(temp_sf, code_muni = br91poly_i, name_muni = nomemunicp )
    } else {
      temp_sf <- dplyr::rename(temp_sf, code_muni = geocodigo, name_muni = nome )
    }
    # else {
    #   temp_sf <- dplyr::rename(temp_sf, code_muni = code_muni, name_muni = name_muni )
    # }

    # temp_sf <- dplyr::rename(temp_sf, code_muni = codigo|code_muni = geocodigo, name_muni = nome )
    temp_sf <- dplyr::select(temp_sf, c('code_muni', 'name_muni', 'geometry'))

    # Use UTF-8 encoding
    temp_sf$name_muni <- stringi::stri_encode(as.character(temp_sf$name_muni), "UTF-8")
#str(temp_sf)
    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
    temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }

    # Convert columns from factors to characters
    temp_sf %>% dplyr::mutate_if(is.factor, as.character) -> temp_sf

    temp_sf$code_muni <- as.numeric(temp_sf$code_muni) # keep code as.numeric()

    # Save cleaned sf in the cleaned directory
    setwd(head_dir)
    destdir <- file.path("./shapes_in_sf_all_years_cleaned",i)
    data_save <- gsub(" ","_",dados)
    data_save <- gsub("./","",data_save)
    data_save <- gsub("-","",data_save)
    readr::write_rds(temp_sf, path = paste0(destdir,"/", gsub(".shp","",data_save[z]), ".rds"), compress="gz" )

  }
}
