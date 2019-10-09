#> DATASET: urbanized areas
#> Source: 2005 - ftp://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/areas_urbanizadas_do_brasil/2005/areas_urbanizadas_do_Brasil_2005_shapes.zip
#>         2015 - ftp://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/areas_urbanizadas_do_brasil/2015/Shape/AreasUrbanizadasDoBrasil_2015.zip
#> Metadata:
# Title: urbanized areas
# Alternate title: ***
# Date: Update 2015
#
# Presentation form: Shape
# Language: Pt-BR
# Character set: 2005 - WINDOWS-1252
#                2015 - UTF-8
#
# Abstract: Polygons of the brazilian urbanized areas.
# Purpose:: Identify the brazilian urbanized areas.
#
# Status: in development
# keywords:****
# Reference System Information: SIRGAS 2000



library(sf)
library(dplyr)
library(tidyverse)
library(tidyr)
library(data.table)
library(mapview)




##### dowload, read e saverds ####

#endereco onde os shapes serão salvos
dir.shapes <- "L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\urban_area"

dir.download <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\urban_area\\Shapes")

dir.2005 <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\urban_area\\2005")

dir.2015 <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\urban_area\\2015")

# create folder to save the data
dir.create(dir.shapes)
dir.create(dir.download)
dir.create(dir.2005)
dir.create(dir.2015)

setwd(dir.download)
# download shape files
download.file("ftp://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/areas_urbanizadas_do_brasil/2005/areas_urbanizadas_do_Brasil_2005_shapes.zip" ,
              destfile="areas_urbanizadas_do_Brasil_2005_shapes.zip")
download.file("ftp://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/areas_urbanizadas_do_brasil/2015/Shape/AreasUrbanizadasDoBrasil_2015.zip" ,
              destfile="AreasUrbanizadasDoBrasil_2015.zip")


# unzip shape files
unzip("./areas_urbanizadas_do_Brasil_2005_shapes.zip")
unzip("./AreasUrbanizadasDoBrasil_2015.zip")

# read shape files
shp_ACP_urban_mun_2005 <- st_read("./AreasUrbanizadas_MunicipiosACP_porMunicipio.shp",
                                  options = "ENCODING=WINDOWS-1252")
shp_cemk_urban_mun_2005 <- st_read("./AreasUrbanizadas_MunicipiosAcima100k_porMunicipio.shp",
                                   options = "ENCODING=WINDOWS-1252")
shp_cost_urban_mun_2005 <- st_read("./AreasUrbanizadas_MunicipiosCosteiros_porMunicipio.shp",
                                   options = "ENCODING=WINDOWS-1252")
shp_mais_urban_mun_2015 <- st_read("./AreasUrbanizadasDoBrasil_2015_Concentracoes_Urbanas_com_mais_de_300000_habitantes.shp",
                                   options = "ENCODING=UTF-8")
shp_ate_urban_mun_2015 <- st_read("./AreasUrbanizadasDoBrasil_2015_Concentracoes_Urbanas_de_100000_a_300000_habitantes.shp",
                                  options = "ENCODING=UTF-8")

# directory 2005
setwd(dir.2005)

# save files rds
readr::write_rds(shp_ACP_urban_mun_2005,"shp_ACP_urban_mun_2005.rds", compress = "gz")
readr::write_rds(shp_cemk_urban_mun_2005,"shp_cemk_urban_mun_2005.rds", compress = "gz")
readr::write_rds(shp_cost_urban_mun_2005,"shp_cost_urban_mun_2005.rds", compress = "gz")



# read files of 2005
ACP_urban_05 <- readRDS("shp_ACP_urban_mun_2005.rds")
cemk_urban_05 <- readRDS("shp_cemk_urban_mun_2005.rds")
cost_urban_05 <- readRDS("shp_cost_urban_mun_2005.rds")

# directory 2015
setwd(dir.2015)

readr::write_rds(shp_mais_urban_mun_2015,"shp_mais_urban_mun_2015.rds", compress = "gz")
readr::write_rds(shp_ate_urban_mun_2015,"shp_ate_urban_mun_2015.rds", compress = "gz")


# read shape files
mais_urban_15 <- readRDS("shp_mais_urban_mun_2015.rds")
ate_urban_15 <- readRDS("shp_ate_urban_mun_2015.rds")

setwd(dir.shapes)
# Delete download folder
unlink("Shapes", recursive = TRUE)


# read the IBGE files for 2005 and 2015
# Note: Although the files are com.rds, they are in another format to read this file, use load
cod_ibge_05 <- "\\\\storage1\\territorial_desenv\\Bases ASMEQ\\Bases consolidadas\\codigo_ibge\\rds\\2005.rds"
load(cod_ibge_05)

names(mun)
ibge_05 <- subset (mun, select = c(municipality_name, municipality_code, state_code, state_initials))

# Rename columns
ibge_05 <- dplyr::rename(ibge_05, name_muni = municipality_name, code_muni = municipality_code,
                         code_state = state_code, abbrev_state = state_initials)

ibge_05$code_muni <- as.factor(ibge_05$code_muni)
head(ibge_05)

#### Clean data set ------------------------------------------------
#########2005##### -------------------------------------------------
setwd(dir.2005)

##### ACP #####

# rename and create columns
names(ACP_urban_05)
ACP_urban_05 <- dplyr::rename(ACP_urban_05, densidade = Tipo, code_muni = GEOCODIGO,
                              geoc_urb = GEOC_URB, acp = ACP, code_acp = COD_ACP)

ACP_urb_05_new<-merge(ACP_urban_05,ibge_05,by="code_muni")
head(ACP_urban_05)


# order and and delete columns
ACP_urb_05 <- ACP_urb_05_new[,c("densidade","code_muni","code_state","name_muni",
                                "abbrev_state","geometry","geoc_urb")]

# store original CRS
original_crs <- sf::st_crs(ACP_urb_05)

# Convert data.table back into sf
ACP_urb_05_sf <- st_as_sf(ACP_urb_05, crs=original_crs)

# Use UTF-8 encoding
str(ACP_urb_05_sf)

ACP_urb_05_sf$name_muni <- stringi::stri_encode(as.character(ACP_urb_05_sf$name_muni), "UTF-8")
ACP_urb_05_sf$abbrev_state <- stringi::stri_encode(as.character(ACP_urb_05_sf$abbrev_state), "UTF-8")

# test the shape
mapview(ACP_urb_05_sf)

# Save cleaned sf in the cleaned directory
readr::write_rds(ACP_urb_05_sf,"./ACP_urb_05.rds", compress = "gz")

##### cemk #####

# rename and create columns
names(cemk_urban_05)
cemk_urban_05 <- dplyr::rename(cemk_urban_05, densidade = Tipo, code_muni = GEOCODIGO,
                              geoc_urb = GEOC_URB, pop_2005 = POP_2005)

cemk_urban_05_new<-merge(cemk_urban_05,ibge_05,by="code_muni")

head(cemk_urban_05)

# order and and delete columns
cemk_urb_05 <- cemk_urban_05_new[,c("densidade","code_muni","code_state",
                                    "name_muni","abbrev_state","geometry","pop_2005","geoc_urb")]
names(cemk_urb_05)

# store original CRS
original_crs <- sf::st_crs(cemk_urb_05)

# Convert data.table back into sf
cemk_urb_05_sf <- st_as_sf(cemk_urb_05, crs=original_crs)

# Use UTF-8 encoding
str(cemk_urb_05_sf)

cemk_urb_05_sf$name_muni <- stringi::stri_encode(as.character(cemk_urb_05_sf$name_muni), "UTF-8")
cemk_urb_05_sf$abbrev_state <- stringi::stri_encode(as.character(cemk_urb_05_sf$abbrev_state), "UTF-8")

# test the shape
mapview(cemk_urb_05_sf)

# Save cleaned sf in the cleaned directory
readr::write_rds(cemk_urb_05_sf,"./cemk_urb_05.rds", compress = "gz")


##### cost #####

# rename and create columns
names(cost_urban_05)

cost_urban_05 <- dplyr::rename(cost_urban_05, densidade = Tipo, code_muni = GEOCODIGO,geoc_urb = GEOC_URB)

cost_urban_05_new<-merge(cost_urban_05,ibge_05,by="code_muni")
head(cost_urban_05)

# order and and delete columns
cost_urb_05 <- cost_urban_05_new[,c("densidade","code_muni","code_state","name_muni",
                                    "abbrev_state","geometry","geoc_urb")]
names(cost_urb_05)

# store original CRS
original_crs <- sf::st_crs(cost_urb_05)

# Convert data.table back into sf
cost_urb_05_sf <- st_as_sf(cost_urb_05, crs=original_crs)

# Use UTF-8 encoding
str(cost_urb_05_sf)

cost_urb_05_sf$name_muni <- stringi::stri_encode(as.character(cost_urb_05_sf$name_muni), "UTF-8")
cost_urb_05_sf$abbrev_state <- stringi::stri_encode(as.character(cost_urb_05_sf$abbrev_state), "UTF-8")

# test the shape
mapview(cost_urb_05_sf)

# Save cleaned sf in the cleaned directory
readr::write_rds(cost_urb_05_sf,"./cost_urb_05.rds", compress = "gz")



#########2015##### --------------------------------------

# activate directory 2015
setwd(dir.2015)

# read the IBGE files for 2005 and 2015
# Note: Although the files are com.rds, they are in another format to read this file, use load
cod_ibge_15 <- "\\\\storage1\\territorial_desenv\\Bases ASMEQ\\Bases consolidadas\\codigo_ibge\\rds\\2015.rds"
load(cod_ibge_15)

names(mun)
ibge_15 <- subset (mun, select = c(municipality_name, municipality_code, state_code, state_initials))

# Rename columns
ibge_15 <- dplyr::rename(ibge_15, name_muni = municipality_name, code_muni = municipality_code,
                         code_state = state_code, abbrev_state = state_initials)
head(ibge_15)

ibge_15$code_muni <- as.factor(ibge_15$code_muni)
head(ibge_15)


########  mais ---------------------

# rename and create columns
mais_urban_15 <- dplyr::rename(mais_urban_15, fid_1 = FID_1, densidade = Densidade, tipo = Tipo, code_muni = CodConcUrb)

mais_urban_15_new<-merge(mais_urban_15,ibge_15,by="code_muni")
head(mais_urban_15)

# order and and delete columns
mais_urb_15 <- mais_urban_15_new[,c("densidade","code_muni","code_state","name_muni",
                                    "abbrev_state","geometry","tipo")]

# store original CRS
original_crs <- sf::st_crs(mais_urb_15)

# Convert data.table back into sf
mais_urb_15_sf <- st_as_sf(mais_urb_15, crs=original_crs)

# Use UTF-8 encoding
str(mais_urb_15_sf)

mais_urb_15_sf$name_muni <- stringi::stri_encode(as.character(mais_urb_15_sf$name_muni), "UTF-8")
mais_urb_15_sf$abbrev_state <- stringi::stri_encode(as.character(mais_urb_15_sf$abbrev_state), "UTF-8")

# test the shape
mapview(mais_urb_15_sf)

# Save cleaned sf in the cleaned directory
readr::write_rds(mais_urb_15_sf,"./mais_urb_15.rds", compress = "gz")


#############
##### até ---------------

# rename and create columns
ate_urban_15 <- dplyr::rename(ate_urban_15, densidade = Densidade, tipo = Tipo, code_muni = CodConcUrb)

ate_urban_15_new<-merge(ate_urban_15,ibge_15,by="code_muni")
head(ate_urban_15)

# order and and delete columns
ate_urb_15 <- ate_urban_15_new[,c("densidade","code_muni","code_state","name_muni",
                                    "abbrev_state","geometry","tipo")]

# store original CRS
original_crs <- sf::st_crs(ate_urb_15)

# Convert data.table back into sf
ate_urb_15_sf <- st_as_sf(ate_urb_15, crs=original_crs)


# Use UTF-8 encoding
str(ate_urb_15_sf)

ate_urb_15_sf$name_muni <- stringi::stri_encode(as.character(ate_urb_15_sf$name_muni), "UTF-8")
ate_urb_15_sf$abbrev_state <- stringi::stri_encode(as.character(ate_urb_15_sf$abbrev_state), "UTF-8")

# test the shape
mapview(ate_urb_15_sf)

# Save cleaned sf in the cleaned directory
readr::write_rds(ate_urb_15_sf,"./ate_urb_15.rds", compress = "gz")



##### join datasets --------------------

# creat pop_2005 in ACP_urb_05 and cost_urb_05
# creat dataset column

setwd(dir.2005)

ACP_urb_05$pop_2005 <- NA
ACP_urb_05$dataset <- "population concentration area"
cost_urb_05$pop_2005 <- NA
cost_urb_05$dataset <- "coastal area"
cemk_urb_05$dataset <- "population about 100k"


urb_2005 <- rbind(ACP_urb_05,cemk_urb_05,cost_urb_05)
dim(urb_2005)
head(urb_2005)
dim(ACP_urb_05)
dim(cemk_urb_05)
dim(cost_urb_05)

# store original CRS
original_crs <- sf::st_crs(urb_2005)

# Convert data.table back into sf
urb_2005_sf <- st_as_sf(urb_2005, crs=original_crs)

#test the shape
mapview(urb_2005_sf)

# Save cleaned sf in the cleaned directory
readr::write_rds(urb_2005_sf,"./urb_2005.rds", compress = "gz")

# creat dataset column
setwd(dir.2015)

mais_urb_15$dataset <- "population greater than 300k"
ate_urb_15$dataset <- "population less than 300k"

dim(mais_urb_15)
dim(ate_urb_15)

urb_2015 <- rbind(ate_urb_15,mais_urb_15)
dim(urb_2015)

# store original CRS
original_crs <- sf::st_crs(urb_2015)

# Convert data.table back into sf
urb_2015_sf <- st_as_sf(urb_2015, crs=original_crs)

#test the shape
mapview(urb_2015_sf)

# Save cleaned sf in the cleaned directory
readr::write_rds(urb_2015_sf,"./urb_2015.rds", compress = "gz")

