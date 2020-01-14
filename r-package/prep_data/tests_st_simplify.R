library(geobr)
library(magrittr)
library(sf)
library(beepr)

# read original data
  # a <- geobr::read_municipality(code_muni= 'all')
  a <- geobr::read_state(code_state= 'all')


# simplify
system.time(  b <- st_transform(a, crs=3857) %>% sf::st_simplify(preserveTopology = T, dTolerance = 500) %>% st_transform(crs=4674) )
  
  as.numeric(object.size(a)) / as.numeric(object.size(b)) # reducao em __ vezes

# save data
  readr::write_rds(a, 'test.rds', compress = "gz")
  readr::write_rds(b, 'test_simplified.rds', compress = "gz")
  beepr::beep()

mapview::mapview(b)


