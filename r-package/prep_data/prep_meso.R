####### Load Support functions to use in the preprocessing of the data
source("./prep_functions.R")
source('./malhas_municipais_function.R')


###### Cleaning MESO files --------------------------------
malhas_municipais(region='meso_regiao', year='2019')
#malhas_municipais(region='meso_regiao', year='all')

meso_dir <-  "//STORAGE6/usuarios/# DIRUR #/ASMEQ/geobr/data-raw/malhas_municipais"
sub_dirs <- list.dirs(path = meso_dir, recursive = F)

sub_dirs <- sub_dirs[sub_dirs %like% paste0(2000:2019,collapse = "|")]

# sub_dirs <- sub_dirs[sub_dirs %like% 2019]


# create a function that will clean the sf files according to particularities of the data in each year
clean_meso <- function(e){ #  e <- sub_dirs[1]

  # get year of the folder
  last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
  year <- last4(e)

  # create directory to save original shape files in sf format
  dir.create(file.path("shapes_in_sf_all_years_cleaned"), showWarnings = FALSE)

  # create a subdirectory of states, municipalities, micro and meso regions
  dir.create(file.path("shapes_in_sf_all_years_cleaned/meso_regiao/"), showWarnings = FALSE)

  # create a subdirectory of years
  dir.create(file.path(paste0("shapes_in_sf_all_years_cleaned/meso_regiao/",year)), showWarnings = FALSE)
  gc(reset = T)

  dir.dest<- file.path(paste0("./shapes_in_sf_all_years_cleaned/meso_regiao/",year))

  # list all sf files in that year/folder
  sf_files <- list.files(e, full.names = T, recursive = T, pattern = ".gpkg$")

  sf_files <- sf_files[sf_files %like% "Mesorregioes"]

  # for each file
  for (i in sf_files){ #  i <- sf_files[1]

    # read sf file
    temp_sf <- st_read(i)
    #temp_sf

    if (year %like% "2000|2001"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_meso = geocodigo, name_meso = nome)
      temp_sf <- dplyr::select(temp_sf, c('code_meso', 'name_meso', 'geom'))
    }

    if (year %like% "2010"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_meso = cd_geocodu, name_meso = nm_meso)
      temp_sf <- dplyr::select(temp_sf, c('code_meso', 'name_meso', 'geom'))
    }

    if (year %like% "2013|2014|2015|2016|2017|2018"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_meso = cd_geocme, name_meso = nm_meso)
      temp_sf <- dplyr::select(temp_sf, c('code_meso', 'name_meso', 'geom'))
    }

    if (year %like% "2019"){
      # dplyr::rename and subset columns
      names(temp_sf) <- names(temp_sf) %>% tolower()
      temp_sf <- dplyr::rename(temp_sf, code_meso = cd_meso, name_meso = nm_meso)
      temp_sf <- dplyr::select(temp_sf, c('code_meso', 'name_meso', 'geom'))
    }

    # Use UTF-8 encoding
    temp_sf$name_meso <- stringi::stri_encode(as.character(temp_sf$name_meso), "UTF-8")

    # Capitalize the first letter
    temp_sf$name_meso <- stringr::str_to_title(temp_sf$name_meso)

    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
    temp_sf <- harmonize_projection(temp_sf)

    # Convert columns from factors to characters
    temp_sf %>% dplyr::mutate_if(is.factor, as.character) -> temp_sf

    # Make an invalid geometry valid # st_is_valid( sf)
    temp_sf <- sf::st_make_valid(temp_sf)

    # keep code as.numeric()
    temp_sf$code_meso <- as.numeric(temp_sf$code_meso)

    # simplify
    temp_sf_simplified <- st_transform(temp_sf, crs=3857) %>% sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)

    # Save cleaned sf in the cleaned directory
    dir.dest.file <- paste0(dir.dest,"/")

    file.name <- paste0(unique(substr(temp_sf$code_meso,1,2)),"ME",".gpkg")

    i <- paste0(dir.dest.file,file.name)

    sf::st_write(temp_sf, i,append = FALSE,delete_dsn =T,delete_layer=T)

    i <- gsub(".gpkg", "_simplified.gpkg", i)

    sf::st_write(temp_sf_simplified, i,append = FALSE,delete_dsn =T,delete_layer=T)

  }
}

future::plan(multiprocess)

future_map(sub_dirs, clean_meso)

rm(list= ls())
gc(reset = T)




###### Correcting number of digits of meso regions in 2010  --------------------------------
# issue #20


# Dirs
meso_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais//shapes_in_sf_all_years_cleaned/meso_regiao"
sub_dirs <- list.dirs(path =meso_dir, recursive = F)

# dirs of 2010 (problematic data) ad 2013 (reference data)
sub_dir_2010 <- sub_dirs[sub_dirs %like% 2010]
sub_dir_2013 <- sub_dirs[sub_dirs %like% 2013]


# list sf files in each dir
sf_files_2010 <- list.files(sub_dir_2010, full.names = T, pattern = ".gpkg")
sf_files_2013 <- list.files(sub_dir_2013, full.names = T, pattern = ".gpkg")


# Create function to correct number of digits of meso regions in 2010

# use data of 2013 to add code and name of meso regions in the 2010 data
correct_meso_digits <- function(a2010_sf_meso_file){ # a2010_sf_meso_file <- sf_files_2010[1]

  # Get UF of the file
  get_uf <- function(x){if (grepl("simplified",x)) {
    substr(x, nchar(x)-19, nchar(x)-18)
  } else {substr(x, nchar(x)-8, nchar(x)-7)}
  }
  uf <- get_uf(a2010_sf_meso_file)


  # read 2010 file
  temp2010 <- st_read(a2010_sf_meso_file)

  # read 2019 file


  temp2013 <- sf_files_2013[ if (grepl("simplified",a2010_sf_meso_file)) {
    (sf_files_2013 %like% paste0("/",uf)) & (sf_files_2013 %like% "simplified")
 } else {
    (sf_files_2013 %like% paste0("/",uf)) & !(sf_files_2013 %like% "simplified")
  }]
  temp2013 <- st_read(temp2013)

  # keep only code and name columns
  table2013 <- temp2013 %>% as.data.frame()
  table2013 <- dplyr::select(table2013, code_meso, name_meso)

  # update code_meso
  sf2010 <- left_join(temp2010, table2013, by="name_meso")
  sf2010 <- dplyr::select(sf2010, code_meso=code_meso.y, name_meso, geom)

  # Save file
  st_write(sf2010,a2010_sf_meso_file,append = FALSE,delete_dsn =T,delete_layer=T)
}

# Apply function
lapply(sf_files_2010, correct_meso_digits)


