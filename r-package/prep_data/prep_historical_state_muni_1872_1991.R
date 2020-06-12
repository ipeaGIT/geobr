### Libraries (use any library as necessary)

library(RCurl)
library(tidyverse)
library(stringr)
library(sf)
library(magrittr)
library(data.table)
library(parallel)
library(lwgeom)

####### Load Support functions to use in the preprocessing of the data

source("C:/Users/canog/Documents/Projetos/geobr/r-package/prep_data/prep_functions.R")




# If the data set is updated regularly, you should create a function that will have
# a `date` argument download the data
# unnecessary


# Root directory
# root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw"
root_dir <- "C:/Users/canog/Documents/Projetos/repositorios"
head_dir<-root_dir
setwd(root_dir)




#### 0. Download original data sets from IBGE ftp -----------------

# ftp with original data
  url <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/evolucao_da_divisao_territorial_do_brasil/evolucao_da_divisao_territorial_do_brasil_1872_2010/municipios_1872_1991/divisao_territorial_1872_1991/"

  # List Years/folders available
    years <- list_foulders(url)

# create folders to download and store raw data of each year
  dir.create("./historical_state_muni_1872_1991")

# For each year
  for (i in years){ # i <- years[4]

  # list files
    subdir <- paste0(url, i,"/")
    files <-list_foulders(subdir)

  # create folder to download and store raw data of each year
    dir.create(paste0("./historical_state_muni_1872_1991/",i))


  # Download zipped files
    for (filename in files) {
        download.file(url = paste(subdir, filename, sep = ""),
                      destfile = paste0("./historical_state_muni_1872_1991/",i,"/",filename))
      }
  }

# rm(list=setdiff(ls(), c("years")))
gc(reset = T)



########  1. Unzip original data sets downloaded from IBGE -----------------

# Root directory
  root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw/historical_state_muni_1872_1991"
  setwd(root_dir)

# List all zip files for all years
  all_zipped_files <- list.files(full.names = T, recursive = T, pattern = ".zip")

unzip_fun(all_zipped_files[1])

# Select only files with municipalities and states
  all_zipped_files <- all_zipped_files[all_zipped_files %like% "limite|malha|litigio"]

# create computing clusters
  cl <- parallel::makeCluster(detectCores())
  parallel::clusterExport(cl=cl, varlist= c("all_zipped_files", "head_dir"), envir=environment())

# apply function in parallel
  parallel::parLapply(cl, all_zipped_files, unzip_fun)
  stopCluster(cl)


rm(list=setdiff(ls(), c("root_dir")))
gc(reset = T)









#### 2. Create folders to save sf.rds files  -----------------


# create directory to save cleaned shape files in sf format
  dir.create(file.path("shapes_in_sf_all_years_cleaned"), showWarnings = FALSE)

# create a subdirectory states and municipalities
  dir.create(file.path("shapes_in_sf_all_years_cleaned", "uf"), showWarnings = FALSE)
  dir.create(file.path("shapes_in_sf_all_years_cleaned", "municipio"), showWarnings = FALSE)







#### 3. Clean Municipalities  -----------------

  # Root directory
  root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw/historical_state_muni_1872_1991"
  setwd(root_dir)

# List years of data available
  years <- list.dirs(path =".", recursive = F)
  years <- years[1:11]
  years <- substr(years, 3, 6)




# Create function to clean municipalities, additing dipusted lands in case they exist
  clean_muni <- function(year){

  # year <- 1872

  # create a subdirectory of year
    dir.create(file.path("./shapes_in_sf_all_years_cleaned", "municipio",year), showWarnings = T)

  # List of muni shape files of that year
    all_shps <- list.files(path = paste0("./",year), full.names = T, recursive = T, pattern = ".shp")
    all_shps <- all_shps[!(all_shps %like% ".xml")] # remove .xml files
    all_shps <- all_shps[all_shps %like% "malha|lit"]

  ## Treat Muni file
  # read shapes
    temp_sf <- st_read(all_shps[1], quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")

  # dplyr::rename and subset columns
    names(temp_sf) <- names(temp_sf) %>% tolower()

    if (year %like% "1911"){
        temp_sf <- dplyr::rename(temp_sf, code_muni = geocodigo, name_muni = nomemuni )
        temp_sf <- dplyr::select(temp_sf, c('code_muni', 'name_muni', 'geometry'))
        } else {
    if (year %like% "1991"){
        temp_sf <- dplyr::rename(temp_sf, code_muni = br91poly_i, name_muni = nomemunicp )
        temp_sf <- dplyr::select(temp_sf, c('code_muni', 'name_muni', 'geometry'))

        # to title case
        a <- temp_sf$name_muni
        a <- stringr::str_to_title(a)
        # fix de, da, do, das
        a <- gsub("(De |Da | Do| Das)", replacement = "\\L\\1", a, perl = TRUE)
        # fix d'
        a <- gsub("(D')([[:lower:]]{1})", replacement = "\\L\\1\\U\\2", a, perl = TRUE)
        temp_sf$name_muni <- a
        } else {

    # other years
      temp_sf <- dplyr::rename(temp_sf, code_muni = codigo, name_muni = nome )
      temp_sf <- dplyr::select(temp_sf, c('code_muni', 'name_muni', 'geometry'))
        }}

  # Use UTF-8 encoding
    temp_sf <- use_encoding_utf8(temp_sf)

  # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
    temp_sf <- harmonize_projection(temp_sf)


  # Make an invalid geometry valid # st_is_valid( sf)
    temp_sf <- lwgeom::st_make_valid(temp_sf)


  ## Treat Litigio (disputed territory) file
    if(length(all_shps) > 1){

      liti <- st_read(all_shps[2], quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")

      # dplyr::rename and subset columns
      names(liti) <- names(liti) %>% tolower()

      liti <- dplyr::rename(liti, code_muni = id, name_muni = nome )
      liti <- dplyr::select(liti, c('code_muni', 'name_muni', 'geometry')) # 'latitudes', 'longitudes' da sede do municipio

      # Use UTF-8 encoding
      liti <- use_encoding_utf8(liti)

      # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
      liti <- harmonize_projection(liti)

      # Make an invalid geometry valid # st_is_valid( sf)
      liti <- lwgeom::st_make_valid(liti)

      temp_sf <- do.call('rbind', list(temp_sf, liti))

    }

    temp_sf$code_state <- substr(temp_sf$code_muni, 1, 2)
    temp_sf <- temp_sf %>% mutate(abbrev_state =
                                       ifelse(code_state== 11, "RO",
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
                                       ifelse(code_state== 53, "DF",NA
                                       ))))))))))))))))))))))))))))

    # reorder columns
    temp_sf <- dplyr::select(temp_sf, 'code_muni', 'name_muni', 'code_state', 'abbrev_state', 'geometry')

    # simplify
    temp_sf_simp <- simplify_temp_sf(temp_sf)

    as.numeric(object.size(temp_sf_simp)) /     as.numeric(object.size(temp_sf))

    # Save cleaned sf in the cleaned directory
    destdir <- file.path("./shapes_in_sf_all_years_cleaned", "municipio",year)
    # readr::write_rds(temp_sf, path = paste0(destdir,"/municipios_", year, ".rds"), compress="gz" )
    sf::st_write(temp_sf,     dsn  = paste0(destdir,"/municipios_", year, ".gpkg") )
    sf::st_write(temp_sf_simp, dsn  = paste0(destdir,"/municipios_", year, "_simplified", ".gpkg"))
  }



# Apply function to save original data sets in rds format

  # create computing clusters
  cl <- parallel::makeCluster(detectCores())

  clusterEvalQ(cl, c(library(data.table), library(dplyr), library(readr), library(stringr), library(sf)))
  parallel::clusterExport(cl=cl, varlist= c("years"), envir=environment())

  # apply function in parallel
  parallel::parLapply(cl, years, clean_muni)
  stopCluster(cl)

  rm(list=setdiff(ls(), c("root_dir")))
  gc(reset = T)










#### 4. Clean States/Provinces  -----------------


# List years of data available
  years <- list.dirs(path =".", recursive = F)
  years <- years[1:11]
  years <- substr(years, 3, 6)




# Create function to clean municipalities, additing dipusted lands in case they exist
clean_state <- function(year){

  # year <- 1872

  # create a subdirectory of year
    dir.create(file.path("./shapes_in_sf_all_years_cleaned", "uf",year), showWarnings = FALSE)

  # List of muni shape files of that year
    all_shps <- list.files(path = paste0("./",year), full.names = T, recursive = T, pattern = ".shp")
    all_shps <- all_shps[!(all_shps %like% ".xml")] # remove .xml files
    all_shps <- all_shps[all_shps %like% "limite|lit"]

## Treat Muni file
# read shapes
    temp_sf <- st_read(all_shps[1], quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")

    # dplyr::rename and subset columns
    names(temp_sf) <- names(temp_sf) %>% tolower()

                temp_sf <- dplyr::rename(temp_sf, name_state = nome )
                temp_sf <- dplyr::select(temp_sf, c('name_state', 'geometry'))

                # Add code_state

                temp_sf <- dplyr::mutate(code_state = ifelse(name_state== "Rondonia",11,
                                                      ifelse(name_state== "Acre",12,
                                                      ifelse(name_state== "Amazonas",13,
                                                      ifelse(name_state== "Roraima",14,
                                                      ifelse(name_state== "Par?",15,
                                                      ifelse(name_state== "Amap?",16,
                                                      ifelse(name_state== "Tocantins",17,
                                                      ifelse(name_state== "Maranh?o",21,
                                                      ifelse(name_state== "Piau?",22,
                                                      ifelse(name_state== "Cear?",23,
                                                      ifelse(name_state== "Rio Grande do Norte",24,
                                                      ifelse(name_state== "Paraiba",25,
                                                      ifelse(name_state== "Pernambuco",26,
                                                      ifelse(name_state== "Alagoas",27,
                                                      ifelse(name_state== "Sergipe",28,
                                                      ifelse(name_state== "Bahia",29,
                                                      ifelse(name_state== "Minas Gerais",31,
                                                      ifelse(name_state== "Espirito Santo",32,
                                                      ifelse(name_state== "Rio de Janeiro",33,
                                                      ifelse(name_state== "S?o Paulo",35,
                                                      ifelse(name_state== "Paran?",41,
                                                      ifelse(name_state== "Santa Catarina",42,
                                                      ifelse(name_state== "Rio Grande do Sul",43,
                                                      ifelse(name_state== "Mato Grosso do Sul",50,
                                                      ifelse(name_state== "Mato Grosso",51,
                                                      ifelse(name_state== "Goi?s",52,
                                                      ifelse(name_state== "Distrito Federal",53,NA
                                                             ))))))))))))))))))))))))))))

                # add State abbreviation
                temp_sf <- temp_sf %>% mutate(abbrev_state =  ifelse(code_state== 11, "RO",
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
                temp_sf$code_region <- substr(temp_sf$code_state, 1,1) %>% as.numeric()
                temp_sf <- temp_sf %>% dplyr::mutate(name_region = ifelse(code_region==1, 'Norte',
                                                                   ifelse(code_region==2, 'Nordeste',
                                                                   ifelse(code_region==3, 'Sudeste',
                                                                   ifelse(code_region==4, 'Sul',
                                                                   ifelse(code_region==5, 'Centro Oeste', NA))))))
                # reorder columns
                temp_sf <- dplyr::select(temp_sf, 'code_state', 'abbrev_state', 'name_state', 'code_region', 'name_region', 'geometry')

  # Use UTF-8 encoding
    temp_sf$name_state <- stringi::stri_encode(as.character(temp_sf$name_state), "UTF-8")

  # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
    temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }

  # Convert columns from factors to characters
    temp_sf %>% dplyr::mutate_if(is.factor, as.character) -> temp_sf


  # Make an invalid geometry valid # st_is_valid( sf)
    temp_sf <- lwgeom::st_make_valid(temp_sf)


  ## Treat Litigio (disputed territory) file
    if(length(all_shps) > 1){

      liti <- st_read(all_shps[2], quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")

    # dplyr::rename and subset columns
      names(liti) <- names(liti) %>% tolower()

      liti$id <- NULL
      liti <- dplyr::rename(liti, name_state = nome )
      liti <- dplyr::select(liti, c('name_state', 'geometry'))

    # Use UTF-8 encoding
      liti$name_state <- stringi::stri_encode(as.character(liti$name_state), "UTF-8")

    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
      liti <- if( is.na(st_crs(liti)) ){ st_set_crs(liti, 4674) } else { st_transform(liti, 4674) }

    # Convert columns from factors to characters
      liti %>% dplyr::mutate_if(is.factor, as.character) -> liti

    # Make an invalid geometry valid # st_is_valid( sf)
      liti <- lwgeom::st_make_valid(liti)

    # pile states and diputed land
      temp_sf <- do.call('rbind', list(temp_sf, liti))

    # simplify
      temp_sf7 <- st_transform(temp_sf, crs=3857) %>%
        sf::st_simplify(preserveTopology = T, dTolerance = 100) %>%
        st_transform(crs=4674)


    }

    # Save cleaned sf in the cleaned directory
    destdir <- file.path("./shapes_in_sf_all_years_cleaned", "uf",year)
    readr::write_rds(temp_sf, path = paste0(destdir,"/states_", year, ".rds"), compress="gz" )
    sf::st_write(temp_sf,     dsn  = paste0(destdir,"/states_", year, ".gpkg") )
    sf::st_write(temp_sf7,    dsn  = paste0(destdir,"/states_", year, " _simplified", ".gpkg"))
  }



# Apply function to save original data sets in rds format
  # create computing clusters
  cl <- parallel::makeCluster(detectCores())

  clusterEvalQ(cl, c(library(data.table), library(dplyr), library(readr), library(stringr), library(sf)))
  parallel::clusterExport(cl=cl, varlist= c("years"), envir=environment())

  # apply function in parallel
  parallel::parLapply(cl, years, clean_state)
  stopCluster(cl)

  rm(list=setdiff(ls(), c("root_dir")))
  gc(reset = T)




  # DO NOT run
  ## remove all unzipped shape files
  #   # list all unzipped shapes
      # root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw/historical_state_muni_1872_1991"
      # f <- list.files(path = root_dir, full.names = T, recursive = T, pattern = ".shx|.shp|.prj|.dbf|.cpg|.sbx|.sbn|.xml")
      # file.remove(f)


