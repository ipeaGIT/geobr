library(sp)
library(sf)
library(geobr)
library(dplyr)
library(mapview)
library(readr)
library(future.apply)


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
  sf_states <- geobr::read_state(code_state = "all", year = y)

  # remove wrong-coded regions
  sf_states <- subset(sf_states, code_region %in% c(1:5))


# store original crs
  original_crs <- st_crs(sf_states)

  # b) make sure we have valid geometries
  temp_sf <- lwgeom::st_make_valid(sf_states)
  temp_sf <- temp_sf %>% st_buffer(0)

  sf_states1 <- temp_sf %>% st_cast("MULTIPOLYGON")

## Func to clean and dissolve each region
dissolve_each_region <- function(region_code){

    # subset region
    tem_region <- subset(sf_states1, code_region == region_code )


    # c) create attribute with the number of points each polygon has
    points_in_each_polygon = sapply(1:dim(tem_region)[1], function(i)
      length(st_coordinates(tem_region$geometry[i])))

    tem_region$points_in_each_polygon <- points_in_each_polygon
    mypols <- subset(tem_region, points_in_each_polygon > 0)

    # d) convert to sp
    sf_regiona <- mypols %>% as("Spatial")
    sf_regiona <- rgeos::gBuffer(sf_regiona, byid=TRUE, width=0) # correct eventual topology issues

    # c) dissolve borders to create country file
    result <- maptools::unionSpatialPolygons(sf_regiona, rep(TRUE, nrow(sf_regiona@data))) # dissolve


    # d) get rid of holes
    outerRings = Filter(function(f){f@ringDir==1},result@polygons[[1]]@Polygons)
    outerBounds = SpatialPolygons(list(Polygons(outerRings,ID=1)))

    # e) convert back to sf data
    outerBounds <- st_as_sf(outerBounds)
    outerBounds <- st_set_crs(outerBounds, original_crs)
    st_crs(outerBounds) <- 4674

    # retrieve code_region info
    outerBounds$code_region <- region_code

    return(outerBounds)
    }

all_regions <- lapply(unique(sf_states1$code_region), dissolve_each_region)
all_regions <- do.call('rbind', all_regions)
### add region names
all_regions$name_region <- ifelse(all_regions$code_region==1, 'Norte',
                                ifelse(all_regions$code_region==2, 'Nordeste',
                                       ifelse(all_regions$code_region==3, 'Sudeste',
                                              ifelse(all_regions$code_region==4, 'Sul',
                                                     ifelse(all_regions$code_region==5, 'Centro Oeste', NA)))))
all_regions <- select(all_regions, c('code_region', 'name_region', 'geometry'))

return(all_regions)
}

# aplicar para todas regioes e empilha resultados
temp_sf <- lapply(unique(sf_states1$code_region), dissolve_each_region)
temp_sf <- do.call('rbind', temp_sf)

### add region names
  temp_sf$name_region <- ifelse(temp_sf$code_region==1, 'Norte',
                                ifelse(temp_sf$code_region==2, 'Nordeste',
                                       ifelse(temp_sf$code_region==3, 'Sudeste',
                                              ifelse(temp_sf$code_region==4, 'Sul',
                                                     ifelse(temp_sf$code_region==5, 'Centro Oeste', NA)))))

  # redorder columns
  temp_sf <- dplyr::select(temp_sf, c('code_region', 'name_region', 'geometry'))

  # Save cleaned sf in the cleaned directory
  readr::write_rds(temp_sf, path= paste0(destdir,"/regions_",y,".rds"), compress = "gz")

}



# Aplica para diferentes anos
my_years <- c(2000, 2001, 2010, 2013, 2014, 2015, 2016, 2017, 2018)

# Parallel processing using future.apply
future::plan(future::multiprocess)
future.apply::future_lapply(X =my_years, FUN=prep_region, future.packages=c('readr', 'sp', 'sf', 'dplyr', 'geobr'))

