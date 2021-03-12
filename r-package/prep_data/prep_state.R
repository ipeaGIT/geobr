####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")
source('./prep_data/download_malhas_municipais_function.R')


setwd('L:/# DIRUR #/ASMEQ/geobr/data-raw')


###### download raw data --------------------------------
# pblapply(X=c(2000,2001,2005,2007,2010,2013:2020), FUN=download_ibge)



###### Unzip raw data --------------------------------
unzip_to_geopackage(region='uf',year='all')


###### Cleaning UF files --------------------------------
setwd('L:/# DIRUR #/ASMEQ/geobr/data-raw/malhas_municipais')

# get folders with years
uf_dir <-  paste0(getwd(),"./shapes_in_sf_all_years_original/uf")
sub_dirs <- list.dirs(path =uf_dir, recursive = F)
sub_dirs <- sub_dirs[sub_dirs %like% paste0(2000:2020,collapse = "|")]



# create a function that will clean the sf files according to particularities of the data in each year

clean_states <- function( e ){  #  e <- sub_dirs[ sub_dirs %like% 2015 ]

  # get year of the folder
  last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
  year <- last4(e)
  year

  # create directory to save original shape files in sf format
  dir.create(file.path("shapes_in_sf_all_years_cleaned2"), showWarnings = FALSE)

  # create a subdirectory of states, municipalities, micro and meso regions
  dir.create(file.path("shapes_in_sf_all_years_cleaned2/uf/"), showWarnings = FALSE)

  # create a subdirectory of years
  dir.create(file.path(paste0("shapes_in_sf_all_years_cleaned2/uf/",year)), showWarnings = FALSE)
  gc(reset = T)

  dir.dest<- file.path(paste0("./shapes_in_sf_all_years_cleaned2/uf/",year))


  # list all sf files in that year/folder
  sf_files <- list.files(e, full.names = T, recursive = T, pattern = ".gpkg$")



  # for each file
  for (i in sf_files){ #  i <- sf_files[1]

    # read sf file
    temp_sf <- st_read(i)
    names(temp_sf) <- names(temp_sf) %>% tolower()

    if (year %like% "2000|2001"){
      # dplyr::rename and subset columns
         #temp_sf <- dplyr::rename(temp_sf, code_state = geocodigo, name_state = nome)
      temp_sf <- dplyr::select(temp_sf, c('code_state'=geocodigo, 'name_state'=nome, 'geom'))
    }

    if (year %like% "2010"){
      # dplyr::rename and subset columns
      temp_sf <- dplyr::rename(temp_sf, code_state = cd_geocodu, name_state = nm_estado)
      temp_sf <- dplyr::select(temp_sf, c('code_state', 'name_state', 'geom'))
    }

    if (year %like% "2013|2014|2015|2016|2017|2018"){
      # dplyr::rename and subset columns
      temp_sf <- dplyr::rename(temp_sf, code_state = cd_geocuf, name_state = nm_estado)
      temp_sf <- dplyr::select(temp_sf, c('code_state', 'name_state', 'geom'))
    }

    if (year %like% "2019|2020"){
      # dplyr::rename and subset columns
      temp_sf <- dplyr::rename(temp_sf, code_state = cd_uf, name_state = nm_uf)
      temp_sf <- dplyr::select(temp_sf, c('code_state', 'name_state', 'geom'))
    }


    # add name_state
    temp_sf <- add_state_info(temp_sf,column = 'code_state')

    # Add Region codes and names
    temp_sf <- add_region_info(temp_sf,'code_state')

    # reorder columns
    temp_sf <- dplyr::select(temp_sf, 'code_state', 'abbrev_state', 'name_state', 'code_region', 'name_region', 'geom')

    # Use UTF-8 encoding
    temp_sf <- use_encoding_utf8(temp_sf)

    # Capitalize the first letter
    temp_sf$name_state <- stringr::str_to_title(temp_sf$name_state)

    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
    temp_sf <- harmonize_projection(temp_sf)

    # strange error in Bahia 2000
    # remove geometries with area == 0
    temp_sf <- subset(temp_sf, !is.na(abbrev_state))
    temp_sf <- temp_sf[ as.numeric(st_area(temp_sf)) != 0, ]
    # if (year==2000 & any(temp_sf$abbrev_state=='BA')) { temp_sf <- temp_sf[which.max(st_area(temp_sf)),] }

    # Make any invalid geom valid # st_is_valid( sf)
    temp_sf <- sf::st_make_valid(temp_sf)

    # keep code as.numeric()
    temp_sf$code_state <- as.numeric(temp_sf$code_state)
    temp_sf$code_region <- as.numeric(temp_sf$code_region)

    # remove state repetition
    temp_sf <- remove_state_repetition(temp_sf)

    # simplify
    temp_sf_simplified <- simplify_temp_sf(temp_sf)

    # convert to MULTIPOLYGON
    temp_sf <- to_multipolygon(temp_sf)
    temp_sf_simplified <- to_multipolygon(temp_sf_simplified)

    # Save cleaned sf in the cleaned directory
    dir.dest.file <- paste0(dir.dest,"/")

    if (year < 2015) {
    file.name <- paste0(unique(substr(temp_sf$code_state,1,2)),"UF",".gpkg")

    # original
    i <- paste0(dir.dest.file,file.name)
    sf::st_write(temp_sf, i, overwrite=TRUE)

    # simplified
    i <- gsub(".gpkg", "_simplified.gpkg", i)
    sf::st_write(temp_sf_simplified, i, overwrite=TRUE)
    }


    if (year >= 2015) {

      for( c in temp_sf$code_state){ # c <-33

      temp2 <- subset(temp_sf, code_state ==c)
      file.name <- paste0(unique(substr(temp2$code_state,1,2)),"UF",".gpkg")

      # original
      i <- paste0(dir.dest.file,file.name)
      sf::st_write(temp2, i, overwrite=TRUE)

      # simplified
      i <- gsub(".gpkg", "_simplified.gpkg", i)
      sf::st_write(temp2, i, overwrite=TRUE)
      }
    }
  }
}

# apply function in parallel
future::plan(multisession)
future_map(sub_dirs, clean_states)

rm(list= ls())
gc(reset = T)
