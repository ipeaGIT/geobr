#### Support functions to use in the preprocessing of the data

library(dplyr)
library(data.table)
library(magrittr)
library(mapview)

mapviewOptions(platform = 'deckgl')


`%nlike%` <- Negate(`%like%`)

###### list ftp folders -----------------

# function to list ftp folders from their original sub-dir
list_folders <- function(ftp){

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
# unzip_fun <- function(f, head_dir){
#   unzip(f, exdir = file.path(head_dir, substr(f, 3, 6)))
# }
unzip_fun <- function(f){
  # f <- files_1st_batch[1]
  t<-strsplit(f, "/")
  t<-t[[1]][length(t[[1]])]
  t<- nchar(t)
  unzip(f, exdir = file.path(head_dir, substr(f, 3, nchar(f)-t) ))
}



###### Harmonize spatial projection -----------------

# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674

harmonize_projection <- function(temp_sf){

  temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }
  st_crs(temp_sf) <- 4674

  return(temp_sf)
  }


###### Add State abbreviation -----------------
options(encoding = "UTF-8")

add_state_info <- function(temp_sf, column){
  options(encoding = "UTF-8")

  if(!is.null(temp_sf$code_muni) & !is.null(temp_sf$name_state)){
  # Add code_state
  temp_sf <- dplyr::mutate(code_state = ifelse(name_state== "Rondonia" | name_state== "Território De Rondonia"  | name_state== "Territorio de Rondonia",11,
                                        ifelse(name_state== "Acre" | name_state== "Território do Acre",12,
                                        ifelse(name_state== "Amazonas",13,
                                        ifelse(name_state== "Roraima" | name_state=="Território de Roraima",14,
                                        ifelse(name_state== "Pará",15,
                                        ifelse(name_state== "Amapá" | name_state=="Territorio do Amapa",16,
                                        ifelse(name_state== "Tocantins",17,
                                        ifelse(name_state== "Maranhão",21,
                                        ifelse(name_state== "Piaui" | name_state== "Piauhy",22,
                                        ifelse(name_state== "Ceará",23,
                                        ifelse(name_state== "Rio Grande do Norte",24,
                                        ifelse(name_state== "Paraiba" | name_state== "Parahyba",25,
                                        ifelse(name_state== "Pernambuco",26,
                                        ifelse(name_state== "Alagoas" | name_state=="Alagôas",27,
                                        ifelse(name_state== "Sergipe",28,
                                        ifelse(name_state== "Bahia",29,
                                        ifelse(name_state== "Minas Gerais" | name_state== "Minas Geraes",31,
                                        ifelse(name_state== "Espirito Santo" | name_state== "Espirito Santo",32,
                                        ifelse(name_state== "Rio de Janeiro",33,
                                        ifelse(name_state== "São Paulo",35,
                                        ifelse(name_state== "Paraná",41,
                                        ifelse(name_state== "Santa Catarina" | name_state== "Santa Catharina",42,
                                        ifelse(name_state== "Rio Grande do Sul",43,
                                        ifelse(name_state== "Mato Grosso do Sul",50,
                                        ifelse(name_state== "Mato Grosso" | name_state== "Matto Grosso",51,
                                        ifelse(name_state== "Goiás" | name_state== "Goyaz",52,
                                        ifelse((name_state== "Distrito Federal" | name_state=="Brasilia") & (year>1950),53,NA
                                        ))))))))))))))))))))))))))))
  }
  if( column != 'name_state'){

  # add code_state
  temp_sf$code_state <- substr( temp_sf[[ column ]] , 1,2) %>% as.numeric()


  #   # add name_state
  # temp_sf <- temp_sf %>% mutate(name_state =  ifelse(code_state== 11, stringi::stri_escape_unicode("Rondônia"),
  #                                             ifelse(code_state== 12, stringi::stri_escape_unicode("Acre"),
  #                                             ifelse(code_state== 13, stringi::stri_escape_unicode("Amazônas"),
  #                                             ifelse(code_state== 14, stringi::stri_escape_unicode("Roraima"),
  #                                             ifelse(code_state== 15, stringi::stri_escape_unicode("Pará"),
  #                                             ifelse(code_state== 16, stringi::stri_escape_unicode("Amapá"),
  #                                             ifelse(code_state== 17, stringi::stri_escape_unicode("Tocantins"),
  #                                             ifelse(code_state== 21, stringi::stri_escape_unicode("Maranhão"),
  #                                             ifelse(code_state== 22, stringi::stri_escape_unicode("Piauí"),
  #                                             ifelse(code_state== 23, stringi::stri_escape_unicode("Ceará"),
  #                                             ifelse(code_state== 24, stringi::stri_escape_unicode("Rio Grande do Norte"),
  #                                             ifelse(code_state== 25, stringi::stri_escape_unicode("Paraíba"),
  #                                             ifelse(code_state== 26, stringi::stri_escape_unicode("Pernambuco"),
  #                                             ifelse(code_state== 27, stringi::stri_escape_unicode("Alagoas"),
  #                                             ifelse(code_state== 28, stringi::stri_escape_unicode("Sergipe"),
  #                                             ifelse(code_state== 29, stringi::stri_escape_unicode("Bahia"),
  #                                             ifelse(code_state== 31, stringi::stri_escape_unicode("Minas Gerais"),
  #                                             ifelse(code_state== 32, stringi::stri_escape_unicode("Espírito Santo"),
  #                                             ifelse(code_state== 33, stringi::stri_escape_unicode("Rio de Janeiro"),
  #                                             ifelse(code_state== 35, stringi::stri_escape_unicode("São Paulo"),
  #                                             ifelse(code_state== 41, stringi::stri_escape_unicode("Paraná"),
  #                                             ifelse(code_state== 42, stringi::stri_escape_unicode("Santa Catarina"),
  #                                             ifelse(code_state== 43, stringi::stri_escape_unicode("Rio Grande do Sul"),
  #                                             ifelse(code_state== 50, stringi::stri_escape_unicode("Mato Grosso do Sul"),
  #                                             ifelse(code_state== 51, stringi::stri_escape_unicode("Mato Grosso"),
  #                                             ifelse(code_state== 52, stringi::stri_escape_unicode("Goiás"),
  #                                             ifelse(code_state== 53, stringi::stri_escape_unicode("Distrito Federal"), "!error!"))))))))))))))))))))))))))))
  #                                             }

  # add name_state
  stringi::stri_encode(from='latin1', to="utf8", str= "Rondônia, goiás")

  temp_sf <- temp_sf %>% mutate(name_state =  ifelse(code_state== 11, utf8::as_utf8("Rondônia"),
ifelse(code_state== 12, stringi::stri_encode(from='latin1', to="utf8", str="Acre"),
ifelse(code_state== 13, stringi::stri_encode(from='latin1', to="utf8", str="Amazônas"),
ifelse(code_state== 14, stringi::stri_encode(from='latin1', to="utf8", str="Roraima"),
ifelse(code_state== 15, stringi::stri_encode(from='latin1', to="utf8", str="Pará"),
ifelse(code_state== 16, stringi::stri_encode(from='latin1', to="utf8", str="Amapá"),
ifelse(code_state== 17, stringi::stri_encode(from='latin1', to="utf8", str="Tocantins"),
ifelse(code_state== 21, stringi::stri_encode(from='latin1', to="utf8", str="Maranhão"),
ifelse(code_state== 22, stringi::stri_encode(from='latin1', to="utf8", str="Piauí"),
ifelse(code_state== 23, stringi::stri_encode(from='latin1', to="utf8", str="Ceará"),
ifelse(code_state== 24, stringi::stri_encode(from='latin1', to="utf8", str="Rio Grande do Norte"),
ifelse(code_state== 25, stringi::stri_encode(from='latin1', to="utf8", str="Paraíba"),
ifelse(code_state== 26, stringi::stri_encode(from='latin1', to="utf8", str="Pernambuco"),
ifelse(code_state== 27, stringi::stri_encode(from='latin1', to="utf8", str="Alagoas"),
ifelse(code_state== 28, stringi::stri_encode(from='latin1', to="utf8", str="Sergipe"),
ifelse(code_state== 29, stringi::stri_encode(from='latin1', to="utf8", str="Bahia"),
ifelse(code_state== 31, stringi::stri_encode(from='latin1', to="utf8", str="Minas Gerais"),
ifelse(code_state== 32, stringi::stri_encode(from='latin1', to="utf8", str="Espírito Santo"),
ifelse(code_state== 33, stringi::stri_encode(from='latin1', to="utf8", str="Rio de Janeiro"),
ifelse(code_state== 35, stringi::stri_encode(from='latin1', to="utf8", str="São Paulo"),
ifelse(code_state== 41, stringi::stri_encode(from='latin1', to="utf8", str="Paraná"),
ifelse(code_state== 42, stringi::stri_encode(from='latin1', to="utf8", str="Santa Catarina"),
ifelse(code_state== 43, stringi::stri_encode(from='latin1', to="utf8", str="Rio Grande do Sul"),
ifelse(code_state== 50, stringi::stri_encode(from='latin1', to="utf8", str="Mato Grosso do Sul"),
ifelse(code_state== 51, stringi::stri_encode(from='latin1', to="utf8", str="Mato Grosso"),
ifelse(code_state== 52, stringi::stri_encode(from='latin1', to="utf8", str="Goiás"),
ifelse(code_state== 53, stringi::stri_encode(from='latin1', to="utf8", str="Distrito Federal"), "!error!"))))))))))))))))))))))))))))
}

  # temp_sf <- temp_sf %>% mutate(name_state =  ifelse(code_state== 11, utf8::as_utf8("Rondônia"),
  #                                             ifelse(code_state== 12, utf8::as_utf8("Acre"),
  #                                             ifelse(code_state== 13, utf8::as_utf8("Amazônas"),
  #                                             ifelse(code_state== 14, utf8::as_utf8("Roraima"),
  #                                             ifelse(code_state== 15, utf8::as_utf8("Pará"),
  #                                             ifelse(code_state== 16, utf8::as_utf8("Amapá"),
  #                                             ifelse(code_state== 17, utf8::as_utf8("Tocantins"),
  #                                             ifelse(code_state== 21, utf8::as_utf8("Maranhão"),
  #                                             ifelse(code_state== 22, utf8::as_utf8("Piauí"),
  #                                             ifelse(code_state== 23, utf8::as_utf8("Ceará"),
  #                                             ifelse(code_state== 24, utf8::as_utf8("Rio Grande do Norte"),
  #                                             ifelse(code_state== 25, utf8::as_utf8("Paraíba"),
  #                                             ifelse(code_state== 26, utf8::as_utf8("Pernambuco"),
  #                                             ifelse(code_state== 27, utf8::as_utf8("Alagoas"),
  #                                             ifelse(code_state== 28, utf8::as_utf8("Sergipe"),
  #                                             ifelse(code_state== 29, utf8::as_utf8("Bahia"),
  #                                             ifelse(code_state== 31, utf8::as_utf8("Minas Gerais"),
  #                                             ifelse(code_state== 32, utf8::as_utf8("Espírito Santo"),
  #                                             ifelse(code_state== 33, utf8::as_utf8("Rio de Janeiro"),
  #                                             ifelse(code_state== 35, utf8::as_utf8("São Paulo"),
  #                                             ifelse(code_state== 41, utf8::as_utf8("Paraná"),
  #                                             ifelse(code_state== 42, utf8::as_utf8("Santa Catarina"),
  #                                             ifelse(code_state== 43, utf8::as_utf8("Rio Grande do Sul"),
  #                                             ifelse(code_state== 50, utf8::as_utf8("Mato Grosso do Sul"),
  #                                             ifelse(code_state== 51, utf8::as_utf8("Mato Grosso"),
  #                                             ifelse(code_state== 52, utf8::as_utf8("Goiás"),
  #                                             ifelse(code_state== 53, utf8::as_utf8("Distrito Federal"), "!error!"))))))))))))))))))))))))))))
  # }

  # add abbrev state
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

add_region_info <- function(temp_sf, column){

  # add code_region
  temp_sf$code_region <- substr( temp_sf[[ column ]] , 1,1) %>% as.numeric()

  # add name_region
  temp_sf <- temp_sf %>% mutate(name_region = ifelse(code_region==1, 'Norte',
                                              ifelse(code_region==2, 'Nordeste',
                                              ifelse(code_region==3, 'Sudeste',
                                              ifelse(code_region==4, 'Sul',
                                              ifelse(code_region==5, 'Centro Oeste', NA))))))
  return(temp_sf)
                                              }



###### Use UTF-8 encoding -----------------
options(encoding = "UTF-8")

use_encoding_utf8 <- function(temp_sf){
  options(encoding = "UTF-8")
  options(encoding = "UTF-8")


  temp_sf <- temp_sf %>%
  mutate_if(is.factor, function(x){
    x %>% as.character() %>% stringi::stri_encode(to="UTF-8") } )

  temp_sf <- temp_sf %>%
    mutate_if(is.character, function(x){
      x  %>% stringi::stri_encode(to="UTF-8") } )

  # code columns remain numeric
  temp_sf <- temp_sf %>% mutate_at(vars(starts_with("code_")), .funs = function(x){ as.numeric(x) })

  return(temp_sf)
  }


###### convert to MULTIPOLYGON -----------------

# to_multipolygon <- function(temp_sf){
# if( st_geometry_type(temp_sf) %>% unique() %>% as.character() %>% length() > 1 |
#     any(  !( st_geometry_type(temp_sf) %>% unique() %>% as.character() %like% "MULTIPOLYGON|GEOMETRYCOLLECTION"))) {
#   # remove linstring
#   temp_sf <- subset(temp_sf, st_geometry_type(temp_sf) %>% as.character() != "LINESTRING")
#   temp_sf <- sf::st_cast(temp_sf, "MULTIPOLYGON")
#   return(temp_sf)
# }else{ return(temp_sf)}}

to_multipolygon <- function(temp_sf){

  # get geometry types
  geom_types <- st_geometry_type(temp_sf) %>% unique() %>% as.character()

  # checks
  if (length(geom_types) > 1 | any(  !( geom_types %like% "MULTIPOLYGON"))) {

      # remove linstring
      temp_sf <- subset(temp_sf, st_geometry_type(temp_sf) %>% as.character() != "LINESTRING")

      # get polyons
      temp_sf <- st_collection_extract(temp_sf, "POLYGON")
      temp_sf <- sf::st_cast(temp_sf, "MULTIPOLYGON")
      return(temp_sf)

    } else {
       return(temp_sf) }
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
  temp_gpkg_simplified <- sf::st_make_valid(temp_gpkg_simplified)

  return(temp_gpkg_simplified)
}



###### Dissolve borders temp_sf -----------------

## Function to clean and dissolve the borders of polygons by groups
dissolve_polygons <- function(mysf, group_column){


  # a) make sure we have valid geometries
  temp_sf <- sf::st_make_valid(mysf)
  temp_sf <- temp_sf %>% st_buffer(0)

  # b) make sure we have sf MULTIPOLYGON
  #temp_sf1 <- temp_sf %>% st_cast("MULTIPOLYGON")
  temp_sf1 <- to_multipolygon(temp_sf)

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


# remove state repetition ----------------------
remove_state_repetition <- function(temp_sf){

  # know cases: Maranhao in 2000 and ES in 2001
  if (nrow(temp_sf)>27 | any(year==2001 & temp_sf$abbrev_state=='ES')   ) {

    # get colnames and summarize
    vars <- names(temp_sf)[-length(names(temp_sf))]
    temp_sf <- temp_sf %>% group_by_at(vars) %>% summarise()
    temp_sf <- temp_sf %>% filter(!code_state=="0")
    return(temp_sf)

  } else { return(temp_sf) }
}




#####fixing municipality repetition---------

# https://github.com/ipeaGIT/geobr/blob/49534a6b19dc765e43e4c2f4404342f4fd0fdb4e/r-package/prep_data/prep_state_muni_regions.R#L987
