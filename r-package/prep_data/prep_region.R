### Libraries (use any library as necessary)

library(sp)
library(sf)
library(geobr)
library(dplyr)
library(mapview)
library(readr)
library(future.apply)
library(data.table)

####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")




###### 0. Create Root folder to save the data -----------------
root_dir <- "L:\\# DIRUR #\\ASMEQ\\geobr\\data-raw"
setwd(root_dir)
dir.create("./regions")


#### This function loads Brazilian stantes for an specified year {geobr::read_states} and
#### and generates the sf boundaries of region
prep_region <- function(year){

  y <- year

  # create year folder to save clean data
  destdir <- paste0("./regions/",y)
  dir.create(destdir)

  # a) reads all states sf files and pile them up
  sf_states <- geobr::read_state(code_state = "all", year = y, simplified = F)

  # remove wrong-coded regions
  sf_states <- subset(sf_states, code_region %in% c(1:5))


# store original crs
  original_crs <- st_crs(sf_states)

  # b) make sure we have valid geometries
  temp_sf <- sf::st_make_valid(sf_states)
  temp_sf <- temp_sf %>% st_buffer(0)

  sf_states1 <- to_multipolygon(temp_sf)


## Dissolve each region
all_regions <- dissolve_polygons(mysf=temp_sf, group_column='code_region')


### add region names
all_regions <- add_region_info(temp_sf = all_regions, column = 'code_region')
all_regions <- select(all_regions, c('code_region', 'name_region', 'geometry'))




###### 7. generate a lighter version of the dataset with simplified borders -----------------
  # skip this step if the dataset is made of points, regular spatial grids or rater data

  # simplify
  temp_sf7 <- simplify_temp_sf(all_regions)

###### convert to MULTIPOLYGON
all_regions <- to_multipolygon(all_regions)
temp_sf7 <- to_multipolygon(temp_sf7)

  # Save cleaned sf in the cleaned directory
  sf::st_write(all_regions, dsn= paste0(destdir,"/regions_",y,".gpkg"))
  sf::st_write(temp_sf7, dsn= paste0(destdir,"/regions_",y,"_simplified", ".gpkg"))

}



# Aplica para diferentes anos
my_years <- c(2000, 2001, 2010, 2013, 2014, 2015, 2016, 2017, 2018)

prep_region(2020)

# Parallel processing using future.apply
future::plan(future::multiprocess)
future.apply::future_lapply(X =my_years, FUN=prep_region, future.packages=c('readr', 'sp', 'sf', 'dplyr', 'geobr'))

