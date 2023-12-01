#### Support functions to use in the preprocessing of the data

# library(dplyr)
# library(data.table)
# library(mapview)
# mapviewOptions(platform = 'deckgl')


options(encoding = "UTF-8")

`%nlike%` <- Negate(data.table::`%like%`)
`%nin%` <- Negate(`%in%`)

###### detect year from file name  -----------------
detect_year_from_string <- function(string){
  yyyy <- regmatches(string, gregexpr("\\d{4}", string))[[1]]
  yyyy <- unique(yyyy)
  yyyy <- yyyy[ yyyy != '2500' ]
  return(yyyy)
}

###### Add State abbreviation -----------------
add_state_info <- function(temp_sf, column){
  options(encoding = "UTF-8")

  # IF only the "name_state" column is present
  # Add code_state
  if (!is.null(temp_sf$code_muni) & "name_state" %in% names(temp_sf) ) {
    temp_sf <- dplyr::mutate(code_state = ifelse(name_state== "Rondonia" | name_state== "Territ\u00f3rio de Rondonia"  | name_state== "Territorio de Rondonia",11,
                                          ifelse(name_state== "Acre" | name_state== "Territ\u00f3rio do Acre",12,
                                          ifelse(name_state== "Amazonas",13,
                                          ifelse(name_state== "Roraima" | name_state=="Territ\u00f3rio de Roraima",14,
                                          ifelse(name_state== "Par\u00e1",15,
                                          ifelse(name_state== "Amap\u00e1" | name_state=="Territorio do Amapa",16,
                                          ifelse(name_state== "Tocantins",17,
                                          ifelse(name_state== "Maranh\u00e3o",21,
                                          ifelse(name_state== "Piaui" | name_state== "Piauhy",22,
                                          ifelse(name_state== "Cear\u00e1",23,
                                          ifelse(name_state== "Rio Grande do Norte",24,
                                          ifelse(name_state== "Paraiba" | name_state== "Parahyba",25,
                                          ifelse(name_state== "Pernambuco",26,
                                          ifelse(name_state== "Alagoas" | name_state=="Alag\u00f4as",27,
                                          ifelse(name_state== "Sergipe",28,
                                          ifelse(name_state== "Bahia",29,
                                          ifelse(name_state== "Minas Gerais" | name_state== "Minas Geraes",31,
                                          ifelse(name_state== "Espirito Santo" | name_state== "Espirito Santo",32,
                                          ifelse(name_state== "Rio de Janeiro",33,
                                          ifelse(name_state== "S\u00e3o Paulo",35,
                                          ifelse(name_state== "Paran\u00e1",41,
                                          ifelse(name_state== "Santa Catarina" | name_state== "Santa Catharina",42,
                                          ifelse(name_state== "Rio Grande do Sul",43,
                                          ifelse(name_state== "Mato Grosso do Sul",50,
                                          ifelse(name_state== "Mato Grosso" | name_state== "Matto Grosso",51,
                                          ifelse(name_state== "Goi\u00e1s" | name_state== "Goyaz",52,
                                          ifelse((name_state== "Distrito Federal" | name_state=="Brasilia") & (year>1950),53,NA
                               ))))))))))))))))))))))))))))
  }

  # IF there is no "name_state" column
  if (column != 'name_state'){

    # add code_state
    temp_sf$code_state <- substr( temp_sf[[ column ]] , 1,2) |> as.numeric()

    # # add name_state ENCODING ISSUES
    # stringi::stri_encode(from='latin1', to="utf8", str= "S\u00e3o Paulo")
    # stringi::stri_encode('S\u00e3o Paulo', to="UTF-8")
    # gtools::ASCIIfy('S\u00e3o Paulo')
    temp_sf <- temp_sf |> dplyr::mutate(name_state =
                                          data.table::fcase(code_state== 11, "Rond\u00f4nia",
                                                            code_state== 12, "Acre",
                                                            code_state== 13, "Amazonas",
                                                            code_state== 14, "Roraima",
                                                            code_state== 15, "Par\u00e1",
                                                            code_state== 16, "Amap\u00e1",
                                                            code_state== 17, "Tocantins",
                                                            code_state== 21, "Maranh\u00e3o",
                                                            code_state== 22, "Piau\u00ed",
                                                            code_state== 23, "Cear\u00e1",
                                                            code_state== 24, "Rio Grande do Norte",
                                                            code_state== 25, "Para\u00edba",
                                                            code_state== 26, "Pernambuco",
                                                            code_state== 27, "Alagoas",
                                                            code_state== 28, "Sergipe",
                                                            code_state== 29, "Bahia",
                                                            code_state== 31, "Minas Gerais",
                                                            code_state== 32, "Espirito Santo",
                                                            code_state== 33, "Rio de Janeiro",
                                                            code_state== 35, "S\u00e3o Paulo",
                                                            code_state== 41, "Paran\u00e1",
                                                            code_state== 42, "Santa Catarina",
                                                            code_state== 43, "Rio Grande do Sul",
                                                            code_state== 50, "Mato Grosso do Sul",
                                                            code_state== 51, "Mato Grosso",
                                                            code_state== 52, "Goi\u00e1s",
                                                            code_state== 53, "Distrito Federal",
                                                            default = NA))
  }

  # add abbrev state
  temp_sf <- temp_sf |> dplyr::mutate(
                            abbrev_state = data.table::fcase(
                                                code_state== 11, "RO",
                                                code_state== 12, "AC",
                                                code_state== 13, "AM",
                                                code_state== 14, "RR",
                                                code_state== 15, "PA",
                                                code_state== 16, "AP",
                                                code_state== 17, "TO",
                                                code_state== 21, "MA",
                                                code_state== 22, "PI",
                                                code_state== 23, "CE",
                                                code_state== 24, "RN",
                                                code_state== 25, "PB",
                                                code_state== 26, "PE",
                                                code_state== 27, "AL",
                                                code_state== 28, "SE",
                                                code_state== 29, "BA",
                                                code_state== 31, "MG",
                                                code_state== 32, "ES",
                                                code_state== 33, "RJ",
                                                code_state== 35, "SP",
                                                code_state== 41, "PR",
                                                code_state== 42, "SC",
                                                code_state== 43, "RS",
                                                code_state== 50, "MS",
                                                code_state== 51, "MT",
                                                code_state== 52, "GO",
                                                code_state== 53, "DF",
                                                default = NA))

  return(temp_sf)
}



###### Add Region info -----------------
add_region_info <- function(temp_sf, column){

  # add code_region
  temp_sf$code_region <- substr( temp_sf[[ column ]] , 1,1) |> as.numeric()

  # add name_region
  temp_sf <- temp_sf |> dplyr::mutate(name_region =
                                        data.table::fcase(code_region==1, 'Norte',
                                             code_region==2, 'Nordeste',
                                             code_region==3, 'Sudeste',
                                             code_region==4, 'Sul',
                                             code_region==5, 'Centro Oeste',
                                             default = NA))
  return(temp_sf)
}


###### list ftp folders -----------------

# function to list ftp folders from their original sub-dir
list_folders <- function(ftp){

  h <- rvest::read_html(ftp)
  elements <- rvest::html_elements(h, "a")
  folders <- rvest::html_attr(elements, "href")
  return(folders)

}



###### Download file to tempdir -----------------

download_file <- function(file_url,
                          showProgress = TRUE){

  file_ext <- tools::file_ext(file_url)
  dest_file <- tempfile(fileext = paste0('.', file_ext))

  # download data
    httr::GET(url=file_url,
              if(showProgress==T){ httr::progress()},
              httr::write_disk(dest_file, overwrite = T),
              config = httr::config(ssl_verifypeer = FALSE)
    )

    return(dest_file)
}

# ###### Unzip data -----------------
#
# # function to Unzip files in their original sub-dir
# # unzip_fun <- function(f, head_dir){
# #   unzip(f, exdir = file.path(head_dir, substr(f, 3, 6)))
# # }
# unzip_fun <- function(f){
#   # f <- files_1st_batch[1]
#   t<-strsplit(f, "/")
#   t<-t[[1]][length(t[[1]])]
#   t<- nchar(t)
#   unzip(f, exdir = file.path(head_dir, substr(f, 3, nchar(f)-t) ))
# }


###### snake case names ---------------------------------------------------

snake_case_names <- function(temp_sf, colname){

  # Capitalize the first letter
  temp_sf[[ colname ]] <- stringr::str_to_title( temp_sf[[ colname ]] )

  # prepositions to lower
  temp_sf[[ colname ]] <- gsub(' Do ', ' do ',   temp_sf[[ colname ]] )
  temp_sf[[ colname ]] <- gsub(' Dos ', ' dos ', temp_sf[[ colname ]] )
  temp_sf[[ colname ]] <- gsub(' Da ', ' da ',   temp_sf[[ colname ]] )
  temp_sf[[ colname ]] <- gsub(' Das ', ' das ', temp_sf[[ colname ]] )
  temp_sf[[ colname ]] <- gsub(' De ', ' de ',   temp_sf[[ colname ]] )

  return(temp_sf)
}



###### Harmonize spatial projection -----------------

# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674

harmonize_projection <- function(temp_sf){

  temp_sf <- if( is.na(sf::st_crs(temp_sf)) ){ sf::st_set_crs(temp_sf, 4674)
  } else {
    sf::st_transform(temp_sf, 4674) }
  sf::st_crs(temp_sf) <- 4674

  return(temp_sf)
  }




###### Use UTF-8 encoding -----------------
use_encoding_utf8 <- function(temp_sf){
  options(encoding = "UTF-8")


  temp_sf <- temp_sf |>
    dplyr::mutate_if(is.factor, function(x){
    x |> as.character() |> stringi::stri_encode(to="UTF-8") } )

  temp_sf <- temp_sf |>
    dplyr::mutate_if(is.character, function(x){
      x  |> stringi::stri_encode(to="UTF-8") } )

  # code columns remain numeric
  temp_sf <- temp_sf |> dplyr::mutate_at(dplyr::vars(starts_with("code_")), .funs = function(x){ as.numeric(x) })

  return(temp_sf)
  }


###### convert to MULTIPOLYGON -----------------

# to_multipolygon <- function(temp_sf){
# if( st_geometry_type(temp_sf) |> unique() |> as.character() |> length() > 1 |
#     any(  !( st_geometry_type(temp_sf) |> unique() |> as.character() %like% "MULTIPOLYGON|GEOMETRYCOLLECTION"))) {
#   # remove linstring
#   temp_sf <- subset(temp_sf, st_geometry_type(temp_sf) |> as.character() != "LINESTRING")
#   temp_sf <- sf::st_cast(temp_sf, "MULTIPOLYGON")
#   return(temp_sf)
# }else{ return(temp_sf)}}

to_multipolygon <- function(temp_sf){

  # get geometry types
  geom_types <- sf::st_geometry_type(temp_sf) |> unique() |> as.character()

  # checks
  if (length(geom_types) > 1 | any(  !( data.table::like(geom_types,"MULTIPOLYGON")))) {

      # remove linstring
      temp_sf <- subset(temp_sf, sf::st_geometry_type(temp_sf) |> as.character() != "LINESTRING")

      # get polyons
      temp_sf <- sf::st_collection_extract(temp_sf, "POLYGON")
      temp_sf <- sf::st_cast(temp_sf, "MULTIPOLYGON")
      return(temp_sf)

    } else {
       return(temp_sf) }
  }

###### Make valid topology -----------------

fix_topoly <- function(temp_sf){

  temp_sf <- sf::st_make_valid(temp_sf)
  # temp_sf <- sf::st_buffer(temp_sf, dist = 0)

  return(temp_sf)
}


###### Simplify temp_sf -----------------

simplify_temp_sf <- function(temp_sf, tolerance=100){

  # reproject to utm
  temp_gpkg_simplified <- sf::st_transform(temp_sf, crs=3857)

  # simplify with tolerance
  temp_gpkg_simplified <- sf::st_simplify(temp_gpkg_simplified,
                                          preserveTopology = T,
                                          dTolerance = tolerance)

  # reproject to utm
  temp_gpkg_simplified <- sf::st_transform(temp_gpkg_simplified, crs=4674)

  # Make any invalid geometry valid # st_is_valid( sf)
  temp_gpkg_simplified <- fix_topoly(temp_gpkg_simplified)

  return(temp_gpkg_simplified)
}



###### Dissolve borders temp_sf -----------------

## Function to clean and dissolve the borders of polygons by groups
dissolve_polygons <- function(mysf, group_column){


  # a) make sure we have valid geometries
  mysf <- fix_topoly(mysf)

  # b) make sure we have sf MULTIPOLYGON
  #temp_sf1 <- temp_sf |> st_cast("MULTIPOLYGON")
  temp_sf1 <- to_multipolygon(mysf)

  # c) long but complete dissolve function
  dissolvefun <- function(grp){

    # c.1) subset region
    temp_region <- subset(mysf, get(group_column, mysf)== grp )


    temp_region <- summarise(temp_region, .by = group_column)
    # plot(temp_region)

    temp_region <- sfheaders::sf_remove_holes(temp_region)
    temp_region <- fix_topoly(temp_region)

    return(temp_region)
  }


  # Apply sub-function
  groups_sf <- pbapply::pblapply(X = unique(get(group_column, mysf)), FUN = dissolvefun )

  # rbind results
  temp_sf <- do.call('rbind', groups_sf)
  return(temp_sf)
}


# # test
# states <- geobr::read_state(year=2000)
# a <- dissolve_polygons(states, group_column='code_region')
# plot(a)


# remove state repetition ----------------------
remove_state_repetition <- function(temp_sf){

  # know cases: Maranhao in 2000 and ES in 2001
  if (nrow(temp_sf)>27 | any(year==2001 & temp_sf$abbrev_state=='ES')   ) {

    # get colnames and summarize
    vars <- names(temp_sf)[-length(names(temp_sf))]
    temp_sf <- temp_sf |> group_by_at(vars) |> summarise()
    temp_sf <- temp_sf |> filter(!code_state=="0")
    temp_sf <- unique(temp_sf)
    return(temp_sf)

  } else { return(temp_sf) }
}


#####fixing municipality repetition---------

# https://github.com/ipeaGIT/geobr/blob/49534a6b19dc765e43e4c2f4404342f4fd0fdb4e/r-package/prep_data/prep_state_muni_regions.R#L987
