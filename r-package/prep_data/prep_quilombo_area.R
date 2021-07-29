#> DATASET: quilombo community
#> Source: INCRA - https://certificacao.incra.gov.br/csv_shp/export_shp.py
#> Metadata:
# Titulo: Áreas Quilombolas 
# Titulo alternativo: Quilombos
# Data: Atualização 2021
#
# Forma de apresentação: Shape
# Linguagem: Pt-BR
# Character set: Utf-8
#
# Resumo: Polígonos e Pontos das áreas quilombolas brasileiras.
# Informações adicionais: Dados produzidos pelo INCRA, e utilizados na elaboração do shape de áreas quilombolas com a melhor base oficial disponível.
# Propósito: Identificação das áreas quilombolas brasileiras.
#
# Estado: Completado
# Palavras chaves descritivas:áreas quilombolas, territórios Quilombolas, áreas quilombolas do Brasil, Quilombos, INCRA.
# Informação do Sistema de Referência: SIRGAS 2000



####### Load Support functions to use in the preprocessing of the data -----------------
 source("./prep_data/prep_functions.R")

library(RCurl)
library(sf)
library(httr)


###### 0. Create Root folder to save the data -----------------
# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw"
setwd(root_dir)

# Directory to keep raw zipped files
destdir_raw <- "./quilombo_area" 
dir.create(destdir_raw)

# Create folders to save clean files  -----------------
dir.create("./quilombo_area/shapes_in_sf_all_years_cleaned", showWarnings = FALSE)
destdir_clean <- "./quilombo_area/shapes_in_sf_all_years_cleaned/"


#### 1. Download original data sets from INCRA and Fundação Cultural Palmmares website -----------------

# Download and read into CSV at the same time
ftp <- "https://certificacao.incra.gov.br/csv_shp/zip/%C3%81reas%20de%20Quilombolas.zip"

download.file(url = ftp,
              destfile = paste0(destdir_raw,"/","quilombo_area.zip"))


#### 2. Unzipe shape files -----------------
setwd(destdir_raw)

# list and unzip zipped files
zipfiles <- list.files(pattern = ".zip")
unzip(zipfiles)


#### 3. Clean data set and save it in compact .gpkg format-----------------

# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//indigenous_land"
setwd(root_dir)


# list all csv files
shape <- list.files(path=root_dir, full.names = T, pattern = ".shp")

# read data 
# o encoding não é UTF-8. Ver qual é. 
temp_sf <- st_read(shape, quiet = F, stringsAsFactors=F, options = "ENCODING=UTF8")
head(temp_sf)

# Select and ename columns
temp_sf <- dplyr::select(temp_sf,
                         code_quilombo = cd_quilomb,
                         code_sr = cd_sr,
                         n_process = nr_process,
                         name_quilombo = nm_comunid,
                         name_muni = nm_municip,
                         abbrev_state = cd_uf,
                         date_recog = dt_publica,
                         date_decree_pr = dt_public1,
                         n_family = nr_familia,
                         date_titration = dt_titulac,
                         code_sipra = cd_sipra,
                         date_decree = dt_decreto,
                         n_scale = nr_escalao,
                         perimeter = perimetro_,
                         sphere = esfera,
                         phase = fase,
                         responsible = responsave,
                         geom = geometry)


# store original CRS
original_crs <- st_crs(temp_sf)

# Create columns with date and with state codes
setDT(temp_sf)

# Create column with state abbreviations
temp_sf[ abbrev_state=="RO", code_state :=	11 ]
temp_sf[ abbrev_state=="AC", code_state :=	12 ]
temp_sf[ abbrev_state=="AM", code_state :=	13 ]
temp_sf[ abbrev_state=="RR", code_state :=	14 ]
temp_sf[ abbrev_state=="PA", code_state :=	15 ]
temp_sf[ abbrev_state=="AP", code_state :=	16 ]
temp_sf[ abbrev_state=="TO", code_state :=	17 ]
temp_sf[ abbrev_state=="MA", code_state :=	21 ]
temp_sf[ abbrev_state=="PI", code_state :=	22 ]
temp_sf[ abbrev_state=="CE", code_state :=	23 ]
temp_sf[ abbrev_state=="RN", code_state :=	24 ]
temp_sf[ abbrev_state=="PB", code_state :=	25 ]
temp_sf[ abbrev_state=="PE", code_state :=	26 ]
temp_sf[ abbrev_state=="AL", code_state :=	27 ]
temp_sf[ abbrev_state=="SE", code_state :=	28 ]
temp_sf[ abbrev_state=="BA", code_state :=	29 ]
temp_sf[ abbrev_state=="MG", code_state :=	31 ]
temp_sf[ abbrev_state=="ES", code_state :=	32 ]
temp_sf[ abbrev_state=="RJ", code_state :=	33 ]
temp_sf[ abbrev_state=="SP", code_state :=	35 ]
temp_sf[ abbrev_state=="PR", code_state :=	41 ]
temp_sf[ abbrev_state=="SC", code_state :=	42 ]
temp_sf[ abbrev_state=="RS", code_state :=	43 ]
temp_sf[ abbrev_state=="MS", code_state :=	50 ]
temp_sf[ abbrev_state=="MT", code_state :=	51 ]
temp_sf[ abbrev_state=="GO", code_state :=	52 ]
temp_sf[ abbrev_state=="DF", code_state :=	53 ]
head(temp_sf)

# standardize columns with different date formats
temp_sf$date_recog <- ifelse(temp_sf$date_recog %like% "^200|^201|^000", 
                             paste0(substr(temp_sf$date_recog,9,10),".",substr(temp_sf$date_recog,6,7),".",substr(temp_sf$date_recog,1,4)),
                             gsub("/",".",temp_sf$date_recog))
temp_sf$date_decree_pr <- ifelse(temp_sf$date_decree_pr %like% "^200|^201|^000", 
                                 paste0(substr(temp_sf$date_decree_pr,9,10),".",substr(temp_sf$date_decree_pr,6,7),".",substr(temp_sf$date_decree_pr,1,4)),
                                 gsub("/",".",temp_sf$date_decree_pr))
temp_sf$date_decree <- ifelse(temp_sf$date_decree %like% "^200|^201|^000", 
                              paste0(substr(temp_sf$date_decree,9,10),".",substr(temp_sf$date_decree,6,7),".",substr(temp_sf$date_decree,1,4)),
                              gsub("/",".",temp_sf$date_decree))
temp_sf$date_titration <- ifelse(temp_sf$date_titration %like% "^000", 
                                 paste0(substr(temp_sf$date_titration,9,10),".",substr(temp_sf$date_titration,6,7),".",substr(temp_sf$date_titration,1,4)),
                                 gsub("/",".",temp_sf$date_titration))


# Standardize code_sr 
temp_sf$code_sr <-  ifelse(temp_sf$code_sr %like% "SR", temp_sf$code_sr, 
                           ifelse(temp_sf$code_sr %like% "^[0-9]", paste0("SR-",temp_sf$code_sr), temp_sf$code_sr))


# Capitalize the first letter
temp_sf$name_muni <- stringr::str_to_title(temp_sf$name_muni)
temp_sf$name_quilombo <- stringr::str_to_title(temp_sf$name_quilombo)


# Convert data.table back into sf
temp_sf <- st_as_sf(temp_sf, crs=original_crs)


# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
temp_sf <- harmonize_projection(temp_sf)


# Make any invalid geometry valid # st_is_valid( sf)
temp_sf <- sf::st_make_valid(temp_sf)


# simplify
temp_sf_simplified <- simplify_temp_sf(temp_sf)

# convert to MULTIPOLYGON
temp_sf <- to_multipolygon(temp_sf)
temp_sf_simplified <- to_multipolygon(temp_sf_simplified)


# Save cleaned sf in the cleaned directory
sf::st_write(temp_sf, dsn = "./shapes_in_sf_all_years_cleaned/quilombo_area.gpkg")
sf::st_write(temp_sf_simplified, dsn = "./shapes_in_sf_all_years_cleaned/quilombo_area_simplified.gpkg")




