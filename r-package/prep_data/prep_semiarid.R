#> DATASET: Brazilian semi-arid
#> Source: IBGE - https://www.ibge.gov.br/geociencias/cartas-e-mapas/mapas-regionais/15974-semiarido-brasileiro.html?=&t=downloads
#> Metadata:
# Titulo: Semiarido brasileiro
# Titulo alternativo: Semiarido brasileiro
# Frequencia de atualizacao: ?
#
# Forma de apresentacao: Shape
# Linguagem: Pt-BR
# Character set: Utf-8
#
# Resumo: Poligonos e Pontos do semiarido brasileiro.
# Informacoes adicionais: Dados produzidos pelo IBGE com base em decretos administrativos do Ministério da Integração Nacional.
# -"Resolução nº 115 do Ministério da Integração Nacional, de 23 de novembro de 2017"
# -"Portaria N°89 de 16 de março de 2005, do Ministério da Integração Nacional"
# Proposito: Identificao do semiarido brasileiro.

# Estado: Em desenvolvimento
# Informacao do Sistema de Referencia: SIRGAS 2000

### Libraries (use any library as necessary)

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
root_dir <- "L:\\# DIRUR #\\ASMEQ\\geobr\\data-raw"
setwd(root_dir)


# Directory to keep raw zipped files
dir.create("./semiarid")
dir_raw_2005 <- paste0("./semiarid/", 2005)
dir_raw_2017 <- paste0("./semiarid/", 2017)

dir.create(dir_raw_2005)
dir.create(dir_raw_2017)

# Create folders to save clean sf.rds files
dir.create("./semiarid/shapes_in_sf_cleaned", showWarnings = FALSE)
dir_clean_2005 <- paste0("./semiarid/shapes_in_sf_cleaned/", 2005)
dir_clean_2017 <- paste0("./semiarid/shapes_in_sf_cleaned/", 2017)
dir.create(dir_clean_2005)
dir.create(dir_clean_2017)



#### 2. Download original data sets from source website -----------------

# Download and read into CSV at the same time
ftp_2005 <- 'ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/semiarido_brasileiro/Situacao_2005a2017/lista_municipios_semiarido.xls'
ftp_2017 <- 'ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/semiarido_brasileiro/Situacao_23nov2017/lista_municipios_Semiarido_2017_11_23.xlsx'


# 2005
download.file(url = ftp_2005, destfile = paste0(dir_raw_2005,"/","lista_municipios_semiarido.xls"), mode = 'wb')

# httr::GET(url=ftp_2005, httr::progress(),
#           httr::write_disk(paste0(dir_raw_2005,"/","lista_municipios_semiarido.xlsx")))

# 2017
download.file(url = ftp_2017,
              destfile = paste0(dir_raw_2017,"/","lista_municipios_semiarido.xlsx") , mode = 'wb')



#### 3. 2005 Clean data set and save it in compact .rds format-----------------

# read IBGE data frame
semi_arid_munis <- readxl::read_xls(path = paste0(dir_raw_2005,"/","lista_municipios_semiarido.xls"),
                                     skip = 1, n_max = 1133)
semi_arid_munis <- as.data.frame(semi_arid_munis)


# Remove linha con info da fonte de dados
# semi_arid_munis[1263,1]
# semi_arid_munis <- na.exclude(semi_arid_munis)


# Rename columns
colnames(semi_arid_munis) <- c("code_state","name_state","code_muni","name_muni","year_muni")


# load all munis sf
all_munis <- geobr::read_municipality(code_muni = 'all', year=2005)



# subset municipalities
semi_arid_sf <- subset(all_munis, code_muni %in% semi_arid_munis$code_muni)


# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
semi_arid_sf <- if( is.na(st_crs(semi_arid_sf)) ){ st_set_crs(semi_arid_sf, 4674) } else { st_transform(semi_arid_sf, 4674) }
st_crs(semi_arid_sf) <- 4674


# Make any invalid geometry valid # st_is_valid( sf)
semi_arid_sf <- lwgeom::st_make_valid(semi_arid_sf)


# Save cleaned sf in the cleaned directory
setwd(root_dir)
readr::write_rds(semi_arid_sf, path= paste0(dir_clean_2005,"/semiarid_2005",".rds"), compress = "gz")




#### 3. 2017 Clean data set and save it in compact .rds format-----------------


# read IBGE data frame
semi_arid_munis <- readxl::read_xlsx(path = paste0(dir_raw_2017,"/","lista_municipios_semiarido.xlsx"),
                                     skip = 1, n_max = 1262)
semi_arid_munis <- as.data.frame(semi_arid_munis)

# Remove linha con info da fonte de dados
#semi_arid_munis[1263,1]
#semi_arid_munis <- na.exclude(semi_arid_munis)



# Rename columns
colnames(semi_arid_munis) <- c("code_state","name_state","code_muni","name_muni","year_muni")


# load all munis sf
all_munis <- geobr::read_municipality(code_muni = 'all', year=2017)



# subset municipalities
semi_arid_sf <- subset(all_munis, code_muni %in% semi_arid_munis$code_muni)


# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
semi_arid_sf <- if( is.na(st_crs(semi_arid_sf)) ){ st_set_crs(semi_arid_sf, 4674) } else { st_transform(semi_arid_sf, 4674) }
st_crs(semi_arid_sf) <- 4674

# Make any invalid geometry valid # st_is_valid( sf)
semi_arid_sf <- lwgeom::st_make_valid(semi_arid_sf)

###### 6. generate a lighter version of the dataset with simplified borders -----------------
# skip this step if the dataset is made of points, regular spatial grids or rater data

# simplify
semi_arid_sf_simplified <- st_transform(semi_arid_sf, crs=3857) %>% 
  sf::st_simplify(preserveTopology = T, dTolerance = 100) %>%
  st_transform(crs=4674)
head(semi_arid_sf_simplified)

# Save cleaned sf in the cleaned directory
setwd(root_dir)
readr::write_rds(semi_arid_sf, path= paste0(dir_clean_2017,"/semiarid_2017",".rds"), compress = "gz")
sf::st_write(semi_arid_sf, dsn= paste0(dir_clean_2017,"/semiarid_2017",".gpkg") )
sf::st_write(semi_arid_sf_simplified, dsn= paste0(dir_clean_2017,"/semiarid_2017"," _simplified", ".gpkg"))

