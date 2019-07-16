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





#### 0. Download original data sets from IBGE ftp -----------------

ftp <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/municipios_por_regioes_metropolitanas/"




