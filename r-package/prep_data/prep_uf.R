####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")
source('./prep_data/malhas_municipais_function.R')

###### Cleaning UF files --------------------------------

## function for malha municipal

malhas_municipais(region='uf')

uf_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais//shapes_in_sf_all_years_original/uf"
sub_dirs <- list.dirs(path =uf_dir, recursive = F)



# create a function that will clean the sf files according to particularities of the data in each year
clean_states <- function( e ){ #  e <- sub_dirs[sub_dirs %like% 2000]

  # get year of the folder
  last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
  year <- last4(e)
  
  # list all sf files in that year/folder
  sf_files <- list.files(e, full.names = T)
  
  # for each file
  for (i in sf_files){ #  i <- sf_files[3]
    
    # read sf file
    temp_sf <- st_read(i)
    
    if (year %like% "2000|2001"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_state = geocodigo, name_state = nome)
      temp_sf <- dplyr::select(temp_sf, c('code_state', 'name_state', 'geometry'))
    }
    
    if (year %like% "2010"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_state = cd_geocodu, name_state = nm_estado)
      temp_sf <- dplyr::select(temp_sf, c('code_state', 'name_state', 'geometry'))
    }
    
    if (year %like% "2013|2014|2015|2016|2017|2018"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_state = cd_geocuf, name_state = nm_estado)
      temp_sf <- dplyr::select(temp_sf, c('code_state', 'name_state', 'geometry'))
    }
    
    if (year %like% "2019"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_state = cd_uf, name_state = nm_uf)
      temp_sf <- dplyr::select(temp_sf, c('code_state', 'name_state', 'geometry'))
    }
    
    # add State abbreviation
    
    temp_sf <- add_state_info(temp_sf,'code_muni')
    
    # Add Region codes and names
    
    temp_sf <- add_region_info(temp_sf,'code_state')
    
    # reorder columns
    temp_sf <- dplyr::select(temp_sf, 'code_state', 'abbrev_state', 'name_state', 'code_region', 'name_region', 'geometry')
    
    # Use UTF-8 encoding
    temp_sf$name_state <- stringi::stri_encode(as.character((temp_sf$name_state), "UTF-8"))
    
    # Capitalize the first letter
    temp_sf$name_state <- stringr::str_to_title(temp_sf$name_state)
    
    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
    temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }
    
    # Convert columns from factors to characters
    temp_sf %>% dplyr::mutate_if(is.factor, as.character) -> temp_sf
    
    # Make any invalid geometry valid # st_is_valid( sf)
    temp_sf <- sf::st_make_valid(temp_sf)
    
    # keep code as.numeric()
    temp_sf$code_state <- as.numeric(temp_sf$code_state)
    
    # simplify
    temp_sf_simplified <- st_transform(temp_sf, crs=3857) %>% sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)
    
    # Save cleaned sf in the cleaned directory
    i <- gsub("original", "cleaned", i)
    # write_rds(temp_sf, path = i, compress="gz" )
    
    i <- gsub(".rds", ".gpkg", i)
    
    sf::st_write(temp_sf, i , update = TRUE)
    
    i <- gsub(".gpkg", "_simplified.gpkg", i)
    
    sf::st_write(temp_sf_simplified, i , update = TRUE)
    
  }
}

future::plan(multiprocess)

future_map(sub_dirs, clean_states)

rm(list= ls())
gc(reset = T)
