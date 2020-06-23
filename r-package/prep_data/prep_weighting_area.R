### Libraries (use any library as necessary)

library(RCurl)
library(dplyr)
library(stringr)
library(sf)
library(magrittr)
library(data.table)
library(parallel)
library(lwgeom)
library(readr)
library(furrr)
library(future)



####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")

#### 0. Download original data sets from IBGE ftp -----------------

ftp <- "ftp://geoftp.ibge.gov.br/recortes_para_fins_estatisticos/areas_de_ponderacao/"

########  1. Unzip original data sets downloaded from IBGE -----------------

# Root directory
root_geobr <- getwd()
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//areas_de_ponderacao"
setwd(root_dir)

# List all zip files for all years
all_zipped_files <- list.files(full.names = T, recursive = T, pattern = ".zip")

#### 1.1. Municipios sem area redefinidas --------------
files_1st_batch <- all_zipped_files[!all_zipped_files %like% "municipios_areas_redefinidas"]

# function to Unzip files in their original sub-dir
unzip_fun1 <- function(f){
    unzip(f, exdir = file.path(root_dir, substr(f, 2, 24)))
}

# apply function in parallel
plan(multiprocess)
furrr::future_map(.x=files_1st_batch, .f=unzip_fun1)

gc(reset = T)

#### 1.2. Municipios  area redefinidas --------------
files_2st_batch <- all_zipped_files[all_zipped_files %like% "municipios_areas_redefinidas"]

## excluindo as areas redefinidas de Pelotas e de Ponta Grossa, dados corrompidos
files_2st_batch <- files_2st_batch[!files_2st_batch %like% "Pelotas|Ponta_Grossa"]

# function to Unzip files in their original sub-dir
unzip_fun2 <- function(f){

  unzip(f, exdir = file.path(root_dir, substr(f, 2, 53) ))
}


# apply function in parallel
furrr::future_map(.x=files_2st_batch, .f=unzip_fun2)
gc(reset = T)



#### 2. Create folders to save sf.rds files  -----------------

# create directory to save original shape files in sf format
  dir.create(file.path("shapes_in_sf_all_years_original"), showWarnings = FALSE)

# create directory to save cleaned shape files in sf format
  dir.create(file.path("shapes_in_sf_all_years_cleaned"), showWarnings = FALSE)

# create a subdirectory of year
dir.create(file.path("shapes_in_sf_all_years_original","2010"), showWarnings = FALSE)

dir.create(file.path("shapes_in_sf_all_years_cleaned", "2010"), showWarnings = FALSE)

# create a subdirectory of municipios_areas_redefinidas
dir.create(file.path("shapes_in_sf_all_years_original", "2010","municipios_areas_redefinidas"), showWarnings = FALSE)

dir.create(file.path("shapes_in_sf_all_years_cleaned","2010","municipios_areas_redefinidas"), showWarnings = FALSE)



#### 3. Save original data sets downloaded from IBGE in compact .rds format-----------------

# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//areas_de_ponderacao"
setwd(root_dir)

# renomeando Boa Vista, não tem .shp
file.rename("L:/# DIRUR #/ASMEQ/geobr/data-raw/areas_de_ponderacao/censo_demografico_2010/14_RR_Roraima/Boa_Vista_area de ponderacao",
            "L:/# DIRUR #/ASMEQ/geobr/data-raw/areas_de_ponderacao/censo_demografico_2010/14_RR_Roraima/Boa_Vista_area de ponderacao.shp")


# List shapes for all years
all_shapes <- list.files(full.names = T, recursive = T, pattern = ".shp$")

shp_to_sf_rds <- function(x){ # x <- all_shapes[1]

  shape <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")

  # name of the file that will be saved
  if( !x %like% "municipios_areas_redefinidas"){ dest_dir <- "./shapes_in_sf_all_years_original/2010"}

  if( x %like% "municipios_areas_redefinidas"){ dest_dir <- "./shapes_in_sf_all_years_original/2010/municipios_areas_redefinidas"}

  file_name <- paste0(str_replace(unlist(str_split(x,"/"))[4],".shp",""), ".rds")

  # save in .rds
    readr::write_rds(shape, path = paste0(dest_dir,"/", file_name), compress="gz" )

}

# Apply function to save original data sets in rds format
furrr::future_map(.x=all_shapes, .f=shp_to_sf_rds)






###### 4. Cleaning weighting area files --------------------------------

# get dirs with sf original data
  uf_dir <- "./shapes_in_sf_all_years_original"
  sub_dirs <- list.dirs(path =uf_dir, recursive = F, full.names = T)

# list all sf files in that year/folder
  sf_files <- list.files(sub_dirs, full.names = T,recursive = T)

# Exlcuindo base duplicada do estado de sao paulo
  sf_files <- sf_files[ !(sf_files %like% "35SEE250GC_SIR_area_de_ponderacao.rds")]

# Remove areas definidas para evitar duplicacao
   sf_files <- sf_files[!(sf_files %like% 'municipios_areas_redefinidas')]
  # areas_redefinidas <- sf_files[sf_files %like% 'municipios_areas_redefinidas']
  # sf_files <- sf_files[! (sf_files %like% '2010/Caxias_do_Sul_area_de_ponderacao|2010/FEIRA_DE_SANTANA_area_de_ponderacao|2010/IMPERATRIZ_area_de_ponderacao|2010/MARINGA_area_de_ponderacao|2010/NATAL_area_de_ponderacao|2010/NOVO HAMBURGO_area de ponderacao|2010/PORTO ALEGRE_area de ponderacao|2010/RIO DE JANEIRO_area de ponderacao|2010/RIO GRANDE_area de ponderacao|2010/SALVADOR_area de ponderacao|2010/SANTA MARIA_area de ponderacao|2010/VIAMAO_area de ponderacao|2010/FEIRA DE SANTANA_area de ponderacao')]

'2010/Caxias_do_Sul_area_de_ponderacao.rds'
'2010/FEIRA_DE_SANTANA_area_de_ponderacao.rds'
'2010/IMPERATRIZ_area_de_ponderacao.rds'
'2010/MARINGA_area_de_ponderacao.rds'
'2010/NATAL_area_de_ponderacao.rds'
'2010/NOVO HAMBURGO_area de ponderacao.rds'
'2010/PORTO ALEGRE_area de ponderacao.rds'
'2010/RIO DE JANEIRO_area de ponderacao.rds'
'2010/RIO GRANDE_area de ponderacao.rds'
'2010/SALVADOR_area de ponderacao.rds'
'2010/SANTA MARIA_area de ponderacao.rds'
'2010/VIAMAO_area de ponderacao.rds'



# Function to clean data
clean_weighting_area <- function( i ){  # i <- sf_files[50]
                                        # i <- sf_files[sf_files %like% "SALVADOR"]

    # read sf file
    temp_sf <- readr::read_rds(i)

    # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      colnames(temp_sf)[colnames(temp_sf) %in% c("cd_aponde","area_pond")] <- "code_weighting_area"
      temp_sf <- dplyr::select(temp_sf, c('code_weighting_area', 'geometry'))
      temp_sf <- dplyr::mutate(temp_sf, code_muni = str_sub(code_weighting_area,1,7))
      temp_sf <- add_state_info(temp_sf, 'code_weighting_area')
      temp_sf <- add_region_info(temp_sf, 'code_weighting_area')

    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
      temp_sf <- harmonize_projection(temp_sf)

      # Convert columns from factors to characters
      temp_sf %>% dplyr::mutate_if(is.factor, as.character) -> temp_sf

    # Use UTF-8 encoding
      temp_sf <- use_encoding_utf8(temp_sf)

    # keep code as.numeric()
      temp_sf$code_weighting_area <- as.numeric(temp_sf$code_weighting_area)
      temp_sf$code_muni <- as.numeric(temp_sf$code_muni)
      temp_sf$code_state <- as.numeric(temp_sf$code_state)
      temp_sf$code_state <- as.numeric(temp_sf$code_region)

    # Make an invalid geometry valid # st_is_valid( sf)
      temp_sf <- sf::st_make_valid(temp_sf)

    # make everything a MULTIPOLYGON
      if( st_geometry_type(temp_sf) %>% unique() %>% as.character() %>% length() > 1 |
          any(  !( st_geometry_type(temp_sf) %>% unique() %>% as.character() %like% "MULTIPOLYGON"))) {
        temp_sf <- sf::st_cast(temp_sf, "MULTIPOLYGON")
      }

      # reorder columns
      temp_sf <- select(temp_sf, code_weighting_area, code_muni, code_state, abbrev_state, abbrev_state, code_region, name_region, geometry )



# Save cleaned sf in the cleaned directory

    # name of the file that will be saved
      #dest_dir <- "./shapes_in_sf_all_years_cleaned/2010/"
       if( !i %like% "municipios_areas_redefinidas"){ dest_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//areas_de_ponderacao//shapes_in_sf_all_years_cleaned//2010//"}

       if( i %like% "municipios_areas_redefinidas"){ dest_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//areas_de_ponderacao//shapes_in_sf_all_years_cleaned//2010//municipios_areas_redefinidas//"}

    # Save sf data as .rds
      readr::write_rds(temp_sf, path = paste0(dest_dir,as.character(temp_sf$code_muni[1]),".rds") )
  }


# Apply function to save original data sets in rds format
furrr::future_map(.x=sf_files, .f=clean_weighting_area)
gc(reset = T)







# juntando as bases por estado
  dir <- "./shapes_in_sf_all_years_cleaned/2010"
  dir.files <- list.files(dir,pattern = ".rds$", recursive = T, full.names = T)
  lista_uf <- unique(substr(dir.files,39, 40))


for (CODE in lista_uf) {# CODE <- 41

    files <- dir.files[ substr(dir.files, 39, 40) ==CODE ]
    files <- lapply(X=files, FUN= readr::read_rds)
    shape <- do.call('rbind', files)
    shape <- st_sf(shape)

# # fix code digit 10th (issue 174)
# if(CODE %in% c(21, 24, 29, 33, 41, 43)){
#   shape$code_weighting_area <- as.character(shape$code_weighting_area)
#
#   ## Replace digits
#     # geobr::lookup_muni(name_muni = 'IMPERATRIz')
#
#     # Rio
#     substr( shape$code_weighting_area[which(shape$code_muni==3304557)] , 10, 10) <- '5'
#     # Natal
#     substr( shape$code_weighting_area[which(shape$code_muni==2408102)] , 10, 10) <- '4'
#     # Caxias do Sul
#     substr( shape$code_weighting_area[which(shape$code_muni==4305108)] , 10, 10) <- '4'
#     # Porto Alegre
#     substr( shape$code_weighting_area[which(shape$code_muni==4314902)] , 10, 10) <- '4'
#     # novo hamburgo
#     substr( shape$code_weighting_area[which(shape$code_muni==4313409)] , 10, 10) <- '4'
#     # Rio Grande
#     substr( shape$code_weighting_area[which(shape$code_muni==4315602)] , 10, 10) <- '4'
#     # Santa Maria
#     substr( shape$code_weighting_area[which(shape$code_muni==4316907)] , 10, 10) <- '4'
#     # Viamao
#     substr( shape$code_weighting_area[which(shape$code_muni==4323002)] , 10, 10) <- '4'
#     # maringa
#     substr( shape$code_weighting_area[which(shape$code_muni==4115200)] , 10, 10) <- '4'
#     # FEIRA_DE_SANTANA
#     substr( shape$code_weighting_area[which(shape$code_muni==2910800)] , 10, 10) <- '4'
#     # Salvador
#     substr( shape$code_weighting_area[which(shape$code_muni==2927408 )] , 10, 10) <- '5'
#     # Imperatriz
#     substr( shape$code_weighting_area[which(shape$code_muni==2105302 )] , 10, 10) <- '4'
#
#     # back to numeric
#     shape$code_weighting_area <- as.numeric(shape$code_weighting_area)
# }




    # simplify borders
    shape_simplified <- simplify_temp_sf(shape)

    sf::st_write(shape, dsn = paste0("./",CODE,"AP.gpkg") )
    sf::st_write(shape_simplified, paste0("./",CODE,"AP_simplified", ".gpkg"))
  }

# mapview::mapview(shape)
