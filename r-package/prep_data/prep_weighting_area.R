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



####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")


#### 0. Download original data sets from IBGE ftp -----------------

ftp <- "ftp://geoftp.ibge.gov.br/recortes_para_fins_estatisticos/malha_de_areas_de_ponderacao/"

########  1. Unzip original data sets downloaded from IBGE -----------------

# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malha_de_areas_de_ponderacao"
setwd(root_dir)

# List all zip files for all years
all_zipped_files <- list.files(full.names = T, recursive = T, pattern = ".zip")

#### 1.1. Municipios sem area redefinidas --------------
files_1st_batch <- all_zipped_files[!all_zipped_files %like% "municipios_areas_redefinidas"]

# function to Unzip files in their original sub-dir
unzip_fun <- function(f){
    unzip(f, exdir = file.path(root_dir, substr(f, 2, 24)))
}

# create computing clusters
cl <- parallel::makeCluster(detectCores())
parallel::clusterExport(cl=cl, varlist= c("files_1st_batch", "root_dir"), envir=environment())

# apply function in parallel
parallel::parLapply(cl, files_1st_batch, unzip_fun)
stopCluster(cl)


rm(list=setdiff(ls(), c("root_dir","all_zipped_files")))
gc(reset = T)

#### 1.2. Municipios  area redefinidas --------------
files_2st_batch <- all_zipped_files[all_zipped_files %like% "municipios_areas_redefinidas"]

## excluindo as areas redefinidas de Pelotas e de Ponta Grossa, dados corrompidos
files_2st_batch <- files_2st_batch[!files_2st_batch %like% "Pelotas|Ponta_Grossa"]

# function to Unzip files in their original sub-dir
unzip_fun <- function(f){

  unzip(f, exdir = file.path(root_dir, substr(f, 2, 53) ))
}

# create computing clusters
cl <- parallel::makeCluster(detectCores())
parallel::clusterExport(cl=cl, varlist= c("files_2st_batch", "root_dir"), envir=environment())

# apply function in parallel
parallel::parLapply(cl, files_2st_batch, unzip_fun)
stopCluster(cl)


rm(list=setdiff(ls(), c("root_dir","all_zipped_files")))
gc(reset = T)


#### 2. Create folders to save sf.rds files  -----------------

# create directory to save original shape files in sf format
  dir.create(file.path("shapes_in_sf_all_years_original"), showWarnings = FALSE)

# create directory to save cleaned shape files in sf format
  dir.create(file.path("shapes_in_sf_all_years_cleaned"), showWarnings = FALSE)

# create a subdirectory area_ponderacao
  dir.create(file.path("shapes_in_sf_all_years_original", "area_ponderacao"), showWarnings = FALSE)

  dir.create(file.path("shapes_in_sf_all_years_cleaned", "area_ponderacao"), showWarnings = FALSE)

# create a subdirectory of year
dir.create(file.path("shapes_in_sf_all_years_original", "area_ponderacao","2010"), showWarnings = FALSE)

dir.create(file.path("shapes_in_sf_all_years_cleaned", "area_ponderacao","2010"), showWarnings = FALSE)

# create a subdirectory of municipios_areas_redefinidas
dir.create(file.path("shapes_in_sf_all_years_original", "area_ponderacao","2010","municipios_areas_redefinidas"), showWarnings = FALSE)

dir.create(file.path("shapes_in_sf_all_years_cleaned", "area_ponderacao","2010","municipios_areas_redefinidas"), showWarnings = FALSE)

#### 3. Save original data sets downloaded from IBGE in compact .rds format-----------------

# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malha_de_areas_de_ponderacao"
setwd(root_dir)

# renomeando Boa Vista, não tem .shp
file.rename("L:/# DIRUR #/ASMEQ/geobr/data-raw/malha_de_areas_de_ponderacao/censo_demografico_2010/14_RR_Roraima/Boa_Vista_area de ponderacao",
            "L:/# DIRUR #/ASMEQ/geobr/data-raw/malha_de_areas_de_ponderacao/censo_demografico_2010/14_RR_Roraima/Boa_Vista_area de ponderacao.shp")


# List shapes for all years
all_shapes <- list.files(full.names = T, recursive = T, pattern = ".shp$")

shp_to_sf_rds <- function(x){ # x <- all_shapes[1]

  shape <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")

  # name of the file that will be saved
  if( !x %like% "municipios_areas_redefinidas"){ dest_dir <- "./shapes_in_sf_all_years_original/area_ponderacao/2010"}

  if( x %like% "municipios_areas_redefinidas"){ dest_dir <- "./shapes_in_sf_all_years_original/area_ponderacao/2010/municipios_areas_redefinidas"}

  file_name <- paste0(str_replace(unlist(str_split(x,"/"))[4],".shp",""), ".rds")

  # save in .rds
    readr::write_rds(shape, path = paste0(dest_dir,"/", file_name), compress="gz" )

}

# Apply function to save original data sets in rds format

# create computing clusters
  cl <- parallel::makeCluster(detectCores())

  clusterEvalQ(cl, c(library(data.table), library(readr), library(stringr), library(sf)))
  parallel::clusterExport(cl=cl, varlist= c("all_shapes"), envir=environment())

# apply function in parallel
  parallel::parLapply(cl, all_shapes, shp_to_sf_rds)
  stopCluster(cl)

rm(list= ls())
gc(reset = T)





###### 4. Cleaning weighting area files --------------------------------

# get dirs with sf original data
  uf_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malha_de_areas_de_ponderacao//shapes_in_sf_all_years_original/area_ponderacao"
  sub_dirs <- list.dirs(path =uf_dir, recursive = F)

# list all sf files in that year/folder
  sf_files <- list.files(sub_dirs, full.names = T,recursive = T)

# Exlcuindo base duplicada do estado de sao paulo
  sf_files <- sf_files[!sf_files == "L:////# DIRUR #//ASMEQ//geobr//data-raw//malha_de_areas_de_ponderacao//shapes_in_sf_all_years_original/area_ponderacao/2010/35SEE250GC_SIR_area_de_ponderacao.rds"]




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
      temp_sf <- dplyr::mutate(temp_sf, code_state = str_sub(code_weighting_area,1,2))

    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
      temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }

    # Convert columns from factors to characters
      temp_sf %>% dplyr::mutate_if(is.factor, as.character) -> temp_sf

    # Make an invalid geometry valid # st_is_valid( sf)
      temp_sf <- lwgeom::st_make_valid(temp_sf)

    # keep code as.numeric()
      temp_sf$code_weighting_area <- as.numeric(temp_sf$code_weighting_area)
      temp_sf$code_muni <- as.numeric(temp_sf$code_muni)
      temp_sf$code_state <- as.numeric(temp_sf$code_state)

    # reorder columns
      temp_sf <- select(temp_sf, code_weighting_area, code_muni, code_state, geometry )

      # Save cleaned sf in the cleaned directory
      #i <- gsub("original", "cleaned", i)
      # name of the file that will be saved
      if( !i %like% "municipios_areas_redefinidas"){ dest_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malha_de_areas_de_ponderacao//shapes_in_sf_all_years_cleaned//area_ponderacao//2010//"}

      if( i %like% "municipios_areas_redefinidas"){ dest_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malha_de_areas_de_ponderacao//shapes_in_sf_all_years_cleaned//area_ponderacao//2010//municipios_areas_redefinidas//"}

    # Save sf data as .rds
      readr::write_rds(temp_sf, path = paste0(dest_dir,as.character(temp_sf$code_muni[1]),".rds"), compress="gz" )
  }


# Apply function to save original data sets in rds format

  # create computing clusters
    cl <- parallel::makeCluster(detectCores())
    clusterEvalQ(cl, c(library(data.table), library(dplyr), library(readr), library(stringr), library(sf)))
    parallel::clusterExport(cl=cl, varlist= c("sf_files"), envir=environment())

  # apply function in parallel
    parallel::parLapply(cl, sf_files, clean_weighting_area)
    stopCluster(cl)

# lapply(sub_dirs, clean_weighting_area)
# clean_weighting_area(sub_dirs)

  rm(list= ls())
  gc(reset = T)

## inserindo as areas redefinidas
  dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malha_de_areas_de_ponderacao//shapes_in_sf_all_years_cleaned/area_ponderacao/2010"
  dir.files <- list.files(dir,pattern = ".rds$")

  dir.redefinidas <-"L:////# DIRUR #//ASMEQ//geobr//data-raw//malha_de_areas_de_ponderacao//shapes_in_sf_all_years_cleaned/area_ponderacao/2010/municipios_areas_redefinidas"
  dir.redefinidas.files <- list.files(dir.redefinidas,pattern = ".rds$")

  for (file in dir.files) { #file=dir.files[11]
    if (file %in% dir.redefinidas.files) {
      file.remove(paste0(dir,"//",file))
      file.copy(from=paste0(dir.redefinidas,"//",file),to=paste0(dir,"//",file))
      file.remove(paste0(dir.redefinidas,"//",file))
      }
  }

  #removendo pasta municipio area redefinida
   unlink("L:////# DIRUR #//ASMEQ//geobr//data-raw//malha_de_areas_de_ponderacao//shapes_in_sf_all_years_cleaned//area_ponderacao//2010//municipios_areas_redefinidas",recursive = TRUE)


#juntando as bases por estado
  dir.proj="L:////# DIRUR #//ASMEQ//geobr//data-raw//malha_de_areas_de_ponderacao//shapes_in_sf_all_years_cleaned/area_ponderacao/2010/"
  setwd(dir.proj)
  lista <- unique(substr(list.files(dir.proj),1,2))

for (CODE in lista) {# CODE <- 33

    files <- list.files(full.names = T,pattern = paste0("^",CODE))
    files <- lapply(X=files, FUN= readr::read_rds)
    files <- lapply(X=files, FUN= as.data.frame)
    shape <- do.call('rbind', files)
    shape <- st_sf(shape)
    shape_simplified <- st_transform(shape, crs=3857) %>% 
      sf::st_simplify(preserveTopology = T, dTolerance = 100) %>%
      st_transform(crs=4674)
    readr::write_rds(shape,paste0("./",CODE,"AP.rds"), compress="gz")
    sf::st_write(shape,dsn = paste0("./",CODE,"AP.gpkg") )
    sf::st_write(shape_simplified, dsn= shape,paste0("./",CODE,"AP_simplified", ".gpkg"))
  }

# mapview::mapview(shape)
