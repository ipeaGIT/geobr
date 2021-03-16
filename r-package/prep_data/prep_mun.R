####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")
source('./prep_data/download_malhas_municipais_function.R')

setwd('L:/# DIRUR #/ASMEQ/geobr/data-raw')

# pblapply(X=c(2000,2001,2005,2007,2010,2013:2020), FUN=download_ibge)
###### download raw data --------------------------------
unzip_to_geopackage(region='municipio', year='all')


###### Cleaning municipality files --------------------------------
setwd('L:/# DIRUR #/ASMEQ/geobr/data-raw/malhas_municipais')

mun_dir <- "./shapes_in_sf_all_years_original/municipio"

sub_dirs <- list.dirs(path =mun_dir, recursive = F)

sub_dirs <- sub_dirs[sub_dirs %like% paste0(2000:2020,collapse = "|")]


clean_muni <- function( e , year=2000){ #  e <- sub_dirs[sub_dirs %like% 2007 ]

  # select year
  if (year == 'all') {
    message(paste('Processing all years'))
  } else{
    if (!any(e %like% year)) {
      return(NULL)
    }
  }
  message(paste('Processing',year))

  options(encoding = "UTF-8")

  # get year of the folder
  last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
  year <- last4(e)
  year

  # create directory to save original shape files in sf format
  dir.create(file.path("shapes_in_sf_all_years_cleaned2"), showWarnings = FALSE)

  # create a subdirectory of states, municipalities, micro and meso regions
  dir.create(file.path("shapes_in_sf_all_years_cleaned2/municipio/"), showWarnings = FALSE)

  # create a subdirectory of years
  dir.create(file.path(paste0("shapes_in_sf_all_years_cleaned2/municipio/",year)), showWarnings = FALSE)
  gc(reset = T)

  dir.dest <- file.path(paste0("./shapes_in_sf_all_years_cleaned2/municipio/",year))

  # list all sf files in that year/folder
  sf_files <- list.files(e, full.names = T, recursive = T, pattern = ".gpkg$")

  #sf_files <- sf_files[sf_files %like% "Municipios"]


  # for each file
  for (i in sf_files){ #  i <- sf_files[1]

    message(paste0(i))

    # read sf file
    temp_sf <- st_read(i)
    names(temp_sf) <- names(temp_sf) %>% tolower()

    if (year %like% "2000|2001|2005"){
      # dplyr::rename and subset columns
      temp_sf <- dplyr::select(temp_sf, c('code_muni'=geocodigo, 'name_muni'=nome, 'geom'))
    }

    if (year %like% "2007"){
      # dplyr::rename and subset columns
      temp_sf <- dplyr::select(temp_sf, c('code_muni'=geocodig_m, 'name_muni'=nome_munic, 'geom'))
    }

    if (year %like% "2010"){
      # dplyr::rename and subset columns
      temp_sf <- dplyr::select(temp_sf, c('code_muni'=cd_geocodm, 'name_muni'=nm_municip, 'geom'))
    }

    if (year %like% "2013|2014|2015|2016|2017|2018"){
      # dplyr::rename and subset columns
      temp_sf <- dplyr::select(temp_sf, c('code_muni'=cd_geocmu, 'name_muni'=nm_municip, 'geom'))
    }

    if (year %like% "2019|2020"){
      # dplyr::rename and subset columns
      temp_sf <- dplyr::select(temp_sf, c('code_muni'=cd_mun, 'name_muni'=nm_mun, 'geom'))
    }

    # add state info
    temp_sf$code_state <- substring(temp_sf$code_muni, 1,2)
    temp_sf <- add_state_info(temp_sf,column = 'code_state')

    # Add Region codes and names
    temp_sf <- add_region_info(temp_sf,'code_state')

    # reorder columns
    temp_sf <- dplyr::select(temp_sf,'code_muni', 'name_muni', 'code_state', 'abbrev_state', 'name_state', 'code_region', 'name_region', 'geom')

    # Use UTF-8 encoding
    temp_sf <- use_encoding_utf8(temp_sf)

    # Capitalize the first letter
    temp_sf$name_muni <- stringr::str_to_title(temp_sf$name_muni)

    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
    temp_sf <- harmonize_projection(temp_sf)

    # strange error in Rio state in 2000
    temp_sf <- subset(temp_sf, code_state > 0)

    # strange error in Espirito Santo in 2000
    unique_codes <- unique(temp_sf$code_state)
    if (length(unique_codes)==2 & any(unique_codes %in% 32)) {
      temp_sf <- subset(temp_sf, code_state ==32)
      }

    # strange error in RJ in 2000
    if (length(unique_codes)==3 & any(unique_codes %in% 33)) {
      temp_sf <- subset(temp_sf, code_state ==33)
    }

    # strange error in SC 2000
    # remove geometries with area == 0
    temp_sf <- temp_sf[ as.numeric(st_area(temp_sf)) != 0, ]

    # Make any invalid geom valid # st_is_valid( sf)
    temp_sf <- sf::st_make_valid(temp_sf)

    # keep code as.numeric()
    temp_sf$code_muni <- as.numeric(temp_sf$code_muni)
    temp_sf$code_state <- as.numeric(temp_sf$code_state)

    # simplify
    temp_sf_simplified <- simplify_temp_sf(temp_sf)

    # convert to MULTIPOLYGON
    temp_sf <- to_multipolygon(temp_sf)
    temp_sf_simplified <- to_multipolygon(temp_sf_simplified)

    # Save cleaned sf in the cleaned directory
    dir.dest.file <- paste0(dir.dest,"/")

    # save each state separately
    for (c in unique(temp_sf$code_state)) { # c <- 11

      temp2 <- subset(temp_sf, code_state ==c)
      temp2_simplified <- subset(temp_sf_simplified, code_state ==c)

      file.name <- paste0(unique(substr(temp2$code_state,1,2)),"MU",".gpkg")

      # original
      i <- paste0(dir.dest.file,file.name)
      sf::st_write(temp2, i, overwrite=TRUE) # append = FALSE,delete_dsn =T,delete_layer=T)

      # simplified
      i <- gsub(".gpkg", "_simplified.gpkg", i)
      sf::st_write(temp2_simplified, i, overwrite=TRUE) # append = FALSE,delete_dsn =T,delete_layer=T)
    }

  }
}

# apply function in parallel
future::plan(multisession)
future_map(.x=sub_dirs, .f=clean_muni, year='all')

rm(list= ls())
gc(reset = T)
