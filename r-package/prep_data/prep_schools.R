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
library(ggplot2)

mapviewOptions(platform = 'leafgl')
# mapviewOptions(platform = 'mapdeck')

####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")

# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw"
setwd(root_dir)



###### 0. Create folders to save the data -----------------

# If the data set is updated regularly, you should create a function that will have
# a `date` argument download the data
update <- 2020
date_update <- '2020-10-18'


# Root directory
root_dir <- "L:\\# DIRUR #\\ASMEQ\\geobr\\data-raw"
setwd(root_dir)

# Directory to keep raw zipped files
dir.create("./schools")
destdir_raw <- paste0("./schools/",update)
dir.create(destdir_raw)




#### 1. Download manual do dado -----------------


# download manual do dado a partir de


# leitura do dado bruto
df <- fread('C:/Users/r1701707/Downloads/Análise - Tabela da lista das escolas - Detalhado (1).csv',
            encoding = 'UTF-8')

head(df)






##### 4. Rename columns -------------------------
df$date_update <- date_update


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
                regulated_education_council = 'Regulamentação pelo Conselho de Educação',
                service_restriction ='Restrição de Atendimento',
                size = 'Porte da Escola',
                urban = 'Localização',
                location_type = 'Localidade Diferenciada',
                date_update = 'date_update',
                y = 'Latitude',
                x = 'Longitude'
  )

head(df2)




# fix spatial coordinates
summary(df2$x)
temp_sf <- sfheaders::sf_point(df2, x='x', y='y', keep = T)
# temp_sf <- sfheaders::sf_point(subset(df2, !is.na(x)), x='x', y='y', keep = T)


# temp_sf = st_as_sf(subset(df2, !is.na(x)), coords = c("x", "y"))



country <- geobr::read_country()
sirgas <- st_crs(country)
st_crs(temp_sf) <- sirgas
st_crs(temp_sf) <- 4674

# st_crs(temp_sf)
# head(temp_sf)
#
# a <- temp_sf[1:100,]
#
# plot(a)
mapview(temp_sf)

ggplot() +
  geom_sf(data= country) +
  geom_sf(data= temp_sf)


##### Save file -------------------------

# save raw file
fwrite(df, paste0(destdir_raw, '/schools_', update, '_raw.csv'))

# Save sf
sf::st_write(temp_sf, dsn= paste0(destdir_raw ,"/schools_", update,".gpkg"), update = TRUE)




