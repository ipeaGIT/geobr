
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
# library(rmapshaper)
library(magrittr)



            # # read original data
            # # o <- geobr::read_municipality(code_muni = 4106902, tp = "original")
            # # a <- geobr::read_municipality(code_muni = 4106902, tp = "simplified")
            #
            # o <- geobr::read_metro_area(year=2013, tp = "original")
            # a <- geobr::read_metro_area(year=2013, tp = "simplified")
            #
            # o <- subset(o, name_metro == "RM São Paulo")
            # a <- subset(a, name_metro == "RM São Paulo")
            #
            #
            #
            #
            #
            # # simplify
            # system.time(  b <- st_transform(o, crs=3857) %>% sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674) )
            #
            # system.time(  c <- st_transform(o, crs=3857)  %>% rmapshaper::ms_simplify(keep = .5) %>% st_transform(crs=4674) )
            #
            # 5000 8%
            # 500 9%
            # 50 16%
            # 10 33%
            # 5 45%
            #
            # identical(b, c)
            #
            #
            # plot(o)
            # plot(a)
            # plot(b)
            # plot(c)
            #
            #
            #   as.numeric(object.size(a)) / as.numeric(object.size(o)) # reducao em __ vezes
            #   as.numeric(object.size(b)) / as.numeric(object.size(o)) # reducao em __ vezes
            #   as.numeric(object.size(c)) / as.numeric(object.size(o)) # reducao em __ vezes
            #
            #
            #   mapview(o) + a + b + c
            #
            #
            # # save data
            #   sf::st_write(o, 'test.gpkg')
            #   sf::st_write(b, 'test_simplified100.gpkg')
            #   sf::st_write(c, 'test_simplified.gpkg')
            #
            #   beepr::beep()
            #
            # mapview::mapview(b)
            #

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
  temp_gpkg_simplified <- sf::st_simplify(temp_gpkg_simplified, preserveTopology = T, dTolerance = tolerance)
  temp_gpkg_simplified <- sf::st_transform(temp_gpkg_simplified, crs=4674)

# Make any invalid geometry valid # st_is_valid( sf)
temp_gpkg_simplified <- lwgeom::st_make_valid(temp_gpkg_simplified)

# as.numeric(object.size(temp_gpkg_simplified)) / as.numeric(object.size(temp_gpkg)) # reducao em __ vezes
# mapview(temp_gpkg) + temp_gpkg_simplified

# delete previous file
message('deleting old file')
file.remove(simplified_file_address)

# save simplified file
message('saving new file')
sf::st_write(temp_gpkg_simplified, simplified_file_address, quiet = TRUE)

}


# list all simplified data sets
simplified_files <- list.files(path = '//storage1/geobr/data_gpkg', pattern = 'simplified', recursive = T, full.names = T)


# aplicar funcao

# i core
pbapply::pblapply(X=simplified_files, FUN = simplify_gpkg)

  ## em paralelo
  # future::plan(future::multiprocess)
  # furrr::future_map(.x=simplified_files, .f = simplify_gpkg, .progress = T)
