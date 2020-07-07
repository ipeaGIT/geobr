
#' Ideally, each 'prep_' script will save the orignal data set and its simplified version.
#' However, this script can be used to ajust the simplified data sets. In our last explorations of the data,
#' we have found that simplifying the data using dTolerance{sf} = 100 gives a good balance between file size
#' without losing too muchgeographic detail

library(geobr)
library(magrittr)
library(sf)
library(beepr)
library(pbapply)
library(furrr)
library(mapview)
library(rmapshaper)
library(magrittr)
library(data.table)

rmapshaper::ms_simplify

### Function to simplify data sets

simplify_gpkg <- function(file_address, tolerance=100){

  message(file_address)

# get address of original file
simplified_file_address <- file_address
original_file_address <- gsub('_simplified.gpkg', '.gpkg', simplified_file_address)

# read original file
temp_gpkg <- sf::st_read(original_file_address, quiet=T)

# simplify with tolerance
  temp_gpkg_simplified <- sf::st_transform(temp_gpkg, crs=3857)

  temp_gpkg_simplified <- rmapshaper::ms_simplify(temp_gpkg, keep=.7)

#  temp_gpkg_simplified <- sf::st_simplify(temp_gpkg_simplified, preserveTopology = T, dTolerance = tolerance)
  temp_gpkg_simplified <- sf::st_transform(temp_gpkg_simplified, crs=4674)

# Make any invalid geometry valid # st_is_valid( sf)
temp_gpkg_simplified <- lwgeom::st_make_valid(temp_gpkg_simplified)

# as.numeric(object.size(temp_gpkg_simplified)) / as.numeric(object.size(temp_gpkg)) # reducao em __ vezes
# mapview(temp_gpkg_simplified, plataform='leafgl') +  temp_gpkg

# delete previous file
message('deleting old file')
file.remove(simplified_file_address)

# save simplified file
message('saving new file')
sf::st_write(temp_gpkg_simplified, simplified_file_address, quiet = TRUE)

}


# list all simplified data sets
simplified_files <- list.files(path = '//storage1/geobr/data_gpkg', pattern = 'simplified', recursive = T, full.names = T)

# data at more local level should not be simplified too much
simplified_files_30 <- simplified_files[simplified_files %like% 'weighting_area|census_tract|urban_area|indigenous_land|disaster_risk_area']

# t <- simplify_gpkg(simplified_files_20[57])
#
# file_address <- simplified_files_30[57]



# aplicar funcao

# i core
pbapply::pblapply(X=simplified_files, FUN = simplify_gpkg)
pbapply::pblapply(X=simplified_files_30, FUN = simplify_gpkg, tolerance=30)

  ## em paralelo
  # future::plan(future::multiprocess)
  # furrr::future_map(.x=simplified_files, .f = simplify_gpkg, .progress = T)
