### Libraries (use any library as necessary)


library(RCurl)
#library(tidyverse)
library(stringr)
library(sf)
library(janitor)
library(dplyr)
library(readr)
library(parallel)
library(data.table)
library(xlsx)
library(magrittr)
library(devtools)
library(lwgeom)
library(stringi)
library(furrr)
library(future)

####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")


# Set a root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//setores_censitarios"
setwd(root_dir)



# If the data set is updated regularly, you should create a function that will have
# a `date` argument download the data




#### 0. Download original data sets from IBGE ftp -----------------

# setores 2010
  ftp <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2010/setores_censitarios_shp/"

# setores 2000 rural
  ftp2 <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2000/setor_rural/projecao_geografica/censo_2000/e500_arcview_shp/uf/"

# setores 2000 urbano
  ftp3 <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2000/setor_urbano/"

# setores 2019
ftp4 <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_de_setores_censitarios__divisoes_intramunicipais/2019/Malha_de_setores_(shp)_por_UFs/"

# setores 2020
ftp5 <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_de_setores_censitarios__divisoes_intramunicipais/2020/Malha_de_setores_(shp)_por_UFs/"


# lista de ftp de 2010,2019 e 2020
ftplist <- c(ftp, ftp4, ftp5)
ftplist <- c(ftp4, ftp5)

for (ftp1 in ftplist){ # ftp1 <- FTPLIST[3]

 # year directory
  if(ftp1 == ftp) { year_dir <- 2010}
  if(ftp1 %in% c(ftp2, ftp3)) { year_dir <- 2010}
  if(ftp1 ==ftp4) { year_dir <- 2019}
  if(ftp1 ==ftp5) { year_dir <- 2020}

  dir.create( paste0('./', year_dir),showWarnings = F )

  ### setor censitario censo
  filenames = getURL(ftp1, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filenames <- strsplit(filenames, "\r\n")
  filenames = unlist(filenames)
  filenames <- filenames[!grepl('leia_me', filenames)]

  # filesurl<-paste(ftp, filenames[9],"/", sep = "")
  # filesurl<-getURL(filesurl, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  # filesurl<-strsplit(filesurl, "\r\n")
  # filesurl<-unlist(filesurl)

  #fazendo download dos dados zipados
  for (filename in filenames) {
    filesurl<-paste(ftp1, filename,"/", sep = "")
    filesurl<-getURL(filesurl, ftp.use.epsv = FALSE, dirlistonly = TRUE)
    filesurl<-strsplit(filesurl, "\r\n")
    filesurl<-unlist(filesurl)

    fileyear <- regmatches(filesurl, gregexpr("[0-9]+",filesurl))
    fileyear <- unlist(fileyear)
    dir.fonte <- paste0("./",fileyear,"/",filename)

    for (fonte in dir.fonte){ # fonte <- dir.fonte[1]
      dir.create(fonte, recursive = T)

      for (files in filesurl){ # files <- filesurl[1]
        download.file(paste(ftp1, filename,"/", files, sep = ""),paste(fonte,"/",files, sep = ""))
      }
    }
  }
}


### setor censitario rural censo 2000
filenames = getURL(ftp2, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames = unlist(filenames)
filenames <- filenames[!grepl('leia_me', filenames)]


#fazendo download dos dados zipados
for (filename in filenames) {
  filesurl<-paste(ftp2, filename,"/", sep = "")
  filesurl<-getURL(filesurl, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filesurl<-strsplit(filesurl, "\r\n")
  filesurl<-unlist(filesurl)

  dir.fonte <- paste0("//Storage6/usuarios/# DIRUR #/ASMEQ/geobr//data-raw//setores_censitarios/censo_2000/",filename)
  dir.create(dir.fonte,recursive = T)

  for (files in filesurl) {
    download.file(paste(ftp2, filename,"/",files, sep = ""),paste(dir.fonte,"/",files,sep = ""))
  }
}

### setor censitario urbano censo 2000

filenames = getURL(ftp3, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames = unlist(filenames)
filenames <- filenames[!grepl('leia_me', filenames)]


dir.fonte <- paste0("//Storage6/usuarios/# DIRUR #/ASMEQ/geobr//data-raw//setores_censitarios/censo_2000/Urbano/")
filespasta<-list.files(dir.fonte)
filespasta<-unlist(filespasta)
difflies<-setdiff(filenames,filespasta)

#fazendo download dos dados zipados

for (filename in difflies) {
  filesurl<-paste(ftp3, filename,"/", sep = "")
  filesurl<-getURL(filesurl, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filesurl<-strsplit(filesurl, "\r\n")
  filesurl<-unlist(filesurl)

  dir.fonte <- paste0("//Storage6/usuarios/# DIRUR #/ASMEQ/geobr//data-raw//setores_censitarios/censo_2000/Urbano/",filename)
  dir.create(dir.fonte,recursive = T)


  for (files in filesurl) {

    if ( grepl("3300704",files)) { download.file(paste(ftp3, filename,"/",files,"/",files,"_2000.zip", sep = ""),paste(dir.fonte,"/",files,".zip",sep = ""),quiet = T)
    }
    else if (grepl(".zip",files)){
      download.file(paste(ftp3, filename,"/",files, sep = ""),paste(dir.fonte,"/",files,sep = ""),quiet = T)
    } else {
      download.file(paste(ftp3, filename,"/",files,"/",files,".zip", sep = ""),paste(dir.fonte,"/",files,".zip",sep = ""),quiet = T)
    }
  }
}



########  1. Unzip original data sets downloaded from IBGE -----------------

# list all zipped files
  all_zipped_files <- list.files(pattern = ".zip", recursive = T, full.names = T)
  all_zipped_files <- all_zipped_files[all_zipped_files %like% "setores|Setores"]


  # select years to unzip
  all_zipped_files <- all_zipped_files[ all_zipped_files %like% '2019|2020' ]




# function to Unzip files in their original sub-dir
unzip_fun <- function(f){ # f <- all_zipped_files[10]
                          # f <- all_zipped_files[54]

  if (grepl("Rural|Urbano",f)) {
    zip_path <- unlist(stringr::str_split(f,"/"))
    zip_path <- tail(zip_path , n=4)
    zip_path <- head(zip_path , n=3)
    zip_path <- paste(zip_path ,collapse  = "/")
  } else {
    zip_path <- unlist(stringr::str_split(f,"/"))
    zip_path <- tail(zip_path , n=3)
    zip_path <- head(zip_path , n=2)
    zip_path <-paste(zip_path ,collapse  = "/")
  }

  # unzip
    dir.create(file.path(root_dir,zip_path), showWarnings = FALSE)
    unzip(f, exdir = file.path(root_dir,zip_path))

### EXCEPTIONS
  # correction in file names of Sao Paulo 2010
    if(f %like% "./censo_2010/sp/sp_setores_censitarios.zip"){

      # list shape files
      files <- list.files(file.path(root_dir,zip_path), full.names = T)
      files <- files[files %like% "_SIR"]
      files_new <- gsub("33SEE250GC_SIR",'35SEE250GC_SIR',files)

      # rename files
      file.rename(files,files_new)
    }

    # correction of file names of Municipio 3300704_2000 (year 2000 urbano)
    if(f %like% "./censo_2000/Urbano/rj/rj_setores_censitarios.zip"){

      # list shape files
      files <- list.files(file.path(root_dir,zip_path), full.names = T)
      files <- files[files %like% "3300704_2000"]
      files_new <- gsub("3300704_2000",'3300704',files)

      # rename files
      file.rename(files,files_new)
    }
}


# apply function in parallel
future::plan(strategy = 'multisession')
furrr::future_map(.x=all_zipped_files, .f=unzip_fun, .progress = T)

gc(reset = T)





#### 2. Create folders to save sf.rds files  -----------------

# create directory to save original and clean shape files in sf format
  dir.create(file.path("shapes_in_sf_all_years_original"), showWarnings = FALSE)
  dir.create(file.path("shapes_in_sf_all_years_cleaned"), showWarnings = FALSE)

# year 2000
  dir.create(file.path("shapes_in_sf_all_years_original", "2000"), showWarnings = FALSE)
  dir.create(file.path("shapes_in_sf_all_years_original/2000", "Rural"), showWarnings = FALSE)
  dir.create(file.path("shapes_in_sf_all_years_original/2000", "Urbano"), showWarnings = FALSE)

  dir.create(file.path("shapes_in_sf_all_years_cleaned", "2000"), showWarnings = FALSE)
  dir.create(file.path("shapes_in_sf_all_years_cleaned/2000", "Rural"), showWarnings = FALSE)
  dir.create(file.path("shapes_in_sf_all_years_cleaned/2000", "Urbano"), showWarnings = FALSE)

# year 2010 onwards
  for (i in c(2010, 2019, 2020)){
    dir.create(file.path("shapes_in_sf_all_years_original", i), showWarnings = FALSE)
    dir.create(file.path("shapes_in_sf_all_years_cleaned", i), showWarnings = FALSE)
  }







#### 3. Save original data sets downloaded from IBGE in compact .rds format-----------------

# List shapes for all years
all_shapes <- list.files(full.names = T, recursive = T, pattern = ".shp|.SHP")
head(all_shapes)

# select years save
all_shapes <- all_shapes[ all_shapes %like% '2019|2020' ]
# all_shapes <- all_shapes[ all_shapes %nlike% '2000' ]



# function to save original files in rds
shp_to_sf_rds <- function(x){

  # x <- all_shapes[30]

  # get corresponding year of the file
  year <- unlist(stringr::str_split(x,"/"))
  year <- head(year , n=2)
  year <- tail(year , n=1)
  year <- gsub("[^0-9]","",year)
  year <- year[!is.na(year)]



  # Encoding for different years
  if (year %like% "2000"){
    shape <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=IBM437")
  }

  if (year %like% "2001|2005|2007|2010"){
    shape <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")
  }

  if (year %like% "2013|2014|2015|2016|2017|2018|2019|2020"){
    shape <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=UTF8")
  }


  # get destination subdirectory based on abbreviation of the geography
  last30 <- function(x){substr(x, nchar(x)-30, nchar(x))}   # function to get the last 4 digits of a string

  if ( last30(x) %like% "Urbano"){ dest_dir <- paste0("./shapes_in_sf_all_years_original/",year,"/Urbano")
  } else if ( last30(x) %like% "Rural"){ dest_dir <- paste0("./shapes_in_sf_all_years_original/",year, "/Rural")
  } else {dest_dir <- paste0("./shapes_in_sf_all_years_original/", year)    }

  # name of the file that will be saved
  if( year %like% "2000" & last30(x) %like% "Urbano"){ file_name <- paste0(toupper(
    substr(tail(unlist(stringr::str_split(x,"/")),n=1), 0, (nchar(tail(unlist(stringr::str_split(x,"/")),n=1))-4) )), ".rds") }
  if( year %like% "2000" & last30(x) %like% "Rural"){ file_name <- paste0(toupper(
    substr(tail(unlist(stringr::str_split(x,"/")),n=1),0,2)), ".rds") }
  if( year %like% "2010|2019|2020"){ file_name <- paste0( toupper(
    substr(tail(unlist(stringr::str_split(x,"/")),n=1),0,2)), ".rds") }

  # save in .rds
  readr::write_rds(shape, file = paste0(dest_dir,"/", file_name), compress="gz" )
}


# apply function in parallel to save original data sets in rds format
future::plan(strategy = 'multisession')
furrr::future_map(.x=all_shapes, .f=shp_to_sf_rds, .progress = T)
gc(reset = T, full = T)








###### 4. Cleaning files --------------------------------

# list all .rds files
  all_rds <- list.files(path = "./shapes_in_sf_all_years_original/",
                           full.names = T, recursive = T, pattern = ".rds")

# select years to process
all_rds <- all_rds[ all_rds %like% '2019|2020' ]
# all_rds <- all_rds[ all_rds %nlike% '2000' ]



# create a function that will clean the sf files according to particularities of the data in each year
clean_tracts <- function( sf_file ){

  message(paste0('\nworking on file ',sf_file , '\n'))
  # sf_file <- all_rds[all_rds %like% "2000" & all_rds %like% "Urbano"]
  # sf_file <- all_rds[all_rds %like% "2010"]
  # sf_file <- all_rds[1]

  # read sf file
    temp_sf <- read_rds(sf_file)
    names(temp_sf) <- names(temp_sf) %>% tolower()


  # get year of the file
    # last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
    # year <- last4(e)
    if( sf_file %like% "/2000/" ){ year <- 2000}
    if( sf_file %like% "/2007/" ){ year <- 2007}
    if( sf_file %like% "/2010/" ){ year <- 2010}
    if( sf_file %like% "/2019/" ){ year <- 2019}
    if( sf_file %like% "/2020/" ){ year <- 2020}


  # rural tracts of year 2000
    if ((year %like% "2000") & (sf_file %like% "Rural")){

      temp_sf <- temp_sf %>% mutate(code_state=substr(geocodigo,1,2),code_muni=substr(geocodigo,1,7))
      temp_sf <- dplyr::rename(temp_sf, code_tract = geocodigo, zone = situacao)
      temp_sf <- dplyr::select(temp_sf, c('code_tract', 'zone', 'code_muni', 'code_state', 'geometry'))
    }


  # Urban tracts of year 2000
    if ((year %like% "2000") & (sf_file %like% "Urbano")){

        temp_sf <- temp_sf %>% mutate(code_state=substr(id_,1,2),code_muni=substr(id_,1,7))
        temp_sf <- dplyr::rename(temp_sf, code_tract = id_)
        temp_sf <- dplyr::select(temp_sf, c('code_tract', 'code_muni', 'code_state', 'geometry'))

    # fix projection
      sf::st_crs(temp_sf) <- paste(sf::st_crs(temp_sf)[["proj4string"]], "+south")

    # define urban/rural classification
        # 1 – Área urbanizada de vila ou cidade: Setor urbano situado em áreas legalmente definidas como urbanas, caracterizadas por construções, arruamentos e intensa ocupação humana; áreas afetadas por transformações decorrentes do desenvolvimento urbano e aquelas reservadas à expansão urbana;
        # 2 – Área não urbanizada de vila ou cidade: Setor urbano situado em áreas localizadas dentro do perímetro urbano de cidades e vilas reservadas à expansão urbana ou em processo de urbanização; áreas legalmente definidas como urbanas, mas caracterizadas por ocupação predominantemente de caráter rural;
        # 3 – Área urbanizada isolada: Setor urbano situado em áreas definidas por lei municipal e separadas da sede municipal ou distrital por área rural ou por um outro limite legal;
        # 4 – Rural - extensão urbana: Setor rural situado em assentamentos situados em área externa ao perímetro urbano legal, mas desenvolvidos a partir de uma cidade ou vila, ou por elas englobados em sua extensão;
        # 5 – Rural – povoado: Setor rural situado em aglomerado rural isolado sem caráter privado ou empresarial, ou seja, não vinculado a um único proprietário do solo (empresa agrícola, indústria, usina, etc.), cujos moradores exercem atividades econômicas no próprio aglomerado ou fora dele. Caracteriza-se pela existência de um número mínimo de serviços ou equipamentos para atendimento aos moradores do próprio aglomerado ou de áreas rurais próximas;
        # 6 – Rural – núcleo: Setor rural situado em aglomerado rural isolado, vinculado a um único proprietário do solo (empresa agrícola, indústria, usina, etc.), privado ou empresarial, dispondo ou não dos serviços ou equipamentos definidores dos povoados;
        # 7 – Rural - outros aglomerados: Setor rural situado em outros tipos de aglomerados rurais, que não dispõem, no todo ou em parte, dos serviços ou equipamentos definidores dos povoados, e que não estão vinculados a um único proprietário (empresa agrícola, indústria, usina, etc.);
        # 8 – Rural – exclusive os aglomerados rurais: Setor rural situado em área externa ao perímetro urbano, exclusive as áreas de aglomerado rural.

    }


  # Tracts of year 2010
    if (year %like% "2010"){

      # rename columns
      temp_sf <- temp_sf %>% mutate(code_state=substr(cd_geocodm,1,2))
      temp_sf <- dplyr::select(temp_sf,
                               code_tract = cd_geocodi,
                               zone = tipo,
                               code_muni = cd_geocodm,
                               name_muni = nm_municip,
                               name_neighborhood=nm_bairro,
                               code_neighborhood=cd_geocodb,
                               code_subdistrict=cd_geocods,
                               name_subdistrict=nm_subdist,
                               code_district=cd_geocodd,
                               name_district=nm_distrit,
                               code_state,
                               geometry)

    }


    # Tracts of year 2019 or 2020
    if (year %like% "2019|2020"){

      # rename columns
      temp_sf <- dplyr::select(temp_sf,
                               code_tract = cd_setor,
                               zone = nm_sit,
                               code_muni = cd_mun,
                               name_muni = nm_mun,
                               code_subdistrict=cd_subdist,
                               name_subdistrict=nm_subdist,
                               code_district=cd_dist,
                               name_district=nm_dist,
                               code_state=cd_uf,
                               abbrev_state=sigla_uf,
                               name_state=nm_uf,
                               geometry )


    }


    # Use UTF-8 encoding
    temp_sf <- use_encoding_utf8(temp_sf)

    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
      temp_sf <- harmonize_projection(temp_sf)
      # mapview::mapview(temp_sf)

    # Make an invalid geometry valid # st_is_valid( sf)
    temp_sf <- sf::st_make_valid(temp_sf)

    # remove lagoa dos patos no RS
    temp_sf <- subset(temp_sf, !is.na(code_state))


    # simplify
    temp_sf_simplified <- simplify_temp_sf(temp_sf)

    # convert to MULTIPOLYGON
    temp_sf <- to_multipolygon(temp_sf)
    temp_sf_simplified <- to_multipolygon(temp_sf_simplified)


  # Determine directory to save cleaned sf
      if( sf_file %like% "2000/Urbano"){ dest_dir <-"./shapes_in_sf_all_years_cleaned//2000//Urbano//" }
      if( sf_file %like% "2000/Rural"){ dest_dir <- "./shapes_in_sf_all_years_cleaned//2000//Rural//" }

      if( sf_file %like% "2010|2019|2020"){ dest_dir <- paste0("./shapes_in_sf_all_years_cleaned//", year, "//") }
      # if( sf_file %like% "/2010/"){ dest_dir <- "./shapes_in_sf_all_years_cleaned//2010//" }
      # if( sf_file %like% "/2019/"){ dest_dir <- "./shapes_in_sf_all_years_cleaned//2019//" }
      # if( sf_file %like% "/2020/"){ dest_dir <- "./shapes_in_sf_all_years_cleaned//2020//" }


  # name of the file that will be saved (the whole string between './' and '.rds')
    # file_name <- gsub(".*/(.+).rds.*", "\\1", sf_file)
    file_name <- unique(temp_sf$code_state)

  # Save cleaned sf in the cleaned directory
    sf::st_write(temp_sf, paste0(dest_dir, file_name,".gpkg") )
    sf::st_write(temp_sf_simplified, paste0(dest_dir, file_name,"_simplified.gpkg"),)

}



# Apply function to save the data
gc(reset = T)
future::plan(strategy = 'multisession')
furrr::future_map(.x=all_rds, .f=clean_tracts, .progress = T)
gc(reset = T, full = T)

pbapply::pblapply(X=all_rds, FUN=clean_tracts)



# ############juntando as bases por estado --------------
#
# dir.proj="L:////# DIRUR #//ASMEQ//geobr//data-raw//setores_censitarios//shapes_in_sf_all_years_cleaned//2000//Urbano//"
# setwd(dir.proj)
# lista <- unique(substr(list.files(dir.proj),1,2))
#
# for (CODE in lista) {# CODE <- 33
#
#   files <- list.files(full.names = T,pattern = paste0("^",CODE))
#   files <- lapply(X=files, FUN= readr::read_rds, quiet = T)
#   files <- lapply(X=files, FUN= as.data.frame)
#   shape <- do.call('rbind', files)
#   shape <- st_sf(shape)
#   shape7 <- st_transform(shape, crs=3857) %>%
#     sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)
#   readr::write_rds(shape,paste0("./",CODE,"sc.rds"), compress="gz")
#   sf::st_write(shape, dsn= paste0("./",CODE,"sc.gpkg"))
#   sf::st_write(shape7, dsn= paste0("./",CODE,"sc_simplified", ".gpkg"))
#
# }
#
#
# a <- read_municipality(code_muni = "11")
