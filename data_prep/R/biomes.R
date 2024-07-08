#> DATASET: biomes 2004, 2019
#> Source: IBGE - https://geoftp.ibge.gov.br/informacoes_ambientais/estudos_ambientais/biomas/
#: scale 1:5.000.000
#> Metadata:
# Titulo: Biomas
# Titulo alternativo: Biomas 2004
# Frequencia de atualizacao: ?
#
# Forma de apresentação: Shape
# Linguagem: Pt-BR
# Character set: Utf-8
#
# Resumo: Poligonos e Pontos do biomas brasileiros.
# Informações adicionais: Dados produzidos pelo IBGE, e utilizados na elaboracao do shape de biomas com a melhor base oficial disponivel.
# Proposito: Identificao dos biomas brasileiros.
#
# Estado: Em desenvolvimento
# Palavras chaves descritivas:****
# Informacao do Sistema de Referencia: SIRGAS 2000

### Libraries (use any library as necessary)

library(RCurl)
library(stringr)
library(collapse)
library(sf)
library(dplyr)
library(readr)
library(data.table)
library(magrittr)
library(lwgeom)
library(stringi)
library(geos)
library(s2)

####### Load Support functions to use in the preprocessing of the data

source("./R/support_fun.R")




# If the data set is updated regularly, you should create a function that will have
# a `date` argument download the data

year <- 2019




###### 0. Create Root folder to save the data -----------------
# Root directory

# create dir if it has not been created already
destdir_raw <- paste0('./data_raw/biomes/', year)
if (isFALSE(dir.exists(destdir_raw))) { dir.create(destdir_raw,
                                                recursive = T,
                                                showWarnings = FALSE) }




# Create folders to save clean sf.rds files  -----------------
destdir_clean <- paste0('./data/biomes/', year)
if (isFALSE(dir.exists(destdir_clean))) { dir.create(destdir_clean,
                                                recursive = T,
                                                showWarnings = FALSE) }





#### 1. Download original data sets from source website -----------------

if ( update == 2004){
# Download and read into CSV at the same time
ftp <- 'https://geoftp.ibge.gov.br/informacoes_ambientais/estudos_ambientais/biomas/vetores/Biomas_5000mil.zip'

download.file(url = ftp,
              destfile = paste0(destdir_raw,"/","Biomas_5000mil.zip"))

}


if ( update == 2019){

ftp <- 'https://geoftp.ibge.gov.br/informacoes_ambientais/estudos_ambientais/biomas/vetores/Biomas_250mil.zip'
ftp_costeiro <- 'https://geoftp.ibge.gov.br/informacoes_ambientais/estudos_ambientais/biomas/vetores/Sistema_Costeiro_Marinho_250mil.zip'

download.file(url = ftp, destfile = paste0(destdir_raw,"/","Biomas_250mil.zip"))
download.file(url = ftp_costeiro, destfile = paste0(destdir_raw,"/","Biomas_250mil_costeiro.zip"))

}



#### 2. Unzip shape files -----------------

# list and unzip zipped files
zipfiles <- list.files(path = destdir_raw, pattern = ".zip", full.names = T)
lapply(zipfiles, unzip, exdir = destdir_raw)







#### 3. Clean data set and save it in compact .rds format-----------------

# list all csv files
shape <- list.files(path=destdir_raw,
                    full.names = T,
                    pattern = ".shp$")

# read data
if ( year == 2004){
  temp_sf <- st_read(shape, quiet = F, stringsAsFactors=F, options = "ENCODING=latin1") #Encoding usado pelo IBGE (ISO-8859-1) usa-se latin1 para ler acentos
  }

if ( year == 2019){
  temp_sf <- st_read(shape[1], quiet = F, stringsAsFactors=F)
  temp_sf_costeiro <- st_read(shape[2], quiet = F, stringsAsFactors=F)

  # make valid geometry
  temp_sf_costeiro <- st_make_valid(temp_sf_costeiro)
  # st_is_valid(temp_sf_costeiro, reason = TRUE)

}

# make valid geometry
temp_sf <- st_make_valid(temp_sf)
# st_is_valid(temp_sf, reason = TRUE)



##### 4. Rename columns -------------------------

if ( year == 2004){
  temp_sf <- dplyr::rename(temp_sf, code_biome = COD_BIOMA, name_biome = NOM_BIOMA)

  # Create columns with date and with state codes
  temp_sf$year <- year

  head(temp_sf)
}


if ( year == 2019){

  # rename columns and pile files up
  temp_sf <- dplyr::rename(temp_sf, code_biome = CD_Bioma, name_biome = Bioma)
  temp_sf$year <- year


  temp_sf_costeiro$name_biome <- "Sistema Costeiro"
  temp_sf_costeiro$code_biome <- NA
  temp_sf_costeiro$year <- year
  temp_sf_costeiro$S_COSTEIRO <- NULL

# reorder columns
setcolorder(temp_sf, neworder= c('name_biome', 'code_biome', 'year', 'geometry'))
setcolorder(temp_sf_costeiro, neworder= c('name_biome', 'code_biome', 'year', 'geometry'))

# pille them up
temp_sf <- rbind(temp_sf, temp_sf_costeiro)
}


# make valid geometry
temp_sf <- st_make_valid(temp_sf)
# st_is_valid(temp_sf, reason = TRUE)



##### 5. Check projection, UTF, topology, etc -------------------------


# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
temp_sf <- harmonize_projection(temp_sf)


# Make any invalid geometry valid # st_is_valid( sf)
temp_sf <- lwgeom::st_make_valid(temp_sf)


# Use UTF-8 encoding in all character columns
temp_sf <- temp_sf %>%
  mutate_if(is.factor, function(x){ x %>% as.character() %>%
      stringi::stri_encode("UTF-8") } )
temp_sf <- temp_sf %>%
  mutate_if(is.factor, function(x){ x %>% as.character() %>%
      stringi::stri_encode("UTF-8") } )



###### convert to MULTIPOLYGON -----------------
temp_sf <- to_multipolygon(temp_sf)

###### 6. generate a lighter version of the dataset with simplified borders -----------------
# skip this step if the dataset is made of points, regular spatial grids or rater data

# simplify
temp_sf_simplified <- st_transform(temp_sf, crs=3857) %>%
  sf::st_simplify(preserveTopology = T, dTolerance = 100) %>%
  st_transform(crs=4674)
head(temp_sf_simplified)



###### 8. Clean data set and save it in geopackage format-----------------
setwd(root_dir)


##### Save file -------------------------

# Save original and simplified datasets
readr::write_rds(temp_sf, path= paste0("./shapes_in_sf_cleaned/",year,"/biomes_", year,".rds"), compress = "gz")
sf::st_write(temp_sf, dsn= paste0("./shapes_in_sf_cleaned/",year,"/biomes_", year,".gpkg"), year = TRUE)
sf::st_write(temp_sf_simplified, dsn= paste0("./shapes_in_sf_cleaned/",year,"/biomes_", year," _simplified", ".gpkg"), update = TRUE)





