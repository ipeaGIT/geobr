####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")
source('./prep_data/download_malhas_municipais_function.R')

setwd('L:/# DIRUR #/ASMEQ/geobr/data-raw')

#pblapply(X=c(2000,2001,2005,2007,2010,2013:2020), FUN=download_ibge)

###### download raw data --------------------------------
# unzip_to_geopackage(region='micro_regiao', year='2019')
unzip_to_geopackage(region='micro_regiao', year='all')


###### Cleaning MICRO files --------------------------------
setwd('L:/# DIRUR #/ASMEQ/geobr/data-raw/malhas_municipais')

micro_dir <- paste0(getwd(),"/shapes_in_sf_all_years_original/micro_regiao")

sub_dirs <- list.dirs(path=micro_dir, recursive = F)

sub_dirs <- sub_dirs[sub_dirs %like% paste0(2000:2020,collapse = "|")]

# sub_dirs <- sub_dirs[sub_dirs %like% 2019]

# create a function that will clean the sf files according to particularities of the data in each year0
clean_micro <- function( e ){ #  e <- sub_dirs[ sub_dirs %like% 2000]

  options(encoding = "UTF-8")

  # get year of the folder
  last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
  year <- last4(e)
  year

  # create directory to save original shape files in sf format
  dir.create(file.path("shapes_in_sf_all_years_cleaned2"), showWarnings = FALSE)

  # create a subdirectory of states, municipalities, micro and meso regions
  dir.create(file.path("shapes_in_sf_all_years_cleaned2/micro_regiao/"), showWarnings = FALSE)

  # create a subdirectory of years
  dir.create(file.path(paste0("shapes_in_sf_all_years_cleaned2/micro_regiao/",year)), showWarnings = FALSE)
  gc(reset = T)

  dir.dest <- file.path(paste0("./shapes_in_sf_all_years_cleaned2/micro_regiao/",year))


  # list all sf files in that year/folder
  sf_files <- list.files(e, full.names = T, recursive = T, pattern = ".gpkg$")

  #sf_files <- sf_files[sf_files %like% "Microrregioes"]

  # for each file
  for (i in sf_files){ #  i <- sf_files[8]

    # read sf file
    temp_sf <- st_read(i)
    names(temp_sf) <- names(temp_sf) %>% tolower()


    if (year %like% "2000|2001"){
      # dplyr::rename and subset columns
      temp_sf <- dplyr::select(temp_sf, c('code_micro'= geocodigo, 'name_micro'=nome, 'geom'))
    }


    if (year %like% "2010"){
      # dplyr::rename and subset columns
      temp_sf <- dplyr::select(temp_sf, c('code_micro'=cd_geocodu, 'name_micro'=nm_micro, 'geom'))
     }

    if (year %like% "2013|2014|2015|2016|2017|2018"){
      # dplyr::rename and subset columns
      temp_sf <- dplyr::select(temp_sf, c('code_micro'=cd_geocmi, 'name_micro'=nm_micro, 'geom'))
    }

    if (year %like% "2019|2020"){
      # dplyr::rename and subset columns
      temp_sf <- dplyr::select(temp_sf, c('code_micro'=cd_micro, 'name_micro'=nm_micro, 'abbrev_state'=sigla_uf, 'geom'))
    }

    # Use UTF-8 encoding
    temp_sf <- use_encoding_utf8(temp_sf)


    # add name_state
    temp_sf$code_state <- substring(temp_sf$code_micro, 1,2)
    temp_sf <- add_state_info(temp_sf,column = 'code_micro')

    # reorder columns
    temp_sf <- dplyr::select(temp_sf, 'code_state', 'abbrev_state', 'name_state', 'code_micro', 'name_micro', 'geom')

    # Capitalize the first letter
    temp_sf$name_micro <- stringr::str_to_title(temp_sf$name_micro)

    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
    temp_sf <- harmonize_projection(temp_sf)

    # strange error in Bahia 2000
    # remove geometries with area == 0
    temp_sf <- temp_sf[ as.numeric(st_area(temp_sf)) != 0, ]

    # strange error in Maranhao 2000
    # micro_21 <- geobr::read_micro_region(code_micro = 21, year=2000)
    # mapview(micro_21) + temp_sf[c(7),]

    if (year==2000 & temp_sf$code_state[1]==21) {
    temp_sf[3, c('code_state', 'abbrev_state', 'name_state', 'code_micro', 'name_micro')] <- c(21, 'MA', 'Maranhão', 210520, 'Gerais De Balsas' )
    temp_sf[7, c('code_state', 'abbrev_state', 'name_state', 'code_micro', 'name_micro')] <- c(21, 'MA', 'Maranhão', 210521, 'Chapadas Das Mangabeiras' )
    }

    # Make an invalid geometry valid # st_is_valid( sf)
    temp_sf <- sf::st_make_valid(temp_sf)

    # keep code as.numeric()
    temp_sf$code_micro <- as.numeric(temp_sf$code_micro)
    temp_sf$code_state <- as.numeric(temp_sf$code_state)

    # simplify
    temp_sf_simplified <- simplify_temp_sf(temp_sf)

    # convert to MULTIPOLYGON
    temp_sf <- to_multipolygon(temp_sf)
    temp_sf_simplified <- to_multipolygon(temp_sf_simplified)

    # Save cleaned sf in the cleaned directory
    dir.dest.file <- paste0(dir.dest,"/")

    # save each state separately
    for( c in unique(temp_sf$code_state)){ # c <- 11

      temp2 <- subset(temp_sf, code_state ==c)
      temp2_simplified <- subset(temp_sf_simplified, code_state ==c)

      file.name <- paste0(unique(substr(temp2$code_state,1,2)),"MI",".gpkg")

      # original
      i <- paste0(dir.dest.file,file.name)
      sf::st_write(temp2, i, overwrite=TRUE)

      # simplified
      i <- gsub(".gpkg", "_simplified.gpkg", i)
      sf::st_write(temp2_simplified, i, overwrite=TRUE)
    }


  }
}


# apply function in parallel
future::plan(multisession)
future_map(sub_dirs, clean_micro)

rm(list= ls())
gc(reset = T)


###### Correcting number of digits of micro regions in 2010  --------------------------------
# issue #20
# use data of 2013 to add code and name of micro regions in the 2010 data

# Dirs
micro_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais//shapes_in_sf_all_years_cleaned2/micro_regiao"
sub_dirs <- list.dirs(path =micro_dir, recursive = F)

# dirs of 2010 (problematic data) ad 2013 (reference data)
sub_dir_2010 <- sub_dirs[sub_dirs %like% 2010]
sub_dir_2013 <- sub_dirs[sub_dirs %like% 2013]


# list sf files in each dir
sf_files_2010 <- list.files(sub_dir_2010, full.names = T, pattern = ".gpkg")
sf_files_2013 <- list.files(sub_dir_2013, full.names = T, pattern = ".gpkg")


# Create function to correct number of digits of meso regions in 2010, based on 2013 data
correct_micro_digits <- function(a2010_sf_micro_file){ # a2010_sf_micro_file <- sf_files_2010[1]
# for (a2010_sf_micro_file in sf_files_2010) {

  # Get UF of the file
  get_uf <- function(x){if (grepl("simplified",x)) {
    substr(x, nchar(x)-19, nchar(x)-18)
  } else {substr(x, nchar(x)-8, nchar(x)-7)}
  }
  uf <- get_uf(a2010_sf_micro_file)

  # read 2010 file
  temp2010 <- st_read(a2010_sf_micro_file)

  # dplyr::rename and subset columns
  temp2010 <- temp2010 %>%  dplyr::mutate(name_micro =as.character(name_micro))
  temp2010 <- temp2010 %>%  dplyr::mutate(name_micro = ifelse(name_micro == "Moji Das Cruzes","Mogi Das Cruzes",
                                                              ifelse(name_micro == "Piraçununga","Pirassununga",
                                                                     ifelse(name_micro == "Moji-Mirim","Moji Mirim",
                                                                            ifelse(name_micro == "São Miguel D'oeste","São Miguel Do Oeste",
                                                                                   ifelse(name_micro == "Serras Do Sudeste","Serras De Sudeste",
                                                                                          ifelse(name_micro == "Vão Do Paraná","Vão Do Paranã",name_micro)))))))


  # read 2013 file
  temp2013 <- sf_files_2013[if (grepl("simplified",a2010_sf_micro_file)) {
    (sf_files_2013 %like% paste0("/",uf)) & (sf_files_2013 %like% "simplified")
  } else {
    (sf_files_2013 %like% paste0("/",uf)) & !(sf_files_2013 %like% "simplified")
  }]
  temp2013 <- st_read(temp2013)

  # keep only code and name columns
  table2013 <- temp2013 %>% as.data.frame()
  table2013 <- dplyr::select(table2013, code_micro, name_micro)

  # update code_micro
  sf2010 <- left_join(temp2010, table2013, by="name_micro")
  sf2010 <- dplyr::select(sf2010, code_micro=code_micro.y, name_micro, geom)

  # Save file
  # write_rds(sf2010, path = a2010_sf_micro_file, compress="gz" )
  st_write(sf2010,a2010_sf_micro_file,append = FALSE,delete_dsn =T,delete_layer=T)
}


# apply function in parallel
future::plan(multisession)
future_map(a2010_sf_micro_file, correct_micro_digits)


