update <- 2006

library(RCurl)
library(stringr)
library(sf)
library(dplyr)
library(readr)
library(data.table)
library(magrittr)
library(lwgeom)
library(stringi)




#> DATASET: biomes 2004
#> Source: IBGE - https://geoftp.ibge.gov.br/informacoes_ambientais/estudos_ambientais/biomas/
#> Metadata:
# Titulo: Biomas 
# Titulo alternativo: Biomas 2004
# Data: Atualização Mensal
#
# Forma de apresentaÃ§Ã£o: Shape
# Linguagem: Pt-BR
# Character set: Utf-8
#
# Resumo: Polígonos e Pontos do biomas brasileiros.
# InformaÃ§Ãµes adicionais: Dados produzidos pelo IBGE, e utilizados na elaboração do shape de biomas com a melhor base oficial disponível.
# Propósito: Identificação dos biomas brasileiros.
#
# Estado: Em desenvolvimento
# Palavras chaves descritivas:****
# Informação do Sistema de Referência: SIRGAS 2000





getwd()


###### 0. Create Root folder to save the data -----------------
# Root directory
root_dir <- "L:/# IPEADATA_LAB #/projetos/ASMEQ"
setwd(root_dir)

# Directory to keep raw zipped files
dir.create("./biomes")
destdir_raw <- paste0("./biomes/",update)
dir.create(destdir_raw)


# Create folders to save clean sf.rds files  -----------------
dir.create("./biomes/shapes_in_sf_2004_cleaned", showWarnings = FALSE)
destdir_clean <- paste0("./biomes/shapes_in_sf_2004_cleaned/",update)
dir.create(destdir_clean)





#### 0. Download original data sets from FUNAI website -----------------

# Download and read into CSV at the same time
ftp <- 'https://geoftp.ibge.gov.br/informacoes_ambientais/estudos_ambientais/biomas/vetores/Biomas_5000mil.zip'

download.file(url = ftp,
              destfile = paste0(destdir_raw,"/","Biomas_5000mil.zip"))





#### 2. Unzipe shape files -----------------
setwd(destdir_raw)

# list and unzip zipped files
zipfiles <- list.files(pattern = ".zip")
unzip(zipfiles)








#### 3. Clean data set and save it in compact .rds format-----------------

# Root directory
root_dir <- "L:/# IPEADATA_LAB #/projetos/ASMEQ/biomes"
setwd(root_dir)


# list all csv files
shape <- list.files(path=paste0("./",update), full.names = T, pattern = ".shp$") # $ para indicar que o nome termina com .shp pois existe outro arquivo com .shp no nome

# read data
temp_sf <- st_read(shape, quiet = F, stringsAsFactors=F, options = "ENCODING=latin1") #Encoding usado pelo IBGE (ISO-8859-1) usa-se latin1 para ler acentos



# Rename columns
temp_sf <- dplyr::rename(temp_sf, code_biome = COD_BIOMA, name_biome = NOM_BIOMA)
head(temp_sf)


# store original CRS
original_crs <- st_crs(temp_sf)

# Create columns with date and with state codes
setDT(temp_sf)[, date := update]


# Convert data.table back into sf
temp_sf <- st_as_sf(temp_sf, crs=original_crs)


# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }


# Make any invalid geometry valid # st_is_valid( sf)
temp_sf <- lwgeom::st_make_valid(temp_sf)



# Save cleaned sf in the cleaned directory
readr::write_rds(temp_sf, path=paste0("./shapes_in_sf_2004_cleaned/",update,"/biomes_", update,".rds"), compress = "gz")






