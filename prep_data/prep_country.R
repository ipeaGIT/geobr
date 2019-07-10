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

#### Using data already in the geobr package -----------------

# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais"
setwd(root_dir)


# create directory to save cleaned shape files in sf format
# dir.create(file.path("./shapes_in_sf_all_years_cleaned/country"), showWarnings = T)


# List years for which we have data
dirs <- list.dirs("./shapes_in_sf_all_years_cleaned/uf")[-1]
years <- stringi::stri_sub(dirs,-4,-1)


# remove problematic years
  years <- years[!(years %in% c(2000, 2001, 2005, 2007))]


#### Function to create country sf file

# For an specified year, the function:
# a) reads all states sf files and pile them up
# b) make sure the have valid geometries
# c) dissolve borders to create country file
# d) create a subdirectory of that year in the country directory
# e) save as an sf file


get_country <- function(y){

  # a) reads all states sf files and pile them up
    # y <- 2010
    temp_sf <- read_state(year=y, code_state = "all")


  # b) make sure we have valid geometries
    temp_sf <- lwgeom::st_make_valid(temp_sf)
    temp_sf <- temp_sf %>% st_buffer(0)

    # convert to sp
      temp_sp <- sf::as_Spatial(temp_sf)
      temp_sp <- rgeos::gBuffer(temp_sp, byid=TRUE, width=0)


  # c) dissolve borders to create country file
    result <- maptools::unionSpatialPolygons(temp_sp, rep(TRUE, nrow(temp_sp@data))) # dissolve


  # d) get rid of holes
    outerRings = Filter(function(f){f@ringDir==1},result@polygons[[1]]@Polygons)
    outerBounds = SpatialPolygons(list(Polygons(outerRings,ID=1)))


  # d) create a subdirectory of that year in the country directory
  dest_dir <- paste0("./shapes_in_sf_all_years_cleaned/country/",y)
  dir.create(dest_dir, showWarnings = FALSE)

  # e) save as an sf file
  outerBounds <- st_as_sf(outerBounds)
  readr::write_rds(outerBounds, path = paste0(dest_dir,"/country_",y,".rds"), compress="gz" )

}





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

