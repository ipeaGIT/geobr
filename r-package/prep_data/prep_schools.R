#> DATASET: schools 2020
#> Source: INEP - http://portal.inep.gov.br/web/guest/dados/catalogo-de-escolas
#: scale
#> Metadata:
# Titulo: schools
#' Frequencia de atualizacao: anual
#'
#' Forma de apresentação: Shape
#' Linguagem: Pt-BR
#' Character set: Utf-8
#'
#' Resumo: Pontos com coordenadas gegráficas das escolas do censo escolar
#' Informações adicionais: Dados produzidos pelo INEP. Os dados de escolas e sua
#' geolocalização são atualizados pelo INEP continuamente. Para finalidade do geobr,
#' esses dados precisam ser baixados uma vez ao ano
#

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
library(sfheaders)
library(mapview)

mapviewOptions(platform = 'leafgl')
mapviewOptions(platform = 'mapdeck')

####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")




# If the data set is updated regularly, you should create a function that will have
# a `date` argument download the data

update <- 2020

# download manual do dado a partir de

df <- fread('C:/Users/user/Downloads/Análise - Tabela da lista das escolas - Detalhado (1).csv',
            encoding = 'UTF-8')

head(df)

###### 0. Create Root folder to save the data -----------------
# Root directory
root_dir <- "L:\\# DIRUR #\\ASMEQ\\geobr\\data-raw"
setwd(root_dir)

# Directory to keep raw zipped files
dir.create("./schools")
destdir_raw <- paste0("./schools/",update)
dir.create(destdir_raw)


# Create folders to save clean sf.rds files  -----------------
destdir_clean <- paste0("./schools/clean/",update)
dir.create(destdir_clean)





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





setwd(destdir_raw)


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






##### 4. Rename columns -------------------------

s <- geobr::read_municipality()
s
head(df)

df2 <-
  dplyr::select(df,
                abbrev_state = 'UF',
                name_muni = 'Município',
                code_school = 'Código INEP',
                name_school = 'Escola',
                education_level = 'Etapas e Modalidade de Ensino Oferecidas',
                education_level_others = 'Outras Ofertas Educacionais',
                admin_category = 'Categoria Administrativa',
                address = 'Endereço',
                phone_number = 'Telefone',
                government_level = 'Dependência Administrativa',
                private_school_type = 'Categoria Escola Privada',
                private_government_partnership = 'Conveniada Poder Público',
                regulated_education_counsil = 'Regulamentação pelo Conselho de Educação',
                service_restriction ='Restrição de Atendimento',
                size = 'Porte da Escola',
                urban = 'Localização',
                location_type = 'Localidade Diferenciada',
                y = 'Latitude',
                x = 'Longitude'
  )


##### Recode columns


table(df2$urban, useNA = 'always')


# fix spatial coordinates
summary(df2$x)
schools_sf <- sfheaders::sf_point(df2, x='x', y='y', keep = T)
schools_sf <- sfheaders::sf_point(subset(df2, is.na(x)), x='x', y='y', keep = T)



sirgas <- st_crs(geobr::read_amazon())
st_crs(schools_sf) <- sirgas
st_crs(schools_sf) <- 4674

st_crs(schools_sf)
head(schools_sf)

a <- schools_sf[1:5,]

plot(a)
mapview(a)


###### 8. Clean data set and save it in geopackage format-----------------
setwd(root_dir)


##### Save file -------------------------

# Save original and simplified datasets
readr::write_rds(temp_sf, path= paste0("./shapes_in_sf_cleaned/",update,"/biomes_", update,".rds"), compress = "gz")
sf::st_write(temp_sf, dsn= paste0("./shapes_in_sf_cleaned/",update,"/biomes_", update,".gpkg"), update = TRUE)
sf::st_write(temp_sf_simplified, dsn= paste0("./shapes_in_sf_cleaned/",update,"/biomes_", update," _simplified", ".gpkg"), update = TRUE)





