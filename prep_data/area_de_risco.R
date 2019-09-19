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



# endereço do servidor onde o shape será salvo
dir.proj <- "L:\\\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\area_de_risco\\2010"

# definindo diretório de download dos arquivos para a pasta "Shapes"
dir.download <- paste0("L:\\\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\area_de_risco\\Shapes")

# se a pasta Shapes não existir ela será criada
dir.create(dir.download)
setwd(dir.download)
# getwd()

# baixando o shape no formato .zip e dando-lhe o nome de "PARBR2018_BATER.zip"
download.file("ftp://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/populacao_em_areas_de_risco_no_brasil/SHPs/PARBR2018_BATER.zip" ,
              destfile="PARBR2018_BATER.zip")

# descompactando o arquivo
unzip("L:\\\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\area_de_risco\\Shapes\\PARBR2018_BATER.zip")

# lendo o shapefile
shp_risco <- st_read("PARBR2018_BATER.shp")

# Definindo o destino dos arquivos
setwd(dir.proj)

# salvando no formato rds
saveRDS(shp_risco, "shp_risco.rds")

# lendo o arquivo
# area_de_risco_2010 <- readRDS("area_de_risco_2010.rds")

# st_write(shp_risco, "shp_risco.shp")

# Deletando a pasta de download
unlink("Shapes", recursive = TRUE)

# renomeando as variáveis
names(area_de_risco_2010)
area_de_risco_2010 <- rename(area_de_risco_2010, id = ID)
area_de_risco_2010 <- rename(area_de_risco_2010, cod_uf = GEO_UF)
area_de_risco_2010 <- rename(area_de_risco_2010, cod_mun = GEO_MUN)
area_de_risco_2010 <- rename(area_de_risco_2010, nome_mun = MUNICIPIO)
area_de_risco_2010 <- rename(area_de_risco_2010, geo_bater = GEO_BATER)
area_de_risco_2010 <- rename(area_de_risco_2010, origem = ORIGEM)
area_de_risco_2010 <- rename(area_de_risco_2010, acuracia = ACURACIA)
area_de_risco_2010 <- rename(area_de_risco_2010, obs = OBS)
area_de_risco_2010 <- rename(area_de_risco_2010, num = NUM)
area_de_risco_2010 <- rename(area_de_risco_2010, area_geo = AREA_GEO)

shp_risco$id <- NULL
shp_risco$nome_mun <- NULL
shp_risco$origem <- NULL
shp_risco$acuracia <- NULL
shp_risco$obs <- NULL

saveRDS(shp_risco, "area_de_risco_2010.rds")






















