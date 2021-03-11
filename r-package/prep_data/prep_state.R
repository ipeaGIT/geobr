####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")
source('./prep_data/download_malhas_municipais_function.R')


setwd('L:/# DIRUR #/ASMEQ/geobr/data-raw')


###### download raw data --------------------------------
pblapply(X=c(2000,2001,2005,2007,2010,2013:2020), FUN=download_ibge)



###### Unzip raw data --------------------------------
unzip_to_geopackage(region='uf',year='all')


###### Cleaning UF files --------------------------------

uf_dir <-  paste0(getwd(),"/shapes_in_sf_all_years_original/uf")
uf_dir <-  "//STORAGE6/usuarios/# DIRUR #/ASMEQ/geobr/data-raw/malhas_municipais"
sub_dirs <- list.dirs(path =uf_dir, recursive = F)

sub_dirs <- sub_dirs[sub_dirs %like% paste0(2000:2020,collapse = "|")]



# create a function that will clean the sf files according to particularities of the data in each year
# clean_states <- function( e ){ #  e <- sub_dirs[10]

clean_states <- function( e ){

  # get year of the folder
  last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
  year <- last4(e)

  # create directory to save original shape files in sf format
  dir.create(file.path("shapes_in_sf_all_years_cleaned"), showWarnings = FALSE)

  # create a subdirectory of states, municipalities, micro and meso regions
  dir.create(file.path("shapes_in_sf_all_years_cleaned/uf/"), showWarnings = FALSE)

  # create a subdirectory of years
  dir.create(file.path(paste0("shapes_in_sf_all_years_cleaned/uf/",year)), showWarnings = FALSE)
  gc(reset = T)

  dir.dest<- file.path(paste0("./shapes_in_sf_all_years_cleaned/uf/",year))


  # list all sf files in that year/folder
  sf_files <- list.files(e, full.names = T, recursive = T, pattern = ".gpkg$")

  #sf_files <- sf_files[sf_files %like% "_UF_"]

  # for each file
  for (i in sf_files){ #  i <- sf_files[1]

    # read sf file
    temp_sf <- st_read(i)

    if (year %like% "2000|2001"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_state = geocodigo, name_state = nome)
      temp_sf <- dplyr::select(temp_sf, c('code_state', 'name_state', 'geom'))
    }

    if (year %like% "2010"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_state = cd_geocodu, name_state = nm_estado)
      temp_sf <- dplyr::select(temp_sf, c('code_state', 'name_state', 'geom'))
    }

    if (year %like% "2013|2014|2015|2016|2017|2018"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_state = cd_geocuf, name_state = nm_estado)
      temp_sf <- dplyr::select(temp_sf, c('code_state', 'name_state', 'geom'))
    }

    if (year %like% "2019|2020"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_state = cd_uf, name_state = nm_uf)
      temp_sf <- dplyr::select(temp_sf, c('code_state', 'name_state', 'geom'))
    }

    # add State abbreviation
    # temp_sf <- add_state_info(temp_sf,'code_state')

    # add name_state
    temp_sf <- temp_sf %>% mutate(name_state =  ifelse(code_state== 11, utf8::as_utf8("Rondônia"),
                                                       ifelse(code_state== 12, utf8::as_utf8("Acre"),
                                                              ifelse(code_state== 13, utf8::as_utf8("Amazônas"),
                                                                     ifelse(code_state== 14, utf8::as_utf8("Roraima"),
                                                                            ifelse(code_state== 15, utf8::as_utf8("Pará"),
                                                                                   ifelse(code_state== 16, utf8::as_utf8("Amapá"),
                                                                                          ifelse(code_state== 17, utf8::as_utf8("Tocantins"),
                                                                                                 ifelse(code_state== 21, utf8::as_utf8("Maranhão"),
                                                                                                        ifelse(code_state== 22, utf8::as_utf8("Piauí"),
                                                                                                               ifelse(code_state== 23, utf8::as_utf8("Ceará"),
                                                                                                                      ifelse(code_state== 24, utf8::as_utf8("Rio Grande do Norte"),
                                                                                                                             ifelse(code_state== 25, utf8::as_utf8("Paraíba"),
                                                                                                                                    ifelse(code_state== 26, utf8::as_utf8("Pernambuco"),
                                                                                                                                           ifelse(code_state== 27, utf8::as_utf8("Alagoas"),
                                                                                                                                                  ifelse(code_state== 28, utf8::as_utf8("Sergipe"),
                                                                                                                                                         ifelse(code_state== 29, utf8::as_utf8("Bahia"),
                                                                                                                                                                ifelse(code_state== 31, utf8::as_utf8("Minas Gerais"),
                                                                                                                                                                       ifelse(code_state== 32, utf8::as_utf8("Espírito Santo"),
                                                                                                                                                                              ifelse(code_state== 33, utf8::as_utf8("Rio de Janeiro"),
                                                                                                                                                                                     ifelse(code_state== 35, utf8::as_utf8("São Paulo"),
                                                                                                                                                                                            ifelse(code_state== 41, utf8::as_utf8("Paraná"),
                                                                                                                                                                                                   ifelse(code_state== 42, utf8::as_utf8("Santa Catarina"),
                                                                                                                                                                                                          ifelse(code_state== 43, utf8::as_utf8("Rio Grande do Sul"),
                                                                                                                                                                                                                 ifelse(code_state== 50, utf8::as_utf8("Mato Grosso do Sul"),
                                                                                                                                                                                                                        ifelse(code_state== 51, utf8::as_utf8("Mato Grosso"),
                                                                                                                                                                                                                               ifelse(code_state== 52, utf8::as_utf8("Goiás"),
                                                                                                                                                                                                                                      ifelse(code_state== 53, utf8::as_utf8("Distrito Federal"), "!error!"))))))))))))))))))))))))))))



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

    # Make any invalid geom valid # st_is_valid( sf)
    temp_sf <- sf::st_make_valid(temp_sf)

    # keep code as.numeric()
    temp_sf$code_state <- as.numeric(temp_sf$code_state)

    # simplify
    temp_sf_simplified <- simplify_temp_sf(temp_sf)

    # convert to MULTIPOLYGON
    temp_sf <- to_multipolygon(temp_sf)
    temp_sf_simplified <- to_multipolygon(temp_sf_simplified)

    # Save cleaned sf in the cleaned directory
    dir.dest.file <- paste0(dir.dest,"/")

    #file.name <- paste0(unique(substr(temp_sf$code_state,1,2)),"UF",".gpkg")
    file.name <- paste0("UF",".gpkg")

    i <- paste0(dir.dest.file,file.name)

    sf::st_write(temp_sf, i, overwrite=TRUE)

    i <- gsub(".gpkg", "_simplified.gpkg", i)

    sf::st_write(temp_sf_simplified, i, overwrite=TRUE)

  }
}

# apply function in parallel
future::plan(multisession)
future_map(sub_dirs, clean_states)

rm(list= ls())
gc(reset = T)
