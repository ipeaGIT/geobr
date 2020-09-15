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
library(mapview)

mapviewOptions(platform = 'leafgl')

####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")

#### 0. Create directories to downlod and save the data -----------------

# Root directory
root_geobr <- getwd()
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw"
setwd(root_dir)

# Create Directory to keep original downloaded files
destdir_raw <- "./weighting_area"
dir.create(destdir_raw)
setwd(destdir_raw)

# create directory to save original shape files in sf format
dir.create(file.path("shapes_in_sf_all_years_original"), showWarnings = FALSE)

# create directory to save cleaned shape files in sf format
dir.create(file.path("sf_all_years_cleaned"), showWarnings = FALSE)


###### 1. download the raw data from the original website source -----------------

download.file("https://opendata.arcgis.com/datasets/ffc3ef46614d4a7987ef122c53fd621e_6.zip" ,
              destfile = paste0(destdir_raw,".zip"))


#####  1.1 Unzip original data set -----------------


# list and unzip zipped files
setwd(destdir_raw)
zipfiles <- list.files(pattern = ".zip")
unzip(zipfiles)

###### List original data sets -----------------

# select file shp
raw_shapes <- list.files(full.names = T, pattern = ".shp$")


# list code_state
state <- geobr::read_state()
state <- unique(state$code_state)

# dividir o arquivo original em arquivos originais subsetados por UF
# broke original files and save by state

original_sf <- st_read(raw_shapes, quiet = T, stringsAsFactors=F, options = "ENCODING=UTF-8")

for(i in state){#i=state[3]
  temp_sf <- subset(original_sf, str_sub(original_sf$CD_GEOCODM,1,2)==i)

  # save in .rds
  file_name <- paste0(i, ".rds")
  readr::write_rds(temp_sf, path = paste0("./shapes_in_sf_all_years_original/", file_name), compress="gz" )
}

# list all files
original_shapes <- list.files(path="./shapes_in_sf_all_years_original" ,full.names = T, pattern = ".rds")



###### 4. Cleaning weighting area files --------------------------------

munis <- geobr::read_municipality(year=2010)
munis$geom <- NULL
munis <- select(munis, code_muni, name_muni)
munis$code_muni <- as.character(munis$code_muni)

cleaning_data_fun <- function(f){ # f=original_shapes[20]

  ### read data
  # temp <- readRDS(f, file = f) #o arquivo abre por aqui, logo n?o est? corrompido
  # temp_sf1 <- st_read(f, quiet = F, stringsAsFactors=F, options = "ENCODING=UTF8")
  temp_sf1 <- readr::read_rds(f)

  ###### 2. rename column names -----------------

  names(temp_sf1) <- names(temp_sf1) %>% tolower()
  colnames(temp_sf1)[colnames(temp_sf1) %in% c("cd_aponde","area_pond")] <- "code_weighting_area"
  temp_sf1 <- select(temp_sf1, 'code_weighting_area', 'geometry')

  temp_sf2 <- add_state_info(temp_sf1, 'code_weighting_area')
  temp_sf2 <- add_region_info(temp_sf2, 'code_weighting_area')
  temp_sf2 <- dplyr::mutate(temp_sf2, code_muni = str_sub(code_weighting_area,1,7))

  # add municipality name
  temp_sf2 <- left_join(temp_sf2, munis)


  ###### reorder columns -----------------
  temp_sf2 <- select(temp_sf2, code_weighting_area, code_muni, name_muni, code_state, abbrev_state, code_region, name_region, geometry )


  ###### 3. ensure the data uses spatial projection SIRGAS 2000 epsg (SRID): 4674-----------------

  temp_sf3 <- harmonize_projection(temp_sf2)

  st_crs(temp_sf3)$epsg
  st_crs(temp_sf3)$input
  st_crs(temp_sf3)$proj4string
  st_crs(st_crs(temp_sf3)$wkt) == st_crs(temp_sf3)



  ###### 4. ensure every string column is as.character with UTF-8 encoding -----------------

  # convert all factor columns to character
  temp_sf4 <- temp_sf3 %>% mutate_if(is.factor, function(x){ x %>% as.character() } )

  # convert all character columns to UTF-8
  temp_sf4 <- temp_sf4 %>% mutate_if(is.character, function(x){ x %>% stringi::stri_encode("UTF-8") } )


  ###### 5. remove Z dimension of spatial data-----------------

  # remove Z dimension of spatial data
  temp_sf5 <- temp_sf4 %>% st_sf() %>% st_zm( drop = T, what = "ZM")



  ###### 6. fix eventual topology issues in the data-----------------

  # Make any invalid geometry valid # st_is_valid( sf)
  # temp_sf6 <- lwgeom::st_make_valid(temp_sf5)
  temp_sf6 <- st_make_valid(temp_sf5)




  ###### convert to MULTIPOLYGON -----------------
  temp_sf6 <- to_multipolygon(temp_sf6)



  ###### 7. generate a lighter version of the dataset with simplified borders -----------------
  # skip this step if the dataset is made of points, regular spatial grids or rater data

  # simplify
  temp_sf7 <- simplify_temp_sf(temp_sf6, tolerance=100)
  # mapview(temp_sf7)

  ###### 8. Clean data set and save it in geopackage format-----------------

  # save original and simplified datasets
  i <- as.numeric(gsub("\\D", "", f))

  # readr::write_rds(temp_sf6, path= paste0("./sf_all_years_cleaned/", i, ".rds"),compress = "gz")
  sf::st_write(temp_sf6, dsn= paste0("./sf_all_years_cleaned/", i, "AP.gpkg"))
  sf::st_write(temp_sf7, dsn= paste0("./sf_all_years_cleaned/", i,"AP_simplified", ".gpkg"))
}



# Apply funtion to all raw data sets

pbapply::pblapply(X=original_shapes, FUN = cleaning_data_fun)






# # juntando as bases por estado
#   dir <- "./shapes_in_sf_all_years_cleaned/2010"
#   dir.files <- list.files(dir,pattern = ".rds$", recursive = T, full.names = T)
#   lista_uf <- unique(substr(dir.files,39, 40))
#
#
# for (CODE in lista_uf) {# CODE <- 41
#
#     files <- dir.files[ substr(dir.files, 39, 40) ==CODE ]
#     files <- lapply(X=files, FUN= readr::read_rds)
#     shape <- do.call('rbind', files)
#     shape <- st_sf(shape)

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




  #   # simplify borders
  #   shape_simplified <- simplify_temp_sf(shape)
  #
  #   sf::st_write(shape, dsn = paste0("./",CODE,"AP.gpkg") )
  #   sf::st_write(shape_simplified, paste0("./",CODE,"AP_simplified", ".gpkg"))
  # }

# mapview::mapview(shape)
