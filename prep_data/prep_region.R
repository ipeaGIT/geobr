library(sp)
library(sf)
library(geobr)
library(dplyr)
library(mapview)


#### This function loads Brazilian stantes for an specified year {geobr::read_states} and
#### and generates the sf boundaries of region
prep_region <- function(year){

  # a) reads all states sf files and pile them up
  y <- year
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

# aplicar para todas regioes e empilha resultados
all_regions <- lapply(unique(sf_states1$code_region), dissolve_each_region)
all_regions <- do.call('rbind', all_regions)



### add region names
all_regions$name_region <- ifelse(all_regions$code_region==1, 'Norte',
                                ifelse(all_regions$code_region==2, 'Nordeste',
                                       ifelse(all_regions$code_region==3, 'Sudeste',
                                              ifelse(all_regions$code_region==4, 'Sul',
                                                     ifelse(all_regions$code_region==5, 'Centro Oeste', NA)))))


# redorder columns
all_regions <- select(all_regions, c('code_region', 'name_region', 'geometry'))

return(all_regions)
}




a2018 <- prep_region(2018)
a2000 <- prep_region(2000)
plot(a2018)
plot(a2000)

a <- read_state(code_state = "all", year=2010)
head(a)

1991 # code state e code region missing
