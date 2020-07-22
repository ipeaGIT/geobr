library(sf)
library(dplyr)
library(tidyverse)
library(tidyr)
library(data.table)
library(mapview)
library(readr)
library(maptools)

#> Metadata:
# Titulo: Health regions
# Titulo alternativo: Regioes de Saude do SUS
# Data: Atualizado em 07/07/2020
#
# Forma de apresentação: Shape
# Linguagem: Pt-BR
# Character set: 2005 - WINDOWS-1252
#                2015 - UTF-8
#
# Resumo: Criado a partir do Decreto n. 7508 de junho de 2011, em substituicao aos
# Colegiados de Gestao Regional (oriundos do Pacto pela Saude), o CIR a um colegiado
# no qual participam as Secretarias Municipais de Saude, de uma dada regiao, e a Secretaria
# de Estado de saude com o objetivo de promover a gestao colaborativa no setor saude do estado.
# Essa instancia veio aprimorar o processo de regionalizacao no SUS. Os problemas de saude sao
# identificados e analisados conjuntamente. A partir dessa avaliacao procede-se a identificacao
# e pactuar?o das acoes prioritarias, com objetivo de melhorar a situacao de saude e garantir a
# atencao integral na regiao.  A CIR a um ambiente de debate e negociacao que promove a gestao
# colaborativa na saude. Caracteriza-se como um espaco de governanca regional.  Cabe as CIR a
# pactuar?o,  organizaaco e o funcionamento em nivel regional das acoes e servicos de saude
# integrados na rede de atencao a saude - RAS.
#
# Estado: Em desenvolvimento
# Palavras chaves descritivas: CIR; RAS; SUS
# Informacao do Sistema de Referdncia: DATASUS


##### dowload, read e saverds ####

dir.shapes <- "L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus"

dir.download <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus\\Shapes")

dir.1991 <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus\\1991")

dir.1994 <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus\\1994")

dir.1997 <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus\\1997")

dir.2001 <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus\\2001")

dir.2005 <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus\\2005")

dir.2013 <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus\\2013")


# read shape files

setwd(dir.download)

shp_region_sus_1991 <- st_read("./1991\\mapa1991.shp",
                               options = "ENCODING=WINDOWS-1252")

shp_region_sus_1994 <- st_read("./1994\\mapa1994.shp",
                               options = "ENCODING=WINDOWS-1252")

shp_region_sus_1997 <- st_read("./1997\\mapa1997.shp",
                               options = "ENCODING=WINDOWS-1252")

shp_region_sus_2001 <- st_read("./2001\\mapa2001.shp",
                               options = "ENCODING=WINDOWS-1252")

shp_region_sus_2005 <- st_read("./2005\\mapa2005.shp",
                               options = "ENCODING=WINDOWS-1252")

shp_region_sus_2013 <- st_read("./2013\\mapa2013.shp",
                               options = "ENCODING=WINDOWS-1252")

# save and read rds files of each year

setwd(dir.1991)
saveRDS(shp_region_sus_1991, "shp_region_sus_1991.rds")
sus_91 <- readRDS("shp_region_sus_1991.rds")

setwd(dir.1994)
saveRDS(shp_region_sus_1994, "shp_region_sus_1994.rds")
sus_94 <- readRDS("shp_region_sus_1994.rds")

setwd(dir.1997)
saveRDS(shp_region_sus_1997, "shp_region_sus_1997.rds")
sus_97 <- readRDS("shp_region_sus_1997.rds")

setwd(dir.2001)
saveRDS(shp_region_sus_2001, "shp_region_sus_2001.rds")
sus_01 <- readRDS("shp_region_sus_2001.rds")

setwd(dir.2005)
saveRDS(shp_region_sus_2005, "shp_region_sus_2005.rds")
sus_05 <- readRDS("shp_region_sus_2005.rds")

setwd(dir.2013)
saveRDS(shp_region_sus_2013, "shp_region_sus_2013.rds")
sus_13 <- readRDS("shp_region_sus_2013.rds")

setwd(dir.shapes)


## Directory 1991  (Valid for 1991 and 1992) ----

# Obs: Os mapas de 1991 e 1994 estavam com problemas e foram precisos fazer
# uma "gambiarra" para Resolver

na_primid <- which(is.na(shp_region_sus_1991$Primary.ID))
shp_region_sus_1991$Primary.ID[na_primid] <- shp_region_sus_1991$Primary._1[na_primid]
shp_region_sus_1991$Secondary[na_primid] <- shp_region_sus_1991$Secondary_[na_primid]

shp_region_sus_1991 <- shp_region_sus_1991[9:448,] %>%
  select(-c("Primary._1","Secondary_")) %>%
  rename(code_sus  = Primary.ID, name_sus = Secondary)

# store original CRS

original_crs <- sf::st_crs(shp_region_sus_1991)

# Create column with state codes
setDT(shp_region_sus_1991)[, code_state := substr(code_sus, 1, 2) %>% as.numeric() ]

# Create column with state abbreviations
shp_region_sus_1991[ code_state== 11, abbrev_state :=	"RO" ]
shp_region_sus_1991[ code_state== 12, abbrev_state :=	"AC" ]
shp_region_sus_1991[ code_state== 13, abbrev_state :=	"AM" ]
shp_region_sus_1991[ code_state== 14, abbrev_state :=	"RR" ]
shp_region_sus_1991[ code_state== 15, abbrev_state :=	"PA" ]
shp_region_sus_1991[ code_state== 16, abbrev_state :=	"AP" ]
shp_region_sus_1991[ code_state== 17, abbrev_state :=	"TO" ]
shp_region_sus_1991[ code_state== 21, abbrev_state :=	"MA" ]
shp_region_sus_1991[ code_state== 22, abbrev_state :=	"PI" ]
shp_region_sus_1991[ code_state== 23, abbrev_state :=	"CE" ]
shp_region_sus_1991[ code_state== 24, abbrev_state :=	"RN" ]
shp_region_sus_1991[ code_state== 25, abbrev_state :=	"PB" ]
shp_region_sus_1991[ code_state== 26, abbrev_state :=	"PE" ]
shp_region_sus_1991[ code_state== 27, abbrev_state :=	"AL" ]
shp_region_sus_1991[ code_state== 28, abbrev_state :=	"SE" ]
shp_region_sus_1991[ code_state== 29, abbrev_state :=	"BA" ]
shp_region_sus_1991[ code_state== 31, abbrev_state :=	"MG" ]
shp_region_sus_1991[ code_state== 32, abbrev_state :=	"ES" ]
shp_region_sus_1991[ code_state== 33, abbrev_state :=	"RJ" ]
shp_region_sus_1991[ code_state== 35, abbrev_state :=	"SP" ]
shp_region_sus_1991[ code_state== 41, abbrev_state :=	"PR" ]
shp_region_sus_1991[ code_state== 42, abbrev_state :=	"SC" ]
shp_region_sus_1991[ code_state== 43, abbrev_state :=	"RS" ]
shp_region_sus_1991[ code_state== 50, abbrev_state :=	"MS" ]
shp_region_sus_1991[ code_state== 51, abbrev_state :=	"MT" ]
shp_region_sus_1991[ code_state== 52, abbrev_state :=	"GO" ]
shp_region_sus_1991[ code_state== 53, abbrev_state :=	"DF" ]
head(shp_region_sus_1991)

region_sus_1991 <- shp_region_sus_1991[,c("code_sus","code_state","name_sus",
                                          "abbrev_state","geometry")]

# Convert data.table back into sf
region_sus_1991_sf <- st_as_sf(region_sus_1991, crs=original_crs)

# Test the shape
mapview(region_sus_1991_sf)

# Save sf file
saveRDS(region_sus_1991_sf,"./sus_1991.rds")


#### Directory 1994 (Valid for 1993 to 1996) ----

na_primid <- which(is.na(shp_region_sus_1994$Primary.ID))
shp_region_sus_1994$Primary.ID[na_primid] <- shp_region_sus_1994$Primary._1[na_primid]
shp_region_sus_1994$Secondary[na_primid] <- shp_region_sus_1994$Secondary_[na_primid]

shp_region_sus_1994 <- shp_region_sus_1994[9:448,] %>%
  select(-c("Primary._1","Secondary_")) %>%
  rename(code_sus  = Primary.ID, name_sus = Secondary)

# store original CRS
original_crs <- sf::st_crs(shp_region_sus_1994)

# Create column with state codes
setDT(shp_region_sus_1994)[, code_state := substr(code_sus, 1, 2) %>% as.numeric() ]

# Create column with state abbreviations
shp_region_sus_1994[ code_state== 11, abbrev_state :=	"RO" ]
shp_region_sus_1994[ code_state== 12, abbrev_state :=	"AC" ]
shp_region_sus_1994[ code_state== 13, abbrev_state :=	"AM" ]
shp_region_sus_1994[ code_state== 14, abbrev_state :=	"RR" ]
shp_region_sus_1994[ code_state== 15, abbrev_state :=	"PA" ]
shp_region_sus_1994[ code_state== 16, abbrev_state :=	"AP" ]
shp_region_sus_1994[ code_state== 17, abbrev_state :=	"TO" ]
shp_region_sus_1994[ code_state== 21, abbrev_state :=	"MA" ]
shp_region_sus_1994[ code_state== 22, abbrev_state :=	"PI" ]
shp_region_sus_1994[ code_state== 23, abbrev_state :=	"CE" ]
shp_region_sus_1994[ code_state== 24, abbrev_state :=	"RN" ]
shp_region_sus_1994[ code_state== 25, abbrev_state :=	"PB" ]
shp_region_sus_1994[ code_state== 26, abbrev_state :=	"PE" ]
shp_region_sus_1994[ code_state== 27, abbrev_state :=	"AL" ]
shp_region_sus_1994[ code_state== 28, abbrev_state :=	"SE" ]
shp_region_sus_1994[ code_state== 29, abbrev_state :=	"BA" ]
shp_region_sus_1994[ code_state== 31, abbrev_state :=	"MG" ]
shp_region_sus_1994[ code_state== 32, abbrev_state :=	"ES" ]
shp_region_sus_1994[ code_state== 33, abbrev_state :=	"RJ" ]
shp_region_sus_1994[ code_state== 35, abbrev_state :=	"SP" ]
shp_region_sus_1994[ code_state== 41, abbrev_state :=	"PR" ]
shp_region_sus_1994[ code_state== 42, abbrev_state :=	"SC" ]
shp_region_sus_1994[ code_state== 43, abbrev_state :=	"RS" ]
shp_region_sus_1994[ code_state== 50, abbrev_state :=	"MS" ]
shp_region_sus_1994[ code_state== 51, abbrev_state :=	"MT" ]
shp_region_sus_1994[ code_state== 52, abbrev_state :=	"GO" ]
shp_region_sus_1994[ code_state== 53, abbrev_state :=	"DF" ]
head(shp_region_sus_1994)

region_sus_1994 <- shp_region_sus_1994[,c("code_sus","code_state","name_sus",
                                          "abbrev_state","geometry")]

# Convert data.table back into sf
region_sus_1994_sf <- st_as_sf(region_sus_1994, crs=original_crs)

# Test the shape
mapview(region_sus_1994_sf)

# Save sf file
saveRDS(region_sus_1994_sf,"./sus_1994.rds")

## Directory 1997 (Valid for 1997 to 2000) ----

shp_region_sus_1997 <- shp_region_sus_1997 %>%
  rename(code_sus  = Primary.ID, name_sus = Secondary)

# store original CRS
original_crs <- sf::st_crs(shp_region_sus_1997)

# Create column with state codes
setDT(shp_region_sus_1997)[, code_state := substr(code_sus, 1, 2) %>% as.numeric() ]


# Create column with state abbreviations
shp_region_sus_1997[ code_state== 11, abbrev_state :=	"RO" ]
shp_region_sus_1997[ code_state== 12, abbrev_state :=	"AC" ]
shp_region_sus_1997[ code_state== 13, abbrev_state :=	"AM" ]
shp_region_sus_1997[ code_state== 14, abbrev_state :=	"RR" ]
shp_region_sus_1997[ code_state== 15, abbrev_state :=	"PA" ]
shp_region_sus_1997[ code_state== 16, abbrev_state :=	"AP" ]
shp_region_sus_1997[ code_state== 17, abbrev_state :=	"TO" ]
shp_region_sus_1997[ code_state== 21, abbrev_state :=	"MA" ]
shp_region_sus_1997[ code_state== 22, abbrev_state :=	"PI" ]
shp_region_sus_1997[ code_state== 23, abbrev_state :=	"CE" ]
shp_region_sus_1997[ code_state== 24, abbrev_state :=	"RN" ]
shp_region_sus_1997[ code_state== 25, abbrev_state :=	"PB" ]
shp_region_sus_1997[ code_state== 26, abbrev_state :=	"PE" ]
shp_region_sus_1997[ code_state== 27, abbrev_state :=	"AL" ]
shp_region_sus_1997[ code_state== 28, abbrev_state :=	"SE" ]
shp_region_sus_1997[ code_state== 29, abbrev_state :=	"BA" ]
shp_region_sus_1997[ code_state== 31, abbrev_state :=	"MG" ]
shp_region_sus_1997[ code_state== 32, abbrev_state :=	"ES" ]
shp_region_sus_1997[ code_state== 33, abbrev_state :=	"RJ" ]
shp_region_sus_1997[ code_state== 35, abbrev_state :=	"SP" ]
shp_region_sus_1997[ code_state== 41, abbrev_state :=	"PR" ]
shp_region_sus_1997[ code_state== 42, abbrev_state :=	"SC" ]
shp_region_sus_1997[ code_state== 43, abbrev_state :=	"RS" ]
shp_region_sus_1997[ code_state== 50, abbrev_state :=	"MS" ]
shp_region_sus_1997[ code_state== 51, abbrev_state :=	"MT" ]
shp_region_sus_1997[ code_state== 52, abbrev_state :=	"GO" ]
shp_region_sus_1997[ code_state== 53, abbrev_state :=	"DF" ]
head(shp_region_sus_1997)

region_sus_1997 <- shp_region_sus_1997[,c("code_sus","code_state","name_sus",
                                          "abbrev_state","geometry")]

# Convert data.table back into sf
region_sus_1997_sf <- st_as_sf(region_sus_1997, crs=original_crs)

# Test the shape
mapview(region_sus_1997_sf)

# Save sf file
saveRDS(region_sus_1997_sf,"./sus_1997.rds")


## Directory 2001 (Valid for 2001 to 2004) ----

shp_region_sus_2001 <- shp_region_sus_2001 %>%
  rename(code_sus  = Primary.ID, name_sus = Secondary)

# store original CRS
original_crs <- sf::st_crs(shp_region_sus_2001)

# Create column with state codes
setDT(shp_region_sus_2001)[, code_state := substr(code_sus, 1, 2) %>% as.numeric() ]

# Create column with state abbreviations
shp_region_sus_2001[ code_state== 11, abbrev_state :=	"RO" ]
shp_region_sus_2001[ code_state== 12, abbrev_state :=	"AC" ]
shp_region_sus_2001[ code_state== 13, abbrev_state :=	"AM" ]
shp_region_sus_2001[ code_state== 14, abbrev_state :=	"RR" ]
shp_region_sus_2001[ code_state== 15, abbrev_state :=	"PA" ]
shp_region_sus_2001[ code_state== 16, abbrev_state :=	"AP" ]
shp_region_sus_2001[ code_state== 17, abbrev_state :=	"TO" ]
shp_region_sus_2001[ code_state== 21, abbrev_state :=	"MA" ]
shp_region_sus_2001[ code_state== 22, abbrev_state :=	"PI" ]
shp_region_sus_2001[ code_state== 23, abbrev_state :=	"CE" ]
shp_region_sus_2001[ code_state== 24, abbrev_state :=	"RN" ]
shp_region_sus_2001[ code_state== 25, abbrev_state :=	"PB" ]
shp_region_sus_2001[ code_state== 26, abbrev_state :=	"PE" ]
shp_region_sus_2001[ code_state== 27, abbrev_state :=	"AL" ]
shp_region_sus_2001[ code_state== 28, abbrev_state :=	"SE" ]
shp_region_sus_2001[ code_state== 29, abbrev_state :=	"BA" ]
shp_region_sus_2001[ code_state== 31, abbrev_state :=	"MG" ]
shp_region_sus_2001[ code_state== 32, abbrev_state :=	"ES" ]
shp_region_sus_2001[ code_state== 33, abbrev_state :=	"RJ" ]
shp_region_sus_2001[ code_state== 35, abbrev_state :=	"SP" ]
shp_region_sus_2001[ code_state== 41, abbrev_state :=	"PR" ]
shp_region_sus_2001[ code_state== 42, abbrev_state :=	"SC" ]
shp_region_sus_2001[ code_state== 43, abbrev_state :=	"RS" ]
shp_region_sus_2001[ code_state== 50, abbrev_state :=	"MS" ]
shp_region_sus_2001[ code_state== 51, abbrev_state :=	"MT" ]
shp_region_sus_2001[ code_state== 52, abbrev_state :=	"GO" ]
shp_region_sus_2001[ code_state== 53, abbrev_state :=	"DF" ]
head(shp_region_sus_2001)

region_sus_2001 <- shp_region_sus_2001[,c("code_sus","code_state","name_sus",
                                          "abbrev_state","geometry")]

# Convert data.table back into sf
region_sus_2001_sf <- st_as_sf(region_sus_2001, crs=original_crs)

# Test the shape
mapview(region_sus_2001_sf)

# Save sf file
saveRDS(region_sus_2001_sf,"./sus_2001.rds")


## Directory  2005 (Valid for 2005 to 2008)  ----

shp_region_sus_2005 <- shp_region_sus_2005 %>%
  rename(code_sus  = Primary.ID, name_sus = Secondary)

# store original CRS
original_crs <- sf::st_crs(shp_region_sus_2005)

# Create column with state codes
setDT(shp_region_sus_2005)[, code_state := substr(code_sus, 1, 2) %>% as.numeric() ]

# Create column with state abbreviations
shp_region_sus_2005[ code_state== 11, abbrev_state :=	"RO" ]
shp_region_sus_2005[ code_state== 12, abbrev_state :=	"AC" ]
shp_region_sus_2005[ code_state== 13, abbrev_state :=	"AM" ]
shp_region_sus_2005[ code_state== 14, abbrev_state :=	"RR" ]
shp_region_sus_2005[ code_state== 15, abbrev_state :=	"PA" ]
shp_region_sus_2005[ code_state== 16, abbrev_state :=	"AP" ]
shp_region_sus_2005[ code_state== 17, abbrev_state :=	"TO" ]
shp_region_sus_2005[ code_state== 21, abbrev_state :=	"MA" ]
shp_region_sus_2005[ code_state== 22, abbrev_state :=	"PI" ]
shp_region_sus_2005[ code_state== 23, abbrev_state :=	"CE" ]
shp_region_sus_2005[ code_state== 24, abbrev_state :=	"RN" ]
shp_region_sus_2005[ code_state== 25, abbrev_state :=	"PB" ]
shp_region_sus_2005[ code_state== 26, abbrev_state :=	"PE" ]
shp_region_sus_2005[ code_state== 27, abbrev_state :=	"AL" ]
shp_region_sus_2005[ code_state== 28, abbrev_state :=	"SE" ]
shp_region_sus_2005[ code_state== 29, abbrev_state :=	"BA" ]
shp_region_sus_2005[ code_state== 31, abbrev_state :=	"MG" ]
shp_region_sus_2005[ code_state== 32, abbrev_state :=	"ES" ]
shp_region_sus_2005[ code_state== 33, abbrev_state :=	"RJ" ]
shp_region_sus_2005[ code_state== 35, abbrev_state :=	"SP" ]
shp_region_sus_2005[ code_state== 41, abbrev_state :=	"PR" ]
shp_region_sus_2005[ code_state== 42, abbrev_state :=	"SC" ]
shp_region_sus_2005[ code_state== 43, abbrev_state :=	"RS" ]
shp_region_sus_2005[ code_state== 50, abbrev_state :=	"MS" ]
shp_region_sus_2005[ code_state== 51, abbrev_state :=	"MT" ]
shp_region_sus_2005[ code_state== 52, abbrev_state :=	"GO" ]
shp_region_sus_2005[ code_state== 53, abbrev_state :=	"DF" ]
head(shp_region_sus_2005)

region_sus_2005 <- shp_region_sus_2005[,c("code_sus","code_state","name_sus",
                                          "abbrev_state","geometry")]


# Convert data.table back into sf
region_sus_2005_sf <- st_as_sf(region_sus_2005, crs=original_crs)

# Test the shape
mapview(region_sus_2005_sf)

# Save sf file
saveRDS(region_sus_2005_sf,"./sus_2005.rds")


## Directory 2013 (Valid for 2009+) ----

shp_region_sus_2013 <- shp_region_sus_2013 %>%
  rename(code_sus  = Primary.ID, name_sus = Secondary)

# store original CRS
original_crs <- sf::st_crs(shp_region_sus_2013)

# Create column with state codes
setDT(shp_region_sus_2013)[, code_state := substr(code_sus, 1, 2) %>% as.numeric() ]

# Create column with state abbreviations
shp_region_sus_2013[ code_state== 11, abbrev_state :=	"RO" ]
shp_region_sus_2013[ code_state== 12, abbrev_state :=	"AC" ]
shp_region_sus_2013[ code_state== 13, abbrev_state :=	"AM" ]
shp_region_sus_2013[ code_state== 14, abbrev_state :=	"RR" ]
shp_region_sus_2013[ code_state== 15, abbrev_state :=	"PA" ]
shp_region_sus_2013[ code_state== 16, abbrev_state :=	"AP" ]
shp_region_sus_2013[ code_state== 17, abbrev_state :=	"TO" ]
shp_region_sus_2013[ code_state== 21, abbrev_state :=	"MA" ]
shp_region_sus_2013[ code_state== 22, abbrev_state :=	"PI" ]
shp_region_sus_2013[ code_state== 23, abbrev_state :=	"CE" ]
shp_region_sus_2013[ code_state== 24, abbrev_state :=	"RN" ]
shp_region_sus_2013[ code_state== 25, abbrev_state :=	"PB" ]
shp_region_sus_2013[ code_state== 26, abbrev_state :=	"PE" ]
shp_region_sus_2013[ code_state== 27, abbrev_state :=	"AL" ]
shp_region_sus_2013[ code_state== 28, abbrev_state :=	"SE" ]
shp_region_sus_2013[ code_state== 29, abbrev_state :=	"BA" ]
shp_region_sus_2013[ code_state== 31, abbrev_state :=	"MG" ]
shp_region_sus_2013[ code_state== 32, abbrev_state :=	"ES" ]
shp_region_sus_2013[ code_state== 33, abbrev_state :=	"RJ" ]
shp_region_sus_2013[ code_state== 35, abbrev_state :=	"SP" ]
shp_region_sus_2013[ code_state== 41, abbrev_state :=	"PR" ]
shp_region_sus_2013[ code_state== 42, abbrev_state :=	"SC" ]
shp_region_sus_2013[ code_state== 43, abbrev_state :=	"RS" ]
shp_region_sus_2013[ code_state== 50, abbrev_state :=	"MS" ]
shp_region_sus_2013[ code_state== 51, abbrev_state :=	"MT" ]
shp_region_sus_2013[ code_state== 52, abbrev_state :=	"GO" ]
shp_region_sus_2013[ code_state== 53, abbrev_state :=	"DF" ]
head(shp_region_sus_2013)

region_sus_2013 <- shp_region_sus_2013[,c("code_sus","code_state","name_sus",
                                          "abbrev_state","geometry")]

# Convert data.table back into sf
region_sus_2013_sf <- st_as_sf(region_sus_2013, crs=original_crs)

# Test the shape
mapview(region_sus_2013_sf)

# Save sf file
saveRDS(region_sus_2013_sf,"./sus_2013.rds")

