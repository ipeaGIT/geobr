#> DATASET: indigenous Lands
#> Source: FUNAI - http://www.funai.gov.br/index.php/shape
#> Metadata:
  # Titulo: Terras Indígenas  / Terras Indígenas em Estudos
  # Titulo alternativo: Terras Indígenas
  # Data: Atualização Mensal
  #
  # Forma de apresentação: Shape
  # Linguagem: Pt-BR
  # Character set: Utf-8
  #
  # Resumo: Polígonos e Pontos das terras indígenas brasileiras.
  # Informações adicionais: Dados produzidos pela FUNAI, e utilizados na elaboração do shape de terras indígenas com a melhor base oficial disponível.
  # Propósito: Identificação das terras indígenas brasileiras.
  #
  # Estado: Completado
  # Palavras chaves descritivas:Terras Indígenas, Áreas Indígenas do Brasil, Áreas Indígenas, FUNAI, Ministério da Justiça (tema).
  # Informação do Sistema de Referência: SIRGAS 2000



####### Load Support functions to use in the preprocessing of the data -----------------
source("./prep_data/prep_functions.R")


# To Update the data, input the date YYYYMM and run the code

update <- 201909

library(RCurl)
library(stringr)
library(sf)
library(dplyr)
library(readr)
library(data.table)
library(magrittr)
library(lwgeom)
library(stringi)

####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")

###### 0. Create Root folder to save the data -----------------
# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw"
setwd(root_dir)

# Directory to keep raw zipped files
  dir.create("./indigenous_land")
  destdir_raw <- paste0("./indigenous_land/",update)
  dir.create(destdir_raw)


# Create folders to save clean sf.rds files  -----------------
  dir.create("./indigenous_land/shapes_in_sf_all_years_cleaned", showWarnings = FALSE)
  destdir_clean <- paste0("./indigenous_land/shapes_in_sf_all_years_cleaned/",update)
  dir.create(destdir_clean)





#### 1. Download original data sets from FUNAI website -----------------

# Download and read into CSV at the same time
  ftp <- "http://mapas2.funai.gov.br/portal_mapas/shapes/ti_sirgas.zip"

  download.file(url = ftp,
                destfile = paste0(destdir_raw,"/","indigenous_land.zip"))





#### 2. Unzipe shape files -----------------
  setwd(destdir_raw)

  # list and unzip zipped files
  zipfiles <- list.files(pattern = ".zip")
  unzip(zipfiles)








#### 3. Clean data set and save it in compact .rds format-----------------

# Root directory
  root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//indigenous_land"
  setwd(root_dir)


# list all csv files
  shape <- list.files(path=paste0("./",update), full.names = T, pattern = ".shp")

# read data
  temp_sf <- st_read(shape, quiet = F, stringsAsFactors=F, options = "ENCODING=UTF8")


# Rename columns
  temp_sf <- dplyr::rename(temp_sf, abbrev_state = uf_sigla, name_muni = municipio_, code_terrai= terrai_cod)
  head(temp_sf)


# store original CRS
  original_crs <- st_crs(temp_sf)

# Create columns with date and with state codes
  setDT(temp_sf)[, date := update]

# Create column with state abbreviations
  temp_sf[ abbrev_state=="RO", code_state :=	11 ]
  temp_sf[ abbrev_state=="AC", code_state :=	12 ]
  temp_sf[ abbrev_state=="AM", code_state :=	13 ]
  temp_sf[ abbrev_state=="RR", code_state :=	14 ]
  temp_sf[ abbrev_state=="PA", code_state :=	15 ]
  temp_sf[ abbrev_state=="AP", code_state :=	16 ]
  temp_sf[ abbrev_state=="TO", code_state :=	17 ]
  temp_sf[ abbrev_state=="MA", code_state :=	21 ]
  temp_sf[ abbrev_state=="PI", code_state :=	22 ]
  temp_sf[ abbrev_state=="CE", code_state :=	23 ]
  temp_sf[ abbrev_state=="RN", code_state :=	24 ]
  temp_sf[ abbrev_state=="PB", code_state :=	25 ]
  temp_sf[ abbrev_state=="PE", code_state :=	26 ]
  temp_sf[ abbrev_state=="AL", code_state :=	27 ]
  temp_sf[ abbrev_state=="SE", code_state :=	28 ]
  temp_sf[ abbrev_state=="BA", code_state :=	29 ]
  temp_sf[ abbrev_state=="MG", code_state :=	31 ]
  temp_sf[ abbrev_state=="ES", code_state :=	32 ]
  temp_sf[ abbrev_state=="RJ", code_state :=	33 ]
  temp_sf[ abbrev_state=="SP", code_state :=	35 ]
  temp_sf[ abbrev_state=="PR", code_state :=	41 ]
  temp_sf[ abbrev_state=="SC", code_state :=	42 ]
  temp_sf[ abbrev_state=="RS", code_state :=	43 ]
  temp_sf[ abbrev_state=="MS", code_state :=	50 ]
  temp_sf[ abbrev_state=="MT", code_state :=	51 ]
  temp_sf[ abbrev_state=="GO", code_state :=	52 ]
  temp_sf[ abbrev_state=="DF", code_state :=	53 ]
  head(temp_sf)



# Convert data.table back into sf
  temp_sf <- st_as_sf(temp_sf, crs=original_crs)


  # # Use UTF-8 encoding
  # temp_sf$name_state <- stringi::stri_encode(as.character((temp_sf$name_state), "UTF-8"))


# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
  temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }


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


###### 7. generate a lighter version of the dataset with simplified borders -----------------
# skip this step if the dataset is made of points, regular spatial grids or rater data

# simplify
  temp_sf_simplified <- st_transform(temp_sf, crs=3857) %>%
    sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)


# Save cleaned sf in the cleaned directory
  readr::write_rds(temp_sf, path=paste0("./shapes_in_sf_all_years_cleaned/",update,"/indigenous_land_", update,".rds"), compress = "gz")
  sf::st_write(temp_sf, dsn = paste0("./shapes_in_sf_all_years_cleaned/",update,"/indigenous_land_", update,".gpkg") )
  sf::st_write(temp_sf_simplified, dsn = paste0("./shapes_in_sf_all_years_cleaned/",update,"/indigenous_land_", update,"_simplified.gpkg") )




