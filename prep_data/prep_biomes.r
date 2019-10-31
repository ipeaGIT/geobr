update <- 2019

library(RCurl)
library(stringr)
library(sf)
library(dplyr)
library(readr)
library(data.table)
library(magrittr)
library(lwgeom)
library(stringi)




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





getwd()


###### 0. Create Root folder to save the data -----------------
# Root directory
root_dir <- "L:\\# DIRUR #\\ASMEQ\\geobr\\data-raw"
setwd(root_dir)

# Directory to keep raw zipped files
dir.create("./biomes")


# Directory to keep raw zipped files
dir.create("./biomes")
destdir_raw <- paste0("./biomes/",update)
dir.create(destdir_raw)


# Create folders to save clean sf.rds files  -----------------
dir.create("./biomes/shapes_in_sf_cleaned", showWarnings = FALSE)
destdir_clean <- paste0("./biomes/shapes_in_sf_cleaned/",update)
dir.create(destdir_clean)





#### 0. Download original data sets from source website -----------------

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



#### 2. Unzipe shape files -----------------
setwd(destdir_raw)

# list and unzip zipped files
zipfiles <- list.files(pattern = ".zip")
lapply(zipfiles, unzip)







#### 3. Clean data set and save it in compact .rds format-----------------

# Root directory
root_dir <- "L:\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\biomes"
setwd(root_dir)


# list all csv files
shape <- list.files(path=paste0("./",update), full.names = T, pattern = ".shp$") # $ para indicar que o nome termina com .shp pois existe outro arquivo com .shp no nome

# read data
if ( update == 2004){
  temp_sf <- st_read(shape, quiet = F, stringsAsFactors=F, options = "ENCODING=latin1") #Encoding usado pelo IBGE (ISO-8859-1) usa-se latin1 para ler acentos
  }

if ( update == 2019){
  temp_sf <- st_read(shape[1], quiet = F, stringsAsFactors=F)
  temp_sf_costeiro <- st_read(shape[2], quiet = F, stringsAsFactors=F)

  }






##### Rename columns -------------------------

if ( update == 2004){
  temp_sf <- dplyr::rename(temp_sf, code_biome = COD_BIOMA, name_biome = NOM_BIOMA)

  # Create columns with date and with state codes
  temp_sf$year <- update

  head(temp_sf)
}


if ( update == 2019){

  # rename columns and pile files up
  temp_sf <- dplyr::rename(temp_sf, code_biome = CD_Bioma, name_biome = Bioma)
  temp_sf$year <- update


  temp_sf_costeiro$name_biome <- "Sistema Costeiro"
  temp_sf_costeiro$code_biome <- NA
  temp_sf_costeiro$year <- update
  temp_sf_costeiro$S_COSTEIRO <- NULL

# reorder columns
setcolorder(temp_sf, neworder= c('name_biome', 'code_biome', 'year', 'geometry'))
setcolorder(temp_sf_costeiro, neworder= c('name_biome', 'code_biome', 'year', 'geometry'))

# pille them up
temp_sf <- rbind(temp_sf, temp_sf_costeiro)
}




##### Check projection, UTF, topology, etc -------------------------


# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }
st_crs(temp_sf) <- 4674


# Make any invalid geometry valid # st_is_valid( sf)
temp_sf <- lwgeom::st_make_valid(temp_sf)


# Use UTF-8 encoding in all character columns
temp_sf <- temp_sf %>%
  mutate_if(is.factor, function(x){ x %>% as.character() %>%
      stringi::stri_encode("UTF-8") } )





##### Save file -------------------------

# Save cleaned sf in the cleaned directory
readr::write_rds(temp_sf, path= paste0("./shapes_in_sf_cleaned/",update,"/biomes_", update,".rds"), compress = "gz")






