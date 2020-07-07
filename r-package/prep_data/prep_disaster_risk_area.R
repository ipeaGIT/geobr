#> DATASET: disaster_risk_areas 2010
#> Source: IBGE - ftp://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/populacao_em_areas_de_risco_no_brasil
#> Metadata:
# Titulo: disaster_risk_areas
# Titulo alternativo: Areas de risco de desastres naturais 2010
# Frequencia de atualizacao: ?
#
# Forma de apresentação: Shape
# Linguagem: Pt-BR
# Character set: Utf-8
#
# Resumo: Poligonos de areas de risco de desastres de natura hidro-climatologicas
# Informações adicionais: Dados produzidos conjuntamente por IBGE e CEMADEN
#
# Estado: Em desenvolvimento
# Palavras chaves descritivas:****
# Informacao do Sistema de Referencia: SIRGAS 2000

### Libraries (use any library as necessary)

library(sf)
library(dplyr)
library(tidyverse)
library(data.table)
library(mapview)

####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")




# If the data set is updated regularly, you should create a function that will have
# a `date` argument download the data

update <- 2010







###### 0. Create Root folder to save the data -----------------
# Root directory
root_dir <- "L:\\# DIRUR #\\ASMEQ\\geobr\\data-raw"
setwd(root_dir)



# Directory to keep raw zipped files
dir.create("./disaster_risk_area")
destdir_raw <- paste0("./disaster_risk_area/",update)
dir.create(destdir_raw)


# Create folders to save clean sf.rds files  -----------------
dir.create("./disaster_risk_area/shapes_in_sf_cleaned", showWarnings = FALSE)
destdir_clean <- paste0("./disaster_risk_area/shapes_in_sf_cleaned/",update)
dir.create(destdir_clean)



#### 0. Download original data sets from source website -----------------


# baixando o shape no formato .zip e dando-lhe o nome de "PARBR2018_BATER.zip"
download.file("ftp://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/populacao_em_areas_de_risco_no_brasil/base_de_dados/PARBR2018_BATER.zip" ,
              destfile= paste0(destdir_raw,"/PARBR2018_BATER.zip"))



#### 2. Unzipe shape files -----------------
setwd(destdir_raw)

# list and unzip zipped files
zipfiles <- list.files(pattern = ".zip")
unzip(zipfiles)




#### 3. Clean data set and save it in compact .rds format-----------------


# lendo o shapefile
temp_sf <- st_read("PARBR2018_BATER.shp")


# renomeando as variáveis e excluindo algumas

names(temp_sf)
temp_sf$ID <- NULL
temp_sf$AREA_GEO <- NULL
temp_sf <- rename(temp_sf, code_state = GEO_UF,)
temp_sf <- rename(temp_sf, code_muni = GEO_MUN)
temp_sf <- rename(temp_sf, name_muni = MUNICIPIO)
temp_sf <- rename(temp_sf, geo_bater = GEO_BATER)
temp_sf <- rename(temp_sf, origem = ORIGEM)
temp_sf <- rename(temp_sf, acuracia = ACURACIA)
temp_sf <- rename(temp_sf, obs = OBS)
temp_sf <- rename(temp_sf, num = NUM)


# Use UTF-8 encoding
temp_sf$name_muni <- stringi::stri_encode(as.character(temp_sf$name_muni), "UTF-8")


# store original CRS
original_crs <- sf::st_crs(temp_sf)

# # criando a coluna das UFs
#alterando temp_sf para poder criar abbrev_state
temp_sf <- as.data.table(temp_sf)

# Criando a coluna das UFs
temp_sf[ code_state== 11, abbrev_state :=	"RO" ]
temp_sf[ code_state== 12, abbrev_state :=	"AC" ]
temp_sf[ code_state== 13, abbrev_state :=	"AM" ]
temp_sf[ code_state== 14, abbrev_state :=	"RR" ]
temp_sf[ code_state== 15, abbrev_state :=	"PA" ]
temp_sf[ code_state== 16, abbrev_state :=	"AP" ]
temp_sf[ code_state== 17, abbrev_state :=	"TO" ]
temp_sf[ code_state== 21, abbrev_state :=	"MA" ]
temp_sf[ code_state== 22, abbrev_state :=	"PI" ]
temp_sf[ code_state== 23, abbrev_state :=	"CE" ]
temp_sf[ code_state== 24, abbrev_state :=	"RN" ]
temp_sf[ code_state== 25, abbrev_state :=	"PB" ]
temp_sf[ code_state== 26, abbrev_state :=	"PE" ]
temp_sf[ code_state== 27, abbrev_state :=	"AL" ]
temp_sf[ code_state== 28, abbrev_state :=	"SE" ]
temp_sf[ code_state== 29, abbrev_state :=	"BA" ]
temp_sf[ code_state== 31, abbrev_state :=	"MG" ]
temp_sf[ code_state== 32, abbrev_state :=	"ES" ]
temp_sf[ code_state== 33, abbrev_state :=	"RJ" ]
temp_sf[ code_state== 35, abbrev_state :=	"SP" ]
temp_sf[ code_state== 41, abbrev_state :=	"PR" ]
temp_sf[ code_state== 42, abbrev_state :=	"SC" ]
temp_sf[ code_state== 43, abbrev_state :=	"RS" ]
temp_sf[ code_state== 50, abbrev_state :=	"MS" ]
temp_sf[ code_state== 51, abbrev_state :=	"MT" ]
temp_sf[ code_state== 52, abbrev_state :=	"GO" ]
temp_sf[ code_state== 53, abbrev_state :=	"DF" ]
head(temp_sf)



# Convert data.table back into sf
temp_sf <- st_as_sf(temp_sf, crs=original_crs)

# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }

# Make any invalid geometry valid # st_is_valid( sf)
temp_sf <- lwgeom::st_make_valid(temp_sf)

# reorder column names
setcolorder(temp_sf, c('geo_bater', 'origem', 'acuracia', 'obs', 'num', 'code_muni', 'name_muni', 'code_state', 'abbrev_state', 'geometry'))



###### convert to MULTIPOLYGON -----------------
temp_sf <- to_multipolygon(temp_sf)


###### 6. generate a lighter version of the dataset with simplified borders -----------------
# skip this step if the dataset is made of points, regular spatial grids or rater data

# simplify
temp_sf7 <- st_transform(temp_sf, crs=3857) %>%
  sf::st_simplify(preserveTopology = T, dTolerance = 100) %>%
  st_transform(crs=4674)
head(temp_sf7)


# Save cleaned sf in the cleaned directory
setwd(root_dir)
readr::write_rds(temp_sf, path= paste0(destdir_clean,"/disaster_risk_area2010.rds"), compress = "gz")
sf::st_write(temp_sf,     dsn=  paste0(destdir_clean,"/disaster_risk_area2010.gpkg") )
sf::st_write(temp_sf7,    dsn=  paste0(destdir_clean,"/disaster_risk_area2010 _simplified", ".gpkg"))


