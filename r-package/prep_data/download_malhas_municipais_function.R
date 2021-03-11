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

setwd('L:/# DIRUR #/ASMEQ/geobr/data-raw')



########  0. Download Raw zipped files for all years ------------

ftp <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/"

# Download function
download_ibge <- function(year=2020){

  message(paste0("Downloading year: ", year, '\n'))
  message(paste0("Downloading year: ", year, '\n'))
  message(paste0("Downloading year: ", year, '\n'))

  # check what years have already been downloaded
  years_already_downloaded <- list.dirs('./malhas_municipais/',recursive = F)
  if( any(years_already_downloaded %like% year) ){ return(NULL) }

  ### LEVEL 1 - List Years/folders available
  all_years = RCurl::getURL(ftp, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  all_years <- strsplit(all_years, "\r\n")
  all_years = unlist(all_years)

  this_year <- all_years[all_years %like% year]

  # create folder to download and store raw data of each year
  dir.create(paste0("./malhas_municipais/",year), showWarnings = F)

  if( year >= 2015){

    # list files
    subdir <- paste0(ftp, this_year,"/", 'Brasil', "/", 'BR', "/")
    files = getURL(subdir, ftp.use.epsv = FALSE, dirlistonly = TRUE)
    files <- strsplit(files, "\r\n")
    files = unlist(files)

    # Download zipped files
    for (filename in files) { # filename <-  files[1]
      download.file(url = paste(subdir, filename, sep = ""),
                    destfile = paste0("./malhas_municipais/",year,"/",filename)
      )
    }
  }

  if( year %in% c(2005, 2007)){

    # list files
    subdir <- paste0(ftp,this_year,"/")
    folders = getURL(subdir, ftp.use.epsv = FALSE, dirlistonly = TRUE)
    folders <- strsplit(folders, "\r\n")
    folders = unlist(folders)
    folders = subset(folders,!grepl(".pdf",folders))

    # escala e projecao
    folder = folders[ folders %like% 'escala_2500mil']
    if(year==2005){subdir = paste0(ftp,this_year,"/",folder, "/proj_geografica/arcview_shp/uf/")}
    if(year==2007){subdir = paste0(ftp,this_year,"/",folder, "/proj_geografica_sirgas2000/uf/")}
    folders = getURL(subdir, ftp.use.epsv = FALSE, dirlistonly = TRUE)
    folders = strsplit(folders, "\r\n")
    folders = unlist(folders)
    folders = subset(folders,!grepl(".pdf",folders))

    # LEVEL 3
    for (n2 in folders){ # n2 <- folders[2]

      # list files
      if(year==2005){subdir2 = paste0(ftp,this_year,"/",folder, "/proj_geografica/arcview_shp/uf/",n2,"/")}
      if(year==2007){subdir2 = paste0(ftp,this_year,"/",folder, "/proj_geografica_sirgas2000/uf/",n2,"/")}
      files = getURL(subdir2, ftp.use.epsv = FALSE, dirlistonly = TRUE)
      files <- strsplit(files, "\r\n")
      files = unlist(files)

      # create folder to download and store raw data of each year
      dest_dir <- paste0("./malhas_municipais/",year,"/",n2)
      dir.create(dest_dir)

      # Download zipped files
      for (filename in files) { # filename <-  files[1]
        download.file(url = paste(subdir2, filename, sep = ""),
                      destfile = paste0(dest_dir, "/",filename) )
      }
    } }

  else if( year < 2015 & year!=2005 & year!=2007){

    # list files
    subdir <- paste0(ftp,this_year,"/")
    folders = getURL(subdir, ftp.use.epsv = FALSE, dirlistonly = TRUE)
    folders <- strsplit(folders, "\r\n")
    folders = unlist(folders)

    folders = subset(folders,!grepl(".pdf",folders))

    # LEVEL 2
    for (n2 in folders){ # n2 <- folders[19]

      # list files
      subdir2 <- paste0(ftp, this_year,"/", n2,"/")
      files = getURL(subdir2, ftp.use.epsv = FALSE, dirlistonly = TRUE)
      files <- strsplit(files, "\r\n")
      files = unlist(files)

      # create folder to download and store raw data of each year
      dest_dir <- paste0("./malhas_municipais/",year,"/",n2)
      dir.create(dest_dir)

      # Download zipped files
      for (filename in files) { # filename <-  files[1]
        download.file(url = paste(subdir2, filename, sep = ""),
                      destfile = paste0(dest_dir, "/",filename) )
      }
    } }
}


# lapply(X=c(2000, 2005, 2007, 2020), FUN=download_ibge)



########  1. Unzip Raw zipped files for all years ------------

unzip_to_geopackage <- function(region, year){

  message(paste0("unziping\n"))

  ########  1. Unzip original data sets downloaded from IBGE -----------------

  # Root directory
  root_dir <- "L:/# DIRUR #/ASMEQ/geobr/data-raw/malhas_municipais"
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

  # filter year
  #  all_zipped_files[all_zipped_files %like% year]

  if (region == "uf"){all_zipped_files <- all_zipped_files[(all_zipped_files %like% "unidades_da_|UF_|uf2500")]}
  if (region == "meso_regiao"){all_zipped_files <- all_zipped_files[all_zipped_files %like% "mesorregioes|Mesorregioes"]}
  if (region == "micro_regiao"){all_zipped_files <- all_zipped_files[all_zipped_files %like% "microrregioes|mi|Microrregioes"]}
  if (region == "municipio"){all_zipped_files <- all_zipped_files[all_zipped_files %like% "municipios|mu500|mu2500|mu1000|Municipios"]}

  if(year=="all"){

    # Select files of selected years
    # 540 files (4 geographies x 27 states x 5 years) 4*27*5
    files_1st_batch <- all_zipped_files[all_zipped_files %like% "2000|2001|2010|2013|2014"]

    # function to Unzip files in their original sub-dir
    unzip_fun <- function(f){
      # g
      t<-strsplit(f, "/")
      t<-t[[1]][length(t[[1]])]
      t<- nchar(t)
      unzip(f, exdir = file.path(root_dir, substr(f, 3, nchar(f)-t)) )
    }

    # create computing clusters
    cl <- parallel::makeCluster(detectCores())
    parallel::clusterExport(cl=cl, varlist= c("files_1st_batch", "root_dir"), envir=environment())

    # apply function in parallel
    parallel::parLapply(cl, files_1st_batch, unzip_fun)
    stopCluster(cl)


    gc(reset = T)

    #### 1.2 GROUP 2/3 - Data available one file for the whole country -----------------
    # 2015, 2016, 2017, 2018

    # List all zip files for all years
    all_zipped_files

    # Select files of selected years
    files_2nd_batch <- all_zipped_files[all_zipped_files %like% "2015|2016|2017|2018|2019|2020"]

    # create computing clusters
    cl <- parallel::makeCluster(detectCores())
    parallel::clusterExport(cl=cl, varlist= c("files_2nd_batch", "root_dir"), envir=environment())

    # apply function in parallel
    parallel::parLapply(cl, files_2nd_batch, unzip_fun)
    stopCluster(cl)

    gc(reset = T)


    #### 1.3 GROUP 3/3 - Data available separately by state different resolution files -----------------
    # 2005, 2007

    # List all zip files for all years
    all_zipped_files

    # Select files of selected years
    files_3rd_batch <- all_zipped_files[all_zipped_files %like% "2005|2007"]

    # Selc only zip files organized by UF at scale  1:2.500.000
    # 54 files (27 files x 2 years) 27*2
    files_3rd_batch <- files_3rd_batch[files_3rd_batch %like% "mu2500"]

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


### 2. Save gpkg files  -----------------


#### 2.1 Create folders to save sf.rds files  -----------------

    message(paste0("saving gpkg\n"))

    sub_dirs <- list.dirs(path = root_dir, recursive = F)

    sub_dirs <- sub_dirs[! (sub_dirs %like% "_all_years_original")]
    sub_dirs <- sub_dirs[! (sub_dirs %like% "_all_years_clean")]

    # get all years in the directory
    years <- unlist(lapply(strsplit(sub_dirs, "/"), tail, n = 1L))
    years <-  unlist(regmatches(years, gregexpr("[[:digit:]]+", years)))
    years <- unique(years)
    years

    # create directory to save original shape files in sf format
    dir.create(file.path("shapes_in_sf_all_years_original"), showWarnings = FALSE)

    # create a subdirectory of states, municipalities, micro and meso regions
    dir.create(file.path("shapes_in_sf_all_years_original/",paste0(region)), showWarnings = FALSE)

    # create a subdirectory of years
    sub_dirs_cleaned <- paste0("./shapes_in_sf_all_years_cleaned/",region)
    sub_dirs_original <- paste0("./shapes_in_sf_all_years_original/",region)

    for (y in years){
        dir.create( file.path(sub_dirs_cleaned, y), showWarnings = FALSE)
        dir.create( file.path(sub_dirs_original, y), showWarnings = FALSE)
      }

    gc(reset = T)





#### 3. Save original data sets downloaded from IBGE in compact .rds format-----------------

    # List shapes for all years
    all_shapes <- list.files(full.names = T, recursive = T, pattern = ".shp$")

    if (region == "uf"){ all_shapes <- all_shapes[(all_shapes %like% "UFE250|uf500|UF2500|UF500|UF2500|UF_")] }
    if (region == "meso_regiao"){all_shapes <- all_shapes[all_shapes %like% "Mesorregioes"]}
    if (region == "micro_regiao"){all_shapes <- all_shapes[all_shapes %like% "MI|Microrregioes"]}
    if (region == "municipio"){all_shapes <- all_shapes[all_shapes %like% "MU|mu500|mu2500|mu1000|Municipios"]}

    temp <- NULL

    shp_to_sf_rds <- function(x){

      # select file
      # x <- all_shapes[all_shapes %like% 2020][3]
      # x <- all_shapes[1]

      # get corresponding year of the file
      years <- lapply(strsplit(x, "/"), head, n = 2L)
      years <- unlist(lapply(years, tail, n = 1L))
      years <-  unlist(regmatches(years, gregexpr("[[:digit:]]+", years)))
      years <- unique(years)
      years


      # Encoding for different years
      if (years %like% "2000"){
        shape_i <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=IBM437")
      }

      if (years %like% "2001|2005|2007|2010"){
        shape_i <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")
      }

      if (years %like% "2013|2014|2015|2016|2017|2018|2019|2020"){
        shape_i <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=UTF8")
      }


      # get destination subdirectory based on abbreviation of the geography
      last15 <- substr(x, nchar(x)-15, nchar(x)) # function to get the last 15 digits of a string
      if( years %like% "2019|2020" & region %like% "Municipio|uf|municipio"){last15 <- substr(x, nchar(x)-18, nchar(x))}
      if( years %like% "2019|2020" & region %like% "meso_regiao"){last15 <- substr(x, nchar(x)-20, nchar(x))}
      if( years %like% "2019|2020" & region %like% "micro_regiao"){last15 <- substr(x, nchar(x)-21, nchar(x))}

      if ( last15 %like% "UF|uf|ME|me|MI|mi|MU|mu|Municipios|Mesorregioes|Microrregioes") {
        dest_dir <- paste0("./shapes_in_sf_all_years_original/",region,"/", years)
        }

      # name of the file that will be saved
      # if( years %like% "2000|2001|2010|2013|2014"){ file_name <- paste0(toupper(substr(x, 21, 24)), ".gpkg") }
      # if( years %like% "2005"){ file_name <- paste0( toupper(substr(x, 67, 70)), ".gpkg") }
      # if( years %like% "2007"){ file_name <- paste0( toupper(substr(x, 66, 69)), ".gpkg") }
      # if( years %like% "2015|2016|2017|2018"){ file_name <- paste0( toupper(substr(x, 25, 28)), ".gpkg") }
      # if( years %like% "2019"){ file_name <- paste0( toupper(substr(x, 25, 29)), ".gpkg") }

      # name of the file and directory that will be saved
      t <- strsplit(x, "/")
      t <- t[[1]][length(t[[1]])]
      n <- nchar(t)
      #dest_dir <- substr(x, 3, nchar(x)-(n+1) )
      file_name <- gsub(".shp$", ".gpkg", t, ignore.case = T)


      temp <- rbind(temp,shape_i) %>% st_as_sf()

      # save in .rds
      sf::st_write(temp, dsn = paste0(dest_dir,"/", file_name), overwrite = TRUE)
    }
666666

    future::plan(multisession)

    future_map(all_shapes, shp_to_sf_rds)


  } else if(year %like% "2000|2001|2005|2007|2010|2013|2014|2015|2016|2017|2018|2019|2020"){

    # Select files of selected years
    # 540 files (4 geographies x 27 states x 5 years) 4*27*5

    files_1st_batch <- all_zipped_files[all_zipped_files %like% year]

    if(year!=2020){
      # remove Brazil files
      files_1st_batch <- files_1st_batch[!(files_1st_batch %like% "BR")]

    }

    # Select one file for each state
    # 540 files (4 geographies x 27 states x 4 years) 4*27*4

    if(year %like% "2005|2007"){
      files_1st_batch <- files_1st_batch[files_1st_batch %like% "mu2500"]
    }

    if(year %like% "2015|2016|2017|2018|2019|2020"){
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
    if (region == "meso_regiao"){all_shapes <- all_shapes[all_shapes %like% "Mesorregioes|mesorregioes|ME500"]}
    if (region == "micro_regiao"){all_shapes <- all_shapes[all_shapes %like% "MI|Microrregioes|microrregioes"]}
    if (region == "municipio"){all_shapes <- all_shapes[all_shapes %like% "MU|mu500|mu2500|mu1000|Municipios"]}

    temp <- NULL

    shp_to_sf_rds <- function(x){


      # get corresponding year of the file
      # x <- all_shapes[1]
      # select file
      # x <- all_shapes[all_shapes %like% 2000][3]


      # Encoding for different years
      if (year %like% "2000"){
        shape_i <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=IBM437")
      } else if (year %like% "2001|2005|2007|2010"){
        shape_i <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")
      } else if (year %like% "2013|2014|2015|2016|2017|2018|2019|2020"){
        shape_i <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=UTF8")
      }


      # get destination subdirectory based on abbreviation of the geography
      last15 <- substr(x, nchar(x)-15, nchar(x)) # function to get the last 4 digits of a string
      if( year %like% "2019|2020" & region %like% "Municipio|uf|municipio"){last15 <- substr(x, nchar(x)-18, nchar(x))}
      if( year %like% "2019|2020" & region %like% "meso_regiao"){last15 <- substr(x, nchar(x)-20, nchar(x))}
      if( year %like% "2019|2020" & region %like% "micro_regiao"){last15 <- substr(x, nchar(x)-21, nchar(x))}

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
      file_name <- gsub(".shp$", ".gpkg", t, ignore.case = T)


      temp <- shape_i %>% st_as_sf()

      # save in .rds
      sf::st_write(temp, dsn = paste0(dest_dir,"/", file_name), overwrite = TRUE)
    }


    # apply function
    future::plan(multisession)

    future_map(all_shapes, shp_to_sf_rds)

    rm(list= ls())
    gc(reset = T)


  } else {stop("Error: Invalid value to argument year")}

}

