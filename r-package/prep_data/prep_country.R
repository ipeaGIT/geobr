### Libraries (use any library as necessary)


library(geobr)
library(dplyr)
library(readr)
library(sp)
library(sf)
library(rgdal)
library(rgeos)
library(maptools)
library(devtools)
library(parallel)
library(data.table)

####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")




# If the data set is updated regularly, you should create a function that will have
# a `date` argument download the data

# Not necessary






#### Using data already in the geobr package -----------------


# Root directory
root_geobr <- getwd()
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw"
setwd(root_dir)


# create directory to save cleaned shape files in sf format
destdir_raw <- "./country"
dir.create(destdir_raw)
setwd(destdir_raw)


# List years for which we have data
dirs <- list.dirs("./shapes_in_sf_all_years_cleaned/uf")[-1]
years <- stringi::stri_sub(dirs,-4,-1)

hist_dirs <- list.dirs("../historical_state_muni_1872_1991/shapes_in_sf_all_years_cleaned/uf")[-1]
hist_years <- stringi::stri_sub(hist_dirs,-4,-1)

# all years
years <- c(years, hist_years) %>% sort()



# remove problematic years
  years <- years[!(years %in% c(2005, 2007))]


#### Function to create country sf file

# For an specified year, the function:
# a) reads all states sf files and pile them up
# b) make sure the have valid geometries
# c) dissolve borders to create country file
# d) create a subdirectory of that year in the country directory
# e) save as an sf file


get_country <- function(y){

  # a) reads all states sf files and pile them up
    # y <- 2018
    sf_states <- read_state(year= y , code_state = "all", simplified = F)

  # store original crs
    original_crs <- st_crs(sf_states)

  # b) make sure we have valid geometries
    temp_sf <- sf::st_make_valid(sf_states)
    temp_sf <- temp_sf %>% st_buffer(0)

    sf_states1 <- to_multipolygon(temp_sf)

  # c) create attribute with the number of points each polygon has
    points_in_each_polygon = sapply(1:dim(sf_states1)[1], function(i)
      length(st_coordinates(sf_states1$geom[i])))

    sf_states1$points_in_each_polygon <- points_in_each_polygon
    mypols <- sf_states1 %>% filter(points_in_each_polygon > 0)

  # d) convert to sp
      sf_statesa <- mypols %>% as("Spatial")
      sf_statesa <- rgeos::gBuffer(sf_statesa, byid=TRUE, width=0) # correct eventual topology issues

      # temp_sp <- sf::as_Spatial(temp_sf)
      # temp_sp <- rgeos::gBuffer(temp_sp, byid=TRUE, width=0)
      # plot(sf_statesa)


  # c) dissolve borders to create country file
    result <- maptools::unionSpatialPolygons(sf_statesa, rep(TRUE, nrow(sf_statesa@data))) # dissolve


  # d) get rid of holes
    outerRings = Filter(function(f){f@ringDir==1},result@polygons[[1]]@Polygons)
    outerBounds = SpatialPolygons(list(Polygons(outerRings,ID=1)))
    plot(outerBounds)

  # e) convert back to sf data
    outerBounds <- st_as_sf(outerBounds)
    outerBounds <- st_set_crs(outerBounds, original_crs)




  # f) create a subdirectory of that year in the country directory
    dest_dir <- paste0("./shapes_in_sf_all_years_cleaned/country/",y)
    dir.create(dest_dir, showWarnings = FALSE)

  # g) generate a lighter version of the dataset with simplified borders
    temp_sf_simp <- simplify_temp_sf(temp_sf)

    ###### convert to MULTIPOLYGON -----------------
    temp_sf <- to_multipolygon(temp_sf)
    temp_sf_simp <- to_multipolygon(temp_sf_simp)


  # h) save as an sf file
    sf::st_write(temp_sf, dsn=paste0("country_",y,".gpkg") )
    sf::st_write(temp_sf_simp,dsn=paste0("country_",y,"_simplified", ".gpkg"))

}


get_country(y=2020)


# Apply function to save original data sets in rds format

# create computing clusters
  cl <- parallel::makeCluster(detectCores())

  clusterEvalQ(cl, c(library(geobr), library(maptools), library(dplyr), library(readr), library(rgeos), library(sf)))
  parallel::clusterExport(cl=cl, varlist= c("years","read_state"), envir=environment())

# apply function in parallel
  parallel::parLapply(cl, years, get_country)
  stopCluster(cl)

# rm(list= ls())
# gc(reset = T)

