#### Support functions to use in the preprocessing of the data




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
