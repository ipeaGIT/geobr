library(sf)
library(dplyr)
library(tidyverse)
library(tidyr)
library(data.table)
library(mapview)
library(readr)
library(maptools)
# https://stackoverflow.com/questions/61614314/how-to-read-a-map-file-extension-in-r

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

# original data source
ftp://ftp.datasus.gov.br/territorio/mapas/



####### Load Support functions to use in the preprocessing of the data -----------------
source("./prep_data/prep_functions.R")






###### 0. Create directories to download and save the data -----------------

# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw"
setwd(root_dir)

# Directory to save clean files
dir.create("./health_regions")
setwd("./health_regions")


# Directory to keep raw zipped files
dir.create("./raw_data")

# Directory to save clean files
dir.create("./shapes_in_sf_cleaned")


# Create folders to save clean files
years_available <- c(1991, 1994, 1997, 2001, 2005, 2013)

lapply(X=years_available, FUN= function(i){
                                destdir_clean1 <- paste0("./gpkg_cleaned_healthregion/",i)
                                destdir_clean2 <- paste0("./gpkg_cleaned_macro/",i)
                                dir.create( destdir_clean1 , showWarnings = FALSE, recursive = T)
                                dir.create( destdir_clean2 , showWarnings = FALSE, recursive = T)
                                }
                              )





###### 1. download the raw data from the original website source -----------------



###### 1.1. Unzip data files if necessary -----------------

zip_files <- list.files('./raw_data/', pattern = '.zip', full.names = T, recursive = T)



####### Function to read original data in .MAP format ------------------


## read function to get names in correct encoding
# source: https://repositorio.ufrn.br/jspui/bitstream/123456789/17008/1/DanielMC_DISSERT.pdf
basic_read_map = function(filename){
  zz=file(filename,"rb")
  #
  # header of .map
  #
  versao = readBin(zz,"integer",1,size=2)  # 100 = versao 1.00
  #Bounding Box
  Leste = readBin(zz,"numeric",1,size=4)
  Norte = readBin(zz,"numeric",1,size=4)
  Oeste = readBin(zz,"numeric",1,size=4)
  Sul   = readBin(zz,"numeric",1,size=4)

  geocodigo = ""
  nome = ""
  xleg = 0
  yleg = 0
  sede = FALSE
  poli = list()
  i = 0

  #
  # repeat of each object in file
  #
  repeat{
    tipoobj = readBin(zz,"integer",1,size=1) # 0=Poligono, 1=PoligonoComSede, 2=Linha, 3=Ponto

    if (length(tipoobj) == 0) break
    i = i + 1

    Len = readBin(zz,"integer",1,size=1)  # length byte da string Pascal
    geocodigo[i] = readChar(zz,10)
    Len = readBin(zz,"integer",1,size=1)  # length byte da string Pascal
    nome[i] = substr(readChar(zz,25),1,Len)
    xleg[i] = readBin(zz,"numeric",1,size=4)
    yleg[i] = readBin(zz,"numeric",1,size=4)
    numpontos = readBin(zz,"integer",1,size=2)

    sede = sede || (tipoobj = 1)

    x=0
    y=0
    for (j in 1:numpontos){
      x[j] = readBin(zz,"numeric",1,size=4)
      y[j] = readBin(zz,"numeric",1,size=4)
    }

    # separate polygons
    xInic = x[1]
    yInic = y[1]
    for (j in 2:numpontos){
      if (x[j] == xInic & y[j] == yInic) {x[j]=NA; y[j] = NA}
    }

    poli[[i]] = c(x,y)
    dim(poli[[i]]) = c(numpontos,2)
  }

  class(poli) = "polylist"
  attr(poli,"region.id") = geocodigo
  attr(poli,"region.name") = nome
  attr(poli,"centroid") = list(x=xleg,y=yleg)
  attr(poli,"sede") = sede
  attr(poli,"maplim") = list(x=c(Oeste,Leste),y=c(Sul,Norte))

  close(zz)
  return(poli)
}





##### START prep function ------------------------
prep_map <- function(i){ # i <- map_files[12]

  message(paste0('working on', i))

# get year and state
  year <- substr(i, 24,27)
  state <- substr(i, 29,30) %>% toupper()

# dest dir
 if( i %like% 'regsaud.MAP' ){ destdir <- "./gpkg_cleaned_healthregion/" }
 if( i %like% 'macsaud.MAP' ){ destdir <- "./gpkg_cleaned_macro/" }



# part1 - get names of regions --------------------------------------
mp <- basic_read_map( i )
name_health_region <- attr(mp,"region.name")
code_health_region <- attr(mp,"region.id")

# part2 - get regions as sf objects ---------------------------------
o <- maptools:::readMAP2polylist( i )
oo <- maptools:::.makePolylistValid(o)
ooo <- maptools:::.polylist2SpP(oo, tol=.Machine$double.eps^(1/4))
#rn <- row.names(ooo)



df <- data.frame(code_health_region=code_health_region, row.names=code_health_region, name_health_region=name_health_region, stringsAsFactors=FALSE)
res <- SpatialPolygonsDataFrame(ooo, data=df)

# fix “orphaned hole” in a polygon
slot(res, "polygons") <- lapply(slot(res, "polygons"), checkPolygonsHoles)

# convert to sf
temp_sf <- st_as_sf(res)
# plot(temp_sf)
# head(temp_sf)

# fix row names
rownames(temp_sf) <- 1:nrow(temp_sf)

        # temp_sf <- geobr::read_health_region(simplified = F)
        # names(temp_sf)[1:2] <- c('code_health_region','name_health_region')

# Add state and region information
options(encoding = "UTF-8")
temp_sf <- add_state_info(temp_sf, column='code_health_region')


# reorder columns
 if (i %like% 'regsaud.MAP') {
   temp_sf <- dplyr::select(temp_sf,
                            "code_health_region", "name_health_region",
                            "code_state", "abbrev_state", "name_state", 'geometry')
                             }

 if (i %like% 'macsaud.MAP') {
   temp_sf <- dplyr::select(temp_sf,
                            "code_health_marcroregion" = code_health_region,
                            "name_health_macroregion" = name_health_region,
                            "code_state", "abbrev_state", "name_state", 'geometry')
                             }



# 4. every string column with UTF-8 encoding -----------------

 # convert all factor columns to character
 temp_sf <- use_encoding_utf8(temp_sf)




###### Harmonize spatial projection -----------------

 # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
 temp_sf <- harmonize_projection(temp_sf)
 st_crs(temp_sf)


 ###### 5. remove Z dimension of spatial data-----------------
 temp_sf <- temp_sf %>% st_sf() %>% st_zm( drop = T, what = "ZM")
 head(temp_sf)


 # simplify
 temp_sf_simplified <- simplify_temp_sf(temp_sf)

 # convert to MULTIPOLYGON
 temp_sf <- to_multipolygon(temp_sf)
 temp_sf_simplified <- to_multipolygon(temp_sf_simplified)



 ###### 8. Clean data set and save it -----------------

 # save original and simplified datasets
 sf::st_write(temp_sf,  paste0( destdir,"/", year, "/", state,".gpkg") )
 sf::st_write(temp_sf_simplified, paste0( destdir, year,"/", state,"_simplified.gpkg") )

}


##### Aplica para diferentes anos ------------------------

# list address of original files
map_files <- list.files('./raw_data', pattern = 'br_regsaud.MAP|br_macsaud.MAP', full.names = T, recursive = T)


  # # regioes de cada estado
  # map_files <- map_files[ substr(map_files, 31,31) == "_" ]


# Parallel processing using future.apply
future::plan(future::multisession)
furrr::future_map(.x=map_files, .f = prep_map, .progress = T)



pbapply::pblapply(map_files, prep_map)



a <-  st_read("./shapes_in_sf_cleaned/1991/BR.gpkg")
head(a)

