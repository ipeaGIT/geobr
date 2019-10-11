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
# -"Resolução Nº 115, de 23 de novembro de 2017, do Ministério da Integração Nacional"
# -"Portaria N°89 de 16 de março de 2005, do Ministério da Integração Nacional"
# Proposito: Identificao do semiarido brasileiro.

# Estado: Em desenvolvimento
# Informacao do Sistema de Referencia: SIRGAS 2000




library(RCurl)
library(stringr)
library(sf)
library(dplyr)
library(readr)
library(data.table)
library(magrittr)
library(lwgeom)
library(stringi)


###### 0. Create Root folder to save the data -----------------

# Root directory
root_dir <- "L:\\# DIRUR #\\ASMEQ\\geobr\\data-raw"
setwd(root_dir)

for (in in c(2015, 2017)){
# Directory to keep raw zipped files
dir.create("./semiarid")
destdir_raw <- paste0("./semiarid/",update)
dir.create(destdir_raw)


# Create folders to save clean sf.rds files

dir.create("./semiarid/shapes_in_sf_cleaned", showWarnings = FALSE)
destdir_clean <- paste0("./semiarid/shapes_in_sf_cleaned/",update)
dir.create(destdir_clean)

}




#### 2. Download original data sets from source website -----------------

# Download and read into CSV at the same time
ftp_2017 <- 'ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/semiarido_brasileiro/Situacao_23nov2017/lista_municipios_Semiarido_2017_11_23.xlsx'

ftp_2015 <- 'ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/semiarido_brasileiro/Situacao_2005a2017/lista_municipios_semiarido.xls'


download.file(url = ftp_2017,
              destfile = paste0(destdir_raw,"/","lista_municipios_semiarido.xlsx") )

download.file(url = ftp_2017,
              destfile = paste0(destdir_raw,"/","lista_municipios_semiarido.xlsx") )



#### 3. Clean data set and save it in compact .rds format-----------------


# read IBGE data frame
semi_arid_munis <- readxl::read_xlsx(path = paste0(destdir_raw,"/","lista_municipios_semiarido.xlsx"),
                                     skip = 1)
na.exclude(semi_arid_munis)
colnames(semi_arid_munis) <- c("code_state","name_state","code_muni","name_muni","year_muni")

# load all munis sf
all_munis <- geobr::read_municipality(code_muni = 'all', year=2017)

# subset
semi_arid_sf <- subset(all_munis, code_muni %in% semi_arid_munis$code_muni)


# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
semi_arid_sf <- if( is.na(st_crs(semi_arid_sf)) ){ st_set_crs(semi_arid_sf, 4674) } else { st_transform(semi_arid_sf, 4674) }
st_crs(semi_arid_sf)


# Make any invalid geometry valid # st_is_valid( sf)
semi_arid_sf <- lwgeom::st_make_valid(semi_arid_sf)


# Save cleaned sf in the cleaned directory
setwd(root_dir)
readr::write_rds(semi_arid_sf, path= paste0(destdir_clean,"/semiarid",".rds"), compress = "gz")

