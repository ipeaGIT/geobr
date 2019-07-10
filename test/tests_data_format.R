library(sf)
library(readr)
library(geobr)
library(feather)

 
a <- geobr::read_country(year=2018)
a <- st_as_sf(a)

# save different formats check which one is more compact
  readr::write_rds(a, path = "a.rds", compress="gz" )
  sf::st_write(a, "a.gpkg")
  sf::st_write(a, "a.shp")
  sf::st_write(a, "a.geojson")
  sf::st_write(a, "a.sqlite")
  sf::st_write(a, "a.gdb")
  # feather::write_feather(a, path="a.feather") # ERROR

  
# Now check the file size in disk
  #and if the file is zipped with gzip?
  
  
  
  
# read file

b <- sf::st_read("a.geojson")
head(b)
class(b)