library(sf)
library(dplyr)
library(tidyverse)
library(data.table)
library(mapview)


#endereco onde o shape sera salvo
dir.disaster <- "L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\disaster_risk_area"

dir.download <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\disaster_risk_area\\Shapes")

# criando o diretorio de download dos arquivos para a pasta "Shapes"
dir.create(dir.disaster)
dir.create(dir.download)

# baixando o shape no formato .zip e dando-lhe o nome de "PARBR2018_BATER.zip"
download.file("ftp://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/populacao_em_areas_de_risco_no_brasil/base_de_dados/PARBR2018_BATER.zip" ,
              destfile= paste0(dir.download,"/PARBR2018_BATER.zip"))

# descompactando o arquivo
setwd("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\disaster_risk_area\\Shapes")


unzip(paste0(zipfile=dir.download,"/PARBR2018_BATER.zip"), exdir = dir.download)


# lendo o shapefile
shp_risco <- st_read("./Shapes/PARBR2018_BATER.shp")

# Definindo o destino dos arquivos
setwd(dir.disaster)

# salvando no formato rds
readr::write_rds(shp_risco, "shp_risco.rds", compress = "gz")

# lendo o arquivo
area_de_risco <- readr::read_rds("shp_risco.rds")

# Deletando a pasta de download
unlink("Shapes", recursive = TRUE)


# renomeando as vari?veis e excluindo algumas

names(area_de_risco)
area_de_risco$ID <- NULL
area_de_risco$AREA_GEO <- NULL
area_de_risco <- rename(area_de_risco, code_state = GEO_UF)
area_de_risco <- rename(area_de_risco, code_muni = GEO_MUN)
area_de_risco <- rename(area_de_risco, nome_muni = MUNICIPIO)
area_de_risco <- rename(area_de_risco, geo_bater = GEO_BATER)
area_de_risco <- rename(area_de_risco, origem = ORIGEM)
area_de_risco <- rename(area_de_risco, acuracia = ACURACIA)
area_de_risco <- rename(area_de_risco, obs = OBS)
area_de_risco <- rename(area_de_risco, num = NUM)

# store original CRS
original_crs <- st_crs(area_de_risco)


# # criando a coluna das UFs
#alterando area_de_risco para poder criar abbrev_state
area_de_risco <- as.data.table(area_de_risco)

# Criando a coluna das UFs
area_de_risco[ code_state== 11, abbrev_state :=	"RO" ]
area_de_risco[ code_state== 12, abbrev_state :=	"AC" ]
area_de_risco[ code_state== 13, abbrev_state :=	"AM" ]
area_de_risco[ code_state== 14, abbrev_state :=	"RR" ]
area_de_risco[ code_state== 15, abbrev_state :=	"PA" ]
area_de_risco[ code_state== 16, abbrev_state :=	"AP" ]
area_de_risco[ code_state== 17, abbrev_state :=	"TO" ]
area_de_risco[ code_state== 21, abbrev_state :=	"MA" ]
area_de_risco[ code_state== 22, abbrev_state :=	"PI" ]
area_de_risco[ code_state== 23, abbrev_state :=	"CE" ]
area_de_risco[ code_state== 24, abbrev_state :=	"RN" ]
area_de_risco[ code_state== 25, abbrev_state :=	"PB" ]
area_de_risco[ code_state== 26, abbrev_state :=	"PE" ]
area_de_risco[ code_state== 27, abbrev_state :=	"AL" ]
area_de_risco[ code_state== 28, abbrev_state :=	"SE" ]
area_de_risco[ code_state== 29, abbrev_state :=	"BA" ]
area_de_risco[ code_state== 31, abbrev_state :=	"MG" ]
area_de_risco[ code_state== 32, abbrev_state :=	"ES" ]
area_de_risco[ code_state== 33, abbrev_state :=	"RJ" ]
area_de_risco[ code_state== 35, abbrev_state :=	"SP" ]
area_de_risco[ code_state== 41, abbrev_state :=	"PR" ]
area_de_risco[ code_state== 42, abbrev_state :=	"SC" ]
area_de_risco[ code_state== 43, abbrev_state :=	"RS" ]
area_de_risco[ code_state== 50, abbrev_state :=	"MS" ]
area_de_risco[ code_state== 51, abbrev_state :=	"MT" ]
area_de_risco[ code_state== 52, abbrev_state :=	"GO" ]
area_de_risco[ code_state== 53, abbrev_state :=	"DF" ]
head(area_de_risco)



# Convert data.table back into sf
area_de_risco <- st_as_sf(area_de_risco, crs=original_crs)

# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
area_de_risco <- if( is.na(st_crs(area_de_risco)) ){ st_set_crs(area_de_risco, 4674) } else { st_transform(area_de_risco, 4674) }

# Make any invalid geometry valid # st_is_valid( sf)
area_de_risco <- lwgeom::st_make_valid(area_de_risco)



# Save cleaned sf in the cleaned directory
readr::write_rds(area_de_risco, path="disaster_risk_area.rds", compress = "gz")

