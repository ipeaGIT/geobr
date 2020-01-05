update <- 2012

library(RCurl)
library(stringr)
library(sf)
library(dplyr)
library(readr)
library(data.table)
library(magrittr)
library(lwgeom)
library(stringi)




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





getwd()


###### 0. Create Root folder to save the data -----------------
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





#### 0. Download original data sets from source website -----------------

# Download and read into CSV at the same time
ftp_shp <- 'http://mapas.mma.gov.br/ms_tmp/amazonia_legal.shp'
ftp_shx <- 'http://mapas.mma.gov.br/ms_tmp/amazonia_legal.shx'
ftp_dbf <- 'http://mapas.mma.gov.br/ms_tmp/amazonia_legal.dbf'
ftp <- c(ftp_shp,ftp_shx,ftp_dbf)
aux_ft <- c("shp","shx","dbf")

for(i in 1:length(ftp)){
  download.file(url = ftp[i],
                destfile = paste0(destdir_raw,"/","amazonia_legal.",aux_ft[i]) )
}






#### 2. Unzipe shape files -----------------
setwd(destdir_raw)

# list and unzip zipped files
#zipfiles <- list.files(pattern = ".zip")
#unzip(zipfiles)








#### 3. Clean data set and save it in compact .rds format-----------------


# read data
temp_sf <- st_read("./amazonia_legal.shp", quiet = F, stringsAsFactors=F)


# Rename columns
temp_sf$GID0 <- NULL


# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }
st_crs(temp_sf)


# Make any invalid geometry valid # st_is_valid( sf)
temp_sf <- lwgeom::st_make_valid(temp_sf)


# Save cleaned sf in the cleaned directory
setwd(root_dir)
readr::write_rds(temp_sf, path= paste0(destdir_clean,"/amazonia_legal",".rds"), compress = "gz")


