library(RCurl)
#library(tidyverse)
library(stringr)
library(sf)
library(janitor)
library(dplyr)
library(readr)
library(parallel)
library(furrr)
library(data.table)
# library(xlsx)
library(magrittr)
library(devtools)
library(lwgeom)
library(stringi)
library(geobr)

library(utils)
library(RCurl)
library(data.table)
library(pbapply)


# Region options:
# uf, municipio, meso_regiao, micro_regiao



########  0. Download Raw zipped files for all years ------------

ftp <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/"

# create folders to download and store raw data of each year
dir.create("./malhas_municipais")

download_ibge <- function(year=2020){

  ### LEVEL 1 - List Years/folders available
  all_years = RCurl::getURL(ftp, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  all_years <- strsplit(all_years, "\r\n")
  all_years = unlist(all_years)

  this_year <- all_years[all_years %like% year]

  # create folder to download and store raw data of each year
  dir.create(paste0("./malhas_municipais/",this_year))

  if( year > 2015){

    # list files
    subdir <- paste0(ftp, this_year,"/", 'Brasil', "/", 'BR', "/")
    files = getURL(subdir, ftp.use.epsv = FALSE, dirlistonly = TRUE)
    files <- strsplit(files, "\r\n")
    files = unlist(files)

    # Download zipped files
    for (filename in files) { # filename <-  files[1]
      download.file(url = paste(subdir, filename, sep = ""),
                    destfile = paste0("./malhas_municipais/",this_year,"/",filename)
      )
    }
  }

  if( year < 2015){

    # list files
    subdir <- paste0(ftp, "/",this_year,"/")
    folders = getURL(subdir, ftp.use.epsv = FALSE, dirlistonly = TRUE)
    folders <- strsplit(folders, "\r\n")
    folders = unlist(folders)

    # LEVEL 2
    for (n2 in folders){ # n2 <- folders[2]

      # list files
      subdir2 <- paste0(ftp, this_year,"/", n2,"/")
      files = getURL(subdir2, ftp.use.epsv = FALSE, dirlistonly = TRUE)
      files <- strsplit(files, "\r\n")
      files = unlist(files)

      # create folder to download and store raw data of each year
      dest_dir <- paste0("./malhas_municipais/",this_year,"/",n2)
      dir.create(dest_dir)

      # Download zipped files
      for (filename in files) { # filename <-  files[1]
        download.file(url = paste(subdir2, filename, sep = ""),
                      destfile = paste0(dest_dir, "/",filename) )
      }
    } }
}

pblapply(X=c(2016, 2020), FUN=download_ibge)





!!! Essa funcao abaixo nao faz download do dado. Ela  unzipa e salva em geopackage. Dai sugiro
mudar o nome para algo do tipo. 'unzip_to_geopackage()'
####


download_malhas_municipais <- function(region, year){

  ########  1. Unzip original data sets downloaded from IBGE -----------------

  # Root directory
  root_dir <- "//STORAGE6/usuarios/# DIRUR #/ASMEQ/geobr/data-raw/malhas_municipais"
  setwd(root_dir)

  # unzip function
  unzip_fun <- function(f){
    # f <- files_1st_batch[1]
    t<-strsplit(f, "/")
    t<-t[[1]][length(t[[1]])]
    t<- nchar(t)
    unzip(f, exdir = file.path(root_dir, substr(f, 3, nchar(f)-t) ))
  }



  #### 1.1. GROUP 1/3 - Data available separately by state in a single resolution E -----------------
  # 2000, 2001, 2010, 2013, 2014

  # List all zip files for all years
  all_zipped_files <- list.files(full.names = T, recursive = T, pattern = ".zip")

  if (region == "uf"){all_zipped_files <- all_zipped_files[(all_zipped_files %like% "unidades_da_")]}
  if (region == "meso_regiao"){all_zipped_files <- all_zipped_files[all_zipped_files %like% "mesorregioes"]}
  if (region == "micro_regiao"){all_zipped_files <- all_zipped_files[all_zipped_files %like% "microrregioes|mi"]}
  if (region == "municipio"){all_zipped_files <- all_zipped_files[all_zipped_files %like% "municipios|mu500|mu2500|mu1000"]}

  if(year=="all"){

    # Select files of selected years
    # 540 files (4 geographies x 27 states x 5 years) 4*27*5
    files_1st_batch <- all_zipped_files[all_zipped_files %like% "2000|2001|2010|2013|2014"]

    # function to Unzip files in their original sub-dir
    unzip_fun <- function(f){
      # f <- files_1st_batch[1]
      t<-strsplit(f, "/")
      t<-t[[1]][length(t[[1]])]
      t<- nchar(t)
      unzip(f, exdir = file.path(root_dir, substr(f, 3, nchar(f)-t) ))
    }

    # create computing clusters
    cl <- parallel::makeCluster(detectCores())
    parallel::clusterExport(cl=cl, varlist= c("files_1st_batch", "root_dir"), envir=environment())

    # apply function in parallel
    parallel::parLapply(cl, files_1st_batch, unzip_fun)
    stopCluster(cl)


    gc(reset = T)

    #### 1.2 GROUP 2/3 - Data available separately by state in a single resolution and file -----------------
    # 2015, 2016, 2017, 2018

    # List all zip files for all years
    all_zipped_files

    # Select files of selected years
    files_2nd_batch <- all_zipped_files[all_zipped_files %like% "2015|2016|2017|2018|2019"]

    # remove Brazil files
    files_2nd_batch <- files_2nd_batch[!(files_2nd_batch %like% "BR")]

    # Select one file for each state
    # 540 files (4 geographies x 27 states x 4 years) 4*27*4
    files_2nd_batch <- files_2nd_batch[nchar(files_2nd_batch) > 30]


    # function to Unzip files in their original sub-dir
    # unzip_fun <- function(f){
    #   # f <- files_2nd_batch[14]
    #   t<-strsplit(f, "/")
    #   t<-t[[1]][length(t[[1]])]
    #   t<- nchar(t)
    #   unzip(f, exdir = file.path(root_dir, substr(f, 3, nchar(f)-t) ))
    # }

    # create computing clusters
    cl <- parallel::makeCluster(detectCores())
    parallel::clusterExport(cl=cl, varlist= c("files_2nd_batch", "root_dir"), envir=environment())

    # apply function in parallel
    parallel::parLapply(cl, files_2nd_batch, unzip_fun)
    stopCluster(cl)

    gc(reset = T)


    #### 1.3 GROUP 3/3 - Data available separately by state in a single resolution and file -----------------
    # 2005, 2007

    # List all zip files for all years
    all_zipped_files

    # Select files of selected years
    files_3rd_batch <- all_zipped_files[all_zipped_files %like% "2005|2007"]

    # Selc only zip files organized by UF at scale  1:2.500.000
    # 54 files (27 files x 2 years) 27*2
    files_3rd_batch <- files_3rd_batch[files_3rd_batch %like% "escala_2500mil/proj_geografica/arcview_shp/uf|escala_2500mil/proj_geografica_sirgas2000/uf"]

    # function to Unzip files in their original sub-dir
    # unzip_fun <- function(f){
    #   # f <- files_3rd_batch[54]
    #
    #   # subdir to unzip/save files
    #   dest_dir <- file.path(root_dir, substr(f, 2, 65))
    #
    #   # unzip
    #   unzip(f, exdir = dest_dir )
    # }

    # create computing clusters
    cl <- parallel::makeCluster(detectCores())
    parallel::clusterExport(cl=cl, varlist= c("files_3rd_batch", "root_dir"), envir=environment())

    # apply function in parallel
    parallel::parLapply(cl, files_3rd_batch, unzip_fun)
    stopCluster(cl)

    gc(reset = T)

    #### 2. Create folders to save sf.rds files  -----------------

    sub_dirs <- list.dirs(path = root_dir, recursive = F)

    sub_dirs <- sub_dirs[sub_dirs %like% "_all_years_original"]

    sub_dirs <- list.dirs(path = paste0(sub_dirs,"/",region), recursive = F)

    # get all years in the directory
    years <- unlist(lapply(strsplit(sub_dirs, "/"), tail, n = 1L))

    years <-  unlist(regmatches(years, gregexpr("[[:digit:]]+", years)))

    years <- unique(years)

    # # get all years in the directory
    # last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
    # years <- lapply(sub_dirs, last4)
    # years <-  unlist(years)

    # create directory to save original shape files in sf format
    dir.create(file.path("shapes_in_sf_all_years_original"), showWarnings = FALSE)

    # create a subdirectory of states, municipalities, micro and meso regions
    dir.create(file.path("shapes_in_sf_all_years_original/",paste0(region)), showWarnings = FALSE)

    # create a subdirectory of years
    sub_dirs <- paste0("./shapes_in_sf_all_years_original/",region)



    for (i in sub_dirs){
      for (y in years){
        dir.create(file.path(i, y), showWarnings = FALSE)
      }
    }

    sub_dirs <- paste0("./shapes_in_sf_all_years_cleaned/",region)

    for (i in sub_dirs){
      for (y in years){
        dir.create(file.path(i, y), showWarnings = FALSE)
      }
    }

    gc(reset = T)





    #### 3. Save original data sets downloaded from IBGE in compact .rds format-----------------

    # List shapes for all years
    all_shapes <- list.files(full.names = T, recursive = T, pattern = ".shp$")

    if (region == "uf"){all_shapes <- all_shapes[(all_shapes %like% "UFE250|uf500|UF2500|UF500|UF2500|UF_")]}
    if (region == "meso_regiao"){all_shapes <- all_shapes[all_shapes %like% "Mesorregioes"]}
    if (region == "micro_regiao"){all_shapes <- all_shapes[all_shapes %like% "MI|Microrregioes"]}
    if (region == "municipio"){all_shapes <- all_shapes[all_shapes %like% "MU|mu500|mu2500|mu1000|Municipios"]}

    shp_to_sf_rds <- function(x){



      # get corresponding year of the file
      #x <- all_shapes[1]

      years <- lapply(strsplit(x, "/"), head, n = 2L)

      years <- unlist(lapply(years, tail, n = 1L))

      years <-  unlist(regmatches(years, gregexpr("[[:digit:]]+", years)))

      years <- unique(years)


      # year <- substr(x, 13, 16)

      region <- region

      # select file
      # x <- all_shapes[all_shapes %like% 2000][3]


      # Encoding for different years
      if (years %like% "2000"){
        shape_i <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=IBM437")
      }

      if (years %like% "2001|2005|2007|2010"){
        shape_i <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")
      }

      if (years %like% "2013|2014|2015|2016|2017|2018|2019"){
        shape_i <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=UTF8")
      }


      # get destination subdirectory based on abbreviation of the geography
      last15 <- substr(x, nchar(x)-15, nchar(x)) # function to get the last 4 digits of a string
      if( years %like% "2019" & region %like% "Municipio|uf|municipio"){last15 <- substr(x, nchar(x)-18, nchar(x))}
      if( years %like% "2019" & region %like% "meso_regiao"){last15 <- substr(x, nchar(x)-20, nchar(x))}
      if( years %like% "2019" & region %like% "micro_regiao"){last15 <- substr(x, nchar(x)-21, nchar(x))}

      if ( last15 %like% "UF|uf|ME|me|MI|mi|MU|mu|Municipios|Mesorregioes|Microrregioes"){ dest_dir <- paste0("./shapes_in_sf_all_years_original/",region,"/", year)}

      # name of the file that will be saved
      # if( years %like% "2000|2001|2010|2013|2014"){ file_name <- paste0(toupper(substr(x, 21, 24)), ".gpkg") }
      # if( years %like% "2005"){ file_name <- paste0( toupper(substr(x, 67, 70)), ".gpkg") }
      # if( years %like% "2007"){ file_name <- paste0( toupper(substr(x, 66, 69)), ".gpkg") }
      # if( years %like% "2015|2016|2017|2018"){ file_name <- paste0( toupper(substr(x, 25, 28)), ".gpkg") }
      # if( years %like% "2019"){ file_name <- paste0( toupper(substr(x, 25, 29)), ".gpkg") }

      # name of the file and directory that will be saved
      t<-strsplit(x, "/")
      t<-t[[1]][length(t[[1]])]
      n<- nchar(t)
      dest_dir <- substr(x, 3, nchar(x)-(n+1) )
      file_name <- gsub(".shp$", ".gpkg", t, ignore.case = T)

      # save in .rds
      sf::st_write(shape_i, dsn = paste0(dest_dir,"/", file_name), delete_layer = TRUE)
    }


    future::plan(multiprocess)

    future_map(all_shapes, shp_to_sf_rds)


  } else if(year %like% "2000|2001|2005|2007|2010|2013|2014|2015|2016|2017|2018|2019"){

    # Select files of selected years
    # 540 files (4 geographies x 27 states x 5 years) 4*27*5

    files_1st_batch <- all_zipped_files[all_zipped_files %like% paste0(year)]

    # remove Brazil files
    files_1st_batch <- files_1st_batch[!(files_1st_batch %like% "BR")]

    # Select one file for each state
    # 540 files (4 geographies x 27 states x 4 years) 4*27*4



    if(year %like% "2005|2007"){
      files_1st_batch <- files_1st_batch[files_1st_batch %like% "escala_2500mil/proj_geografica/arcview_shp/uf|escala_2500mil/proj_geografica_sirgas2000/uf"]
    }

    if(year %like% "2015|2016|2017|2018|2019"){
      files_1st_batch <- files_1st_batch[nchar(files_1st_batch) > 30]

    }


    # create computing clusters
    cl <- parallel::makeCluster(detectCores())
    parallel::clusterExport(cl=cl, varlist= c("files_1st_batch", "root_dir"), envir=environment())

    # apply function in parallel
    parallel::parLapply(cl, files_1st_batch, unzip_fun)
    stopCluster(cl)


    rm(list=setdiff(ls(), c("root_dir","all_zipped_files","region","year")))
    gc(reset = T)

    #### 2. Create folders to save sf.rds files  -----------------

    sub_dirs <- list.dirs(path =root_dir, recursive = F)

    # get all years in the directory
    sub_dirs <- sub_dirs[sub_dirs %like% paste0(year)]

    # create directory to save original shape files in sf format
    dir.create(file.path("shapes_in_sf_all_years_original"), showWarnings = FALSE)

    # create a subdirectory of states, municipalities, micro and meso regions
    dir.create(file.path("shapes_in_sf_all_years_original/",paste0(region)), showWarnings = FALSE)

    # create a subdirectory of years
    sub_dirs <- paste0("./shapes_in_sf_all_years_original/",region)
    dir.create(file.path(sub_dirs,year), showWarnings = FALSE)
    gc(reset = T)

    #### 3. Save original data sets downloaded from IBGE in compact .rds format-----------------

    # List shapes for all years
    all_shapes <- list.files(full.names = T, recursive = T, pattern = ".shp$")
    all_shapes <- all_shapes[all_shapes %like% paste0(year)]

    if (region == "uf"){all_shapes <- all_shapes[(all_shapes %like% "UFE250|uf500|UF2500|UF500|UF2500|UF_")]}
    if (region == "meso_regiao"){all_shapes <- all_shapes[all_shapes %like% "Mesorregioes"]}
    if (region == "micro_regiao"){all_shapes <- all_shapes[all_shapes %like% "MI|Microrregioes"]}
    if (region == "municipio"){all_shapes <- all_shapes[all_shapes %like% "MU|mu500|mu2500|mu1000|Municipios"]}



    shp_to_sf_rds <- function(x){


      # get corresponding year of the file
      #x <- all_shapes[26]
      # select file
      # x <- all_shapes[all_shapes %like% 2000][3]


      # Encoding for different years
      if (year %like% "2000"){
        shape_i <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=IBM437")
      } else if (year %like% "2001|2005|2007|2010"){
        shape_i <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")
      } else if (year %like% "2013|2014|2015|2016|2017|2018|2019"){
        shape_i <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=UTF8")
      }


      # get destination subdirectory based on abbreviation of the geography
      last15 <- substr(x, nchar(x)-15, nchar(x)) # function to get the last 4 digits of a string
      if( year %like% "2019" & region %like% "Municipio|uf|municipio"){last15 <- substr(x, nchar(x)-18, nchar(x))}
      if( year %like% "2019" & region %like% "meso_regiao"){last15 <- substr(x, nchar(x)-20, nchar(x))}
      if( year %like% "2019" & region %like% "micro_regiao"){last15 <- substr(x, nchar(x)-21, nchar(x))}

      if ( last15 %like% "UF|uf|ME|me|MI|mi|MU|mu|Municipios|Mesorregioes|Microrregioes"){ dest_dir <- paste0("./shapes_in_sf_all_years_original/",region,"/", year)}

      # name of the file that will be saved
      # if( year %like% "2000|2001|2010|2013|2014"){ file_name <- paste0(toupper(substr(x, 21, 24)), ".gpkg")
      # } else if( year %like% "2005"){ file_name <- paste0( toupper(substr(x, 67, 70)), ".gpkg")
      # } else if( year %like% "2007"){ file_name <- paste0( toupper(substr(x, 66, 69)), ".gpkg")
      # } else if( year %like% "2015|2016|2017|2018"){ file_name <- paste0( toupper(substr(x, 25, 28)), ".gpkg")
      # } else if( year %like% "2019"){ file_name <- paste0( toupper(substr(x, 25, 29)), ".gpkg") }

      # name of the file and directory that will be saved
      t<-strsplit(x, "/")
      t<-t[[1]][length(t[[1]])]
      n<- nchar(t)
      dest_dir <- substr(x, 3, nchar(x)-(n+1) )
      file_name <- gsub(".shp$", ".gpkg", t, ignore.case = T)

      # save in .rds
      sf::st_write(shape_i, dsn = paste0(dest_dir,"/", file_name), delete_layer = TRUE)
    }


    future::plan(multiprocess)

    future_map(all_shapes, shp_to_sf_rds)

    rm(list= ls())
    gc(reset = T)


  } else {stop("Error: Invalid value to argument year")}

}


# }

