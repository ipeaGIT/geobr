#' DATASET: Arranjos Populacionais e Concentracoes Urbanas
#' Source: IBGE
#'         - https://www.ibge.gov.br/geociencias/organizacao-do-territorio/divisao-regional/15782-arranjos-populacionais-e-concentracoes-urbanas-do-brasil.html
#'         - https://geoftp.ibge.gov.br/organizacao_do_territorio/divisao_regional/arranjos_populacionais
#'
#' scale 1:25.000
#' Metadata:
#' Titulo: Arranjos Populacionais e Concentracoes Urbanas
#' Frequencia de atualizacao: 10 anos ?
#'
#' Linguagem: Pt-BR
#' Character set: Utf-8
#'
#' Informacao do Sistema de Referencia: SIRGAS 2000

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


# If the data set is updated regularly, you should create a function that will have
# a `date` argument download the data

update <- 2015




###### 0. Create Root folder to save the data -----------------
# Root directory
root_dir <- "L:\\# DIRUR #\\ASMEQ\\geobr\\data-raw"
setwd(root_dir)


# Directory to keep raw zipped files
destdir_raw <- paste0("./pop_arrengments/", update)
dir.create(destdir_raw, recursive = T)


# Create folders to save clean sf.rds files  -----------------
destdir_clean <- paste0("./pop_arrengments/sf_cleaned/",update)
dir.create(destdir_clean, recursive = T)





#### 1. Download original data sets from source website -----------------
mannually





#### 2. Unzip shape files -----------------
setwd(destdir_raw)

# list and unzip zipped files
zipfiles <- list.files(pattern = ".zip")
lapply(zipfiles, unzip)




#### 3. Clean data set and save it in compact .rds format-----------------
setwd(destdir_raw)

      # # raw-data file
      # file <- 'ArranjosPopulacionais_2ed.mdb'
      #
      # # available
      # st_layers(file)
      #
      # # ap <- sf::st_read(file, layer = 'ArranjosPopulacionais_01')
      # # cp <- sf::st_read(file, layer = 'ConcentracoesUrbanas_ConsideradasAnalise_01')
      #
      # # # read data of municipalities
      # # mun <- sf::st_read(file, layer = 'ArranjosPopulacionais_2ed.mdb'
      # #                    # ,options = "ENCODING=ISO-8859-1"
      # #                    )

# read raw-data
mun <- sf::st_read(dsn = 'ArranjosPopulacionais_2ed.gpkg')
head(mun)



##### Rename columns -------------------------

# select / rename columns
temp_sf <- dplyr::select(mun,
                         code_muni = CodMunic,
                         name_muni = NomMunic,
                         pop_total_2010 = PopTot2010,
                         pop_urban_2010 = Pess2010Urbano,
                         pop_rural_2010 = Pess2010Rural,

                         code_pop_arrangement = CodArranjoPop ,
                         name_pop_arrangement = NomeArranjoPop ,

                         code_urban_concentration_big = CodGrandeConcUrbana ,
                         name_urban_concentration_big = NomeGrandeConcUrbana ,
                         code_urban_concentration_mid = CodMediaConcUrbana ,
                         name_urban_concentration_mid = NomeMediaConcUrbana ,
                         geom = geom
)

head(temp_sf)


##### Use UTF-8 encoding
temp_sf <- use_encoding_utf8(temp_sf)



##### create unique code for urban concentration areas
setDT(temp_sf)
temp_sf[, code_urban_concentration := code_urban_concentration_big]
temp_sf[, code_urban_concentration := fifelse(is.na(code_urban_concentration),
                                              code_urban_concentration_mid,
                                              code_urban_concentration)]

temp_sf[, name_urban_concentration := name_urban_concentration_big]
temp_sf[, name_urban_concentration := fifelse(is.na(name_urban_concentration),
                                              name_urban_concentration_mid,
                                              name_urban_concentration)]

# drop old columns
temp_sf[, c('name_urban_concentration_mid', 'name_urban_concentration_big',
            'code_urban_concentration_mid', 'code_urban_concentration_big') := NULL]


##### back to sf
temp_sf <- st_sf(temp_sf)



##### add name_state
temp_sf$code_state <- substring(temp_sf$code_muni, 1,2)
temp_sf <- add_state_info(temp_sf,column = 'code_state')
head(temp_sf)



##### Use UTF-8 encoding
temp_sf <- use_encoding_utf8(temp_sf)




##### remove Z dimension of spatial data
temp_sf <- temp_sf %>% st_sf() %>% st_zm( drop = T, what = "ZM")
head(temp_sf)




##### Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
temp_sf <- harmonize_projection(temp_sf)



##### Make an invalid geometry valid # st_is_valid( sf)
temp_sf <- sf::st_make_valid(temp_sf)



###### ARRANJOS POPULACIONAIS  -----------------------

# subset munis
df1_arranjo <- subset(temp_sf, ! is.na(code_pop_arrangement))
unique(df1_arranjo$code_pop_arrangement) %>% length()

# reorder columns
df1_arranjo <- dplyr::select(df1_arranjo, c(code_pop_arrangement, name_pop_arrangement, code_muni, name_muni, pop_total_2010, pop_urban_2010, pop_rural_2010,
                                            code_state, abbrev_state, name_state, geom))



###### simplify
df1_arranjo_simp <- simplify_temp_sf(df1_arranjo)

# convert to MULTIPOLYGON
df1_arranjo <- to_multipolygon(df1_arranjo)
df1_arranjo_simp <- to_multipolygon(df1_arranjo_simp)






###### CONCENTRACAO URBABA -----------------------

# subset munis
df2_concentr <- subset(temp_sf, ! is.na(code_urban_concentration))
unique(df2_concentr$code_urban_concentration) %>% length()

# reorder columns
df2_concentr <- dplyr::select(df2_concentr, c(code_urban_concentration, name_urban_concentration, code_muni, name_muni, pop_total_2010, pop_urban_2010, pop_rural_2010,
                                              code_state, abbrev_state, name_state, geom))



###### simplify
df2_concentr_simp <- simplify_temp_sf(df2_concentr)

# convert to MULTIPOLYGON
df2_concentr <- to_multipolygon(df2_concentr)
df2_concentr_simp <- to_multipolygon(df2_concentr_simp)


###### save -----------------------
setwd(root_dir)

sf::st_write(df2_concentr, dsn= paste0(destdir_clean,"/urban_concentrations_",update,".gpkg"))
sf::st_write(df2_concentr_simp, dsn= paste0(destdir_clean,"/urban_concentrations_",update,"_simplified.gpkg"))

sf::st_write(df1_arranjo, dsn= paste0(destdir_clean,"/pop_arrengements_",update,".gpkg"))
sf::st_write(df1_arranjo_simp, dsn= paste0(destdir_clean,"/pop_arrengements_",update,"_simplified.gpkg"))






