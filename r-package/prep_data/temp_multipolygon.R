
#' Ideally, each 'prep_' script will save the orignal data set as a mulpitolygon

library(geobr)
library(magrittr)
library(sf)
library(beepr)
library(pbapply)
library(furrr)
library(mapview)
library(magrittr)
library(data.table)


### Function to covert sf to MULTIPOLYGON

multipolygon_gpkg <- function(file_address){

  # file_address <- polygon_files[53]
  message(file_address)

# read original file
temp_gpkg <- sf::st_read(file_address, quiet=T)


# make everything a MULTIPOLYGON
if( st_geometry_type(temp_gpkg) %>% unique() %>% as.character() %>% length() > 1 |
    any(  !( st_geometry_type(temp_gpkg) %>% unique() %>% as.character() %like% "MULTIPOLYGON|GEOMETRYCOLLECTION"))) {

  # remove linstring
  temp_gpkg <- subset(temp_gpkg, st_geometry_type(temp_gpkg) %>% as.character() != "LINESTRING")
  temp_gpkg <- sf::st_cast(temp_gpkg, "MULTIPOLYGON")

  # delete previous file
  message('deleting old file')
  file.remove(file_address)

  # save simplified file
  message('saving new file')
  sf::st_write(temp_gpkg, file_address, quiet = TRUE)


} else{

  message(paste('jumping file' ))
  return(NULL)}

}


# list all simplified data sets
all_files <- list.files(path = '//storage1/geobr/data_gpkg', recursive = T, full.names = T)

# data that are not polygons should not be processed
polygon_files <- all_files[!(all_files %like% 'health_facilities|lookup_muni|municipal_seat')]

#  polygon_files[ polygon_files %like% '//storage1/geobr/data_gpkg/country/19']
#  file_address = '//storage1/geobr/data_gpkg/meso_region/2000/29ME.gpkg'

# aplicar funcao

# i core
pbapply::pblapply(X=polygon_files, FUN = multipolygon_gpkg)

  ## em paralelo
  # future::plan(future::multiprocess)
  # furrr::future_map(.x=simplified_files, .f = simplify_gpkg, .progress = T)
