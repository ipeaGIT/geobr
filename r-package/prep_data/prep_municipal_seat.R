### Libraries (use any library as necessary)

library(RCurl)
library(tidyverse)
library(stringr)
library(sf)
library(magrittr)
library(data.table)
library(parallel)
library(lwgeom)
library(geobr)
library(mapview)

####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")



# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw"
# root_dir <- "C:/Users/rafa/Desktop/data"


setwd(root_dir)

head_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//municipal_seat"
# head_dir <- "C:/Users/rafa/Desktop/data/municipal_seat"
dir.create(head_dir)
#### 0. Download original data sets from IBGE ftp -----------------

# ftp with original data

#bases históricas
url_h <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/evolucao_da_divisao_territorial_do_brasil/evolucao_da_divisao_territorial_do_brasil_1872_2010/municipios_1872_1991/divisao_territorial_1872_1991/"

#base atual
url_a <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/localidades/Shapefile_SHP/"

# List files/folders available

years = getURL(url_h, ftp.use.epsv = FALSE, dirlistonly = TRUE)
years <- strsplit(years, "\r\n")
years = unlist(years)
years <- c(years, 2010)

for (i in years){

  # list files
  message(paste('Downloading', i))
  subdir <- paste0(url_h, i,"/")
  files = getURL(subdir, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  files <- strsplit(files, "\r\n")
  files = unlist(files)
  files <- files[grepl("municipal",files)]


  # create folder to download and store raw data of each year
  dir.create(paste0(head_dir,"//",i))


  # Download zipped files
  for (filename in files) {
    url = paste(subdir, filename, sep = "")
    download.file(url,destfile = paste0("./municipal_seat/",i,"/",filename))
  }

  if(i=="2010"){
    # Download current file (2010)

    message(paste('Downloading', i))
    file_a <- getURL(url_a, ftp.use.epsv = FALSE, dirlistonly = TRUE)
    file_a <- strsplit(file_a, "\r\n")
    file_a = unlist(file_a)

    dir_2010 <- paste0(head_dir,"//",2010)
    dir.create(dir_2010)
    setwd(head_dir)

    for (filename in file_a) {
      url = paste(url_a, filename, sep = "")
      download.file(url, destfile = paste0("./",2010,"/",filename) , mode = "wb")
    }
  }

}



########  1. Unzip original data sets downloaded from IBGE -----------------
setwd(head_dir)


# List all zip files for all years
all_zipped_files <- list.files(full.names = T, recursive = T, pattern = ".zip")



# Select only files with capital and headquarter
all_zipped_files <- all_zipped_files[all_zipped_files %like% "municipal"]


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
setwd(head_dir)


# create directory to save cleaned shape files in sf format
dir.create(file.path("shapes_in_sf_all_years_cleaned"), showWarnings = FALSE)

# create a subdirectory years
for (i in years){
  dir.create(file.path("shapes_in_sf_all_years_cleaned", i), showWarnings = FALSE)
}



#i=2010
for (i in years){
  # i=2010
  dir_years <- paste0(head_dir,"//",i)
  setwd(dir_years)

  # selecionar apenas os arquivos .shp
  dados <- list.files(pattern = "*.shp", full.names = T)

  if (i!=2010){
    # retirando os arquivos .xml da lista
    dados <- dados[!grepl(".xml",dados)]

    # mantendo apenas o arquivo de sede na lista
    dados <- dados[grepl("sede",dados)]
  }

  # Lendo os shapes
  setwd(paste0(head_dir,"//",i))
  temp_sf <- st_read(dados, quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")

  # colocando o nome das colunas em letras minúsculas
  names(temp_sf) <- names(temp_sf) %>% tolower()

  # padroniza o nome da coluna para "code_muni"
  if("codigo" %in% names(temp_sf)){
    temp_sf <- dplyr::rename(temp_sf, code_muni = codigo)
  } else if ("br91poly_i" %in% names(temp_sf)){
    temp_sf <- dplyr::rename(temp_sf, code_muni = br91poly_i)
  } else if ("geocodigo" %in% names(temp_sf)){
    temp_sf <- dplyr::rename(temp_sf, code_muni = geocodigo)
  } else {
    temp_sf <- dplyr::rename(temp_sf, code_muni = cd_geocodm)
  }


  # seleciona apenas a sede
  if(i==2010){# table(temp_sf$nm_categor, temp_sf$cd_nivel)
    temp_sf <- subset(temp_sf, nm_categor == "CIDADE")
  }


  # leitura dos municipios
  municipios <- read_municipality(code_muni = 'all', year = i)

  # harmoniza projecao
  temp_sf <- st_transform(temp_sf, st_crs(municipios))

  # faz intersecao
  temp_sf <- st_join(temp_sf, municipios)


  # remover sedes duplicadas no municipio errado
  temp_sf <- subset(temp_sf, code_muni.y == code_muni.x)





  # organiza colunas
  temp_sf <- dplyr::select(temp_sf, code_muni = code_muni.x, name_muni, geometry)

  # cria a coluna ano
  temp_sf$year <- i


  ### cria colunas de estado
  # add State code
  temp_sf$code_state <-  substr(temp_sf$code_muni,1,2)

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



  # cria coluna de região
  temp_sf$code_region <-  substr(temp_sf$code_muni,1,1)

  ### add region names
  temp_sf$name_region <- ifelse(temp_sf$code_region==1, 'Norte',
                                ifelse(temp_sf$code_region==2, 'Nordeste',
                                       ifelse(temp_sf$code_region==3, 'Sudeste',
                                              ifelse(temp_sf$code_region==4, 'Sul',
                                                     ifelse(temp_sf$code_region==5, 'Centro Oeste', NA)))))

  # organizando colunas
  temp_sf <- dplyr::select(temp_sf, c('code_muni', 'name_muni', 'code_state', 'abbrev_state', 'code_region', 'name_region', 'year', 'geometry'))

  # Use UTF-8 encoding
  temp_sf$name_muni <- stringi::stri_encode(as.character(temp_sf$name_muni), "UTF-8")

  # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
  temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }
  st_crs(temp_sf) <- 4674

  # Convert columns from factors to characters
  temp_sf %>% dplyr::mutate_if(is.factor, as.character) -> temp_sf

  temp_sf$code_muni <- as.numeric(temp_sf$code_muni) # keep code as.numeric()
  
  # Save cleaned sf in the cleaned directory
  setwd(head_dir)
  destdir <- file.path("./shapes_in_sf_all_years_cleaned",i)
  readr::write_rds(temp_sf, path= paste0(destdir,"/", "municipal_seat_",i, ".rds"), compress = "gz")
  sf::st_write(temp_sf,  dsn= paste0(destdir,"/", "municipal_seat_",i, ".gpkg") )


}
