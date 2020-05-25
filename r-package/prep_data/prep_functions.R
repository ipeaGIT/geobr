#### Support functions to use in the preprocessing of the data



###### list ftp folders -----------------

# function to list ftp folders from their original sub-dir
list_foulders <- function(ftp){

  if (substr(ftp, nchar(ftp), nchar(ftp)) != "/") {
    ftp<-paste0(ftp,"/")
  }
  ##List Years/folders available
  years = getURL(ftp, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  years <- strsplit(years, "\r\n")
  years = unlist(years)

  return(years)

}

###### Download data -----------------



###### Unzip data -----------------

# function to Unzip files in their original sub-dir
unzip_fun <- function(f){
  unzip(f, exdir = file.path(head_dir, substr(f, 3, 6)))
}




###### Harmonize spatial projection -----------------

# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674

harmonize_projection <- function(temp_sf){

  temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }
  st_crs(temp_sf) <- 4674

  return(temp_sf)
  }


###### Add State abbreviation -----------------

add_state_info <- function(temp_sf){

  # add code_state
  temp_sf$code_state <- substr(temp_sf$code_muni, 1, 2)

  temp_sf <- temp_sf %>% mutate(abbrev_state = ifelse(code_state== 11, "RO",
                                               ifelse(code_state== 12, "AC",
                                               ifelse(code_state== 13, "AM",
                                               ifelse(code_state== 14, "RR",
                                               ifelse(code_state== 15, "PA",
                                               ifelse(code_state== 16, "AP",
                                               ifelse(code_state== 17, "TO",
                                               ifelse(code_state== 21, "MA",
                                               ifelse(code_state== 22, "PI",
                                               ifelse(code_state== 23, "CE",
                                               ifelse(code_state== 24, "RN",
                                               ifelse(code_state== 25, "PB",
                                               ifelse(code_state== 26, "PE",
                                               ifelse(code_state== 27, "AL",
                                               ifelse(code_state== 28, "SE",
                                               ifelse(code_state== 29, "BA",
                                               ifelse(code_state== 31, "MG",
                                               ifelse(code_state== 32, "ES",
                                               ifelse(code_state== 33, "RJ",
                                               ifelse(code_state== 35, "SP",
                                               ifelse(code_state== 41, "PR",
                                               ifelse(code_state== 42, "SC",
                                               ifelse(code_state== 43, "RS",
                                               ifelse(code_state== 50, "MS",
                                               ifelse(code_state== 51, "MT",
                                               ifelse(code_state== 52, "GO",
                                               ifelse(code_state== 53, "DF",NA))))))))))))))))))))))))))))
  return(temp_sf)
  }



###### Add Region info -----------------

add_region_info <- function(temp_sf){

  # add code_region
  temp_sf$code_region <- substr(temp_sf$code_muni, 1,1)

  # add name_region
  temp_sf <- temp_sf %>% mutate(name_region = ifelse(code_region==1, 'Norte',
                                              ifelse(code_region==2, 'Nordeste',
                                              ifelse(code_region==3, 'Sudeste',
                                              ifelse(code_region==4, 'Sul',
                                              ifelse(code_region==5, 'Centro Oeste', NA))))))
                                              }



###### Use UTF-8 encoding -----------------

use_encoding_utf8 <- function(temp_sf){


  temp_sf <- temp_sf %>%
  mutate_if(is.factor, function(x){ x %>% as.character() %>%
      stringi::stri_encode("UTF-8") } )

  return(temp_sf)
  }



###### Simplify temp_sf -----------------

simplify_temp_sf <- function(temp_sf, tolerance=100){

  # reproject to utm
  temp_gpkg_simplified <- sf::st_transform(temp_sf, crs=3857)

  # simplify with tolerance
  temp_gpkg_simplified <- sf::st_simplify(temp_gpkg_simplified, preserveTopology = T, dTolerance = tolerance)

  # reproject to utm
  temp_gpkg_simplified <- sf::st_transform(temp_gpkg_simplified, crs=4674)

  # Make any invalid geometry valid # st_is_valid( sf)
  temp_gpkg_simplified <- lwgeom::st_make_valid(temp_gpkg_simplified)
  return(temp_gpkg_simplified)
}



###### Dissolve borders temp_sf -----------------

## Function to clean and dissolve the borders of polygons by groups
dissolve_polygons <- function(mysf, group_column){


  # a) make sure we have valid geometries
  temp_sf <- lwgeom::st_make_valid(mysf)
  temp_sf <- temp_sf %>% st_buffer(0)

  # b) make sure we have sf MULTIPOLYGON
  temp_sf1 <- temp_sf %>% st_cast("MULTIPOLYGON")

  # c) long but complete dissolve function
  dissolvefun <- function(grp){

    # c.1) subset region
    temp_region <- subset(mysf, get(group_column, mysf)== grp )


    # c.2) create attribute with the number of points each polygon has
    points_in_each_polygon = sapply(1:dim(temp_region)[1], function(i)
      length(st_coordinates(temp_region$geom[i])))

    temp_region$points_in_each_polygon <- points_in_each_polygon
    mypols <- subset(temp_region, points_in_each_polygon > 0)

    # d) convert to sp
    sf_regiona <- mypols %>% as("Spatial")
    sf_regiona <- rgeos::gBuffer(sf_regiona, byid=TRUE, width=0) # correct eventual topology issues

    # c) dissolve borders to create country file
    result <- maptools::unionSpatialPolygons(sf_regiona, rep(TRUE, nrow(sf_regiona@data))) # dissolve


    # d) get rid of holes
    outerRings = Filter(function(f){f@ringDir==1},result@polygons[[1]]@Polygons)
    outerBounds = sp::SpatialPolygons(list(sp::Polygons(outerRings,ID=1)))

    # e) convert back to sf data
    outerBounds <- st_as_sf(outerBounds)
    outerBounds <- st_set_crs(outerBounds, st_crs(mysf))
    st_crs(outerBounds) <- st_crs(mysf)

    # retrieve code_region info and reorder columns
    outerBounds <- dplyr::mutate(outerBounds, group_column = grp)
    outerBounds <- dplyr::select(outerBounds, group_column, geometry)
    names(outerBounds)[1] <- group_column
    return(outerBounds)
  }


  # Apply sub-function
  groups_sf <- lapply(X = unique(get(group_column, mysf)), FUN = dissolvefun )

  # rbind results
  temp_sf <- do.call('rbind', groups_sf)
  return(temp_sf)
}


# # test
# states <- geobr::read_state()
# a <- dissolve_polygons(states, group_column='code_region')
# plot(a)

