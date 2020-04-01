#> DATASET: legal amazon
#> Source: MMA - http://mapas.mma.gov.br/i3geo/datadownload.htm
#> Metadata:
# Titulo: Amzonia legal
# Titulo alternativo: Amazonia legal
# Frequencia de atualizacao: ?
#
# Forma de apresentacao: Shape
# Linguagem: Pt-BR
# Character set: Utf-8
#
# Resumo: Poligonos e Pontos da amzonia legal brasileia.
# Informacoees adicionais: Dados produzidos pelo MMA com base na legal que consta no código florestal (lei 12.651).
# Proposito: Identificao da Amazonia lega.
#
# Estado: Em desenvolvimento
# Palavras chaves descritivas:****
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




# If the data set is updated regularly, you should create a function that will have
# a `date` argument download the data

update <- 2012



###### 0. Create directories to downlod and save the data -----------------

# Root directory
root_dir <- "L:\\# DIRUR #\\ASMEQ\\geobr\\data-raw"
setwd(root_dir)

# Directory to keep raw zipped files
dir.create("./amazonia_legal")
destdir_raw <- paste0("./amazonia_legal/",update)
dir.create(destdir_raw)


# Create folders to save clean sf.rds files  -----------------
dir.create("./amazonia_legal/shapes_in_sf_cleaned", showWarnings = FALSE)
destdir_clean <- paste0("./amazonia_legal/shapes_in_sf_cleaned/",update)
dir.create(destdir_clean)





###### 1. download the raw data from the original website source -----------------

# Download and read into CSV at the same time
ftp_shp <- 'http://mapas.mma.gov.br/ms_tmp/amazlegal.shp'
ftp_shx <- 'http://mapas.mma.gov.br/ms_tmp/amazlegal.shx'
ftp_dbf <- 'http://mapas.mma.gov.br/ms_tmp/amazlegal.dbf'
ftp <- c(ftp_shp,ftp_shx,ftp_dbf)
aux_ft <- c("shp","shx","dbf")

for(i in 1:length(ftp)){

    # download.file(url = ftp[i],
    #               destfile = paste0(destdir_raw,"/","amazonia_legal.",aux_ft[i]) )
  httr::GET(url=ftp[i],
            httr::write_disk(path=paste0(destdir_raw,"/","amazonia_legal.",aux_ft[i]), overwrite = F))

  }





###### 2. rename column names -----------------
setwd(destdir_raw)

# read data
temp_sf <- sf::st_read("./amazonia_legal.shp", quiet = F, stringsAsFactors=F)


# Rename columns
temp_sf$GID0 <- NULL
temp_sf$ID1 <- NULL



###### 3. ensure the data uses spatial projection SIRGAS 2000 epsg (SRID): 4674-----------------

temp_sf3 <- harmonize_projection(temp_sf)

# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }
st_crs(temp_sf)

st_crs(temp_sf3)$epsg
st_crs(temp_sf3)$input
st_crs(temp_sf3)$proj4string
st_crs(st_crs(temp_sf3)$wkt) == st_crs(temp_sf3)




###### 4. ensure every string column is as.character with UTF-8 encoding -----------------

# not necessary here



###### 5. remove Z dimension of spatial data-----------------

# remove Z dimension of spatial data
temp_sf5 <- temp_sf3 %>% st_sf() %>% st_zm( drop = T, what = "ZM")



###### 6. fix eventual topology issues in the data-----------------

# Make any invalid geometry valid # st_is_valid( sf)
temp_sf6 <- lwgeom::st_make_valid(temp_sf5)


###### 7. generate a lighter version of the dataset with simplified borders -----------------
# skip this step if the dataset is made of points, regular spatial grids or rater data

# simplify
temp_sf7 <- simplify_temp_sf(temp_sf6)
head(temp_sf7)



###### 8. Clean data set and save it in geopackage format-----------------
setwd(root_dir)

# save original and simplified datasets
sf::st_write(temp_sf6, dsn= paste0(destdir_clean, "/amazonia_legal_", update, ".gpkg") )
sf::st_write(temp_sf7, dsn= paste0(destdir_clean, "/amazonia_legal_", update," _simplified", ".gpkg"))


