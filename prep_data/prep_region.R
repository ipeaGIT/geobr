library(sp)
library(sf)



prep_region <- function(year){

  # a) reads all states sf files and pile them up
  y <- year
  sf_states <- geobr::read_state(code_state = "all", year = 2000)

  # store original crs
  original_crs <- st_crs(sf_states)

  # b) make sure we have valid geometries
  temp_sf <- lwgeom::st_make_valid(sf_states)
  temp_sf <- temp_sf %>% st_buffer(0)

  sf_states1 <- temp_sf %>% st_cast("MULTIPOLYGON")

## Func to clean and dissolve each region

each_region <- function(region_code){

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

return(outerBounds)
}

a <- lapply(unique(sf_states1$code_region), each_region)

a <- lapply(c(1, 2), each_region)

shape <- do.call('rbind', files)


a <- each_region(1)

  # Dissolve borders within continents with ms_dissolve()
  temp_ucs2 <- rmapshaper::ms_dissolve(temp_ucs)


  #clean columns and add region names
  temp_sf$Group.1 <- NULL
  temp_sf$name_region <- ifelse(temp_sf$code_region==1, 'Norte',
                                ifelse(temp_sf$code_region==2, 'Nordeste',
                                       ifelse(temp_sf$code_region==3, 'Sudeste',
                                              ifelse(temp_sf$code_region==4, 'Sul',
                                                     ifelse(temp_sf$code_region==5, 'Centro Oeste', NA)))))

