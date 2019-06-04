## Pacotes
library(stringr)
library(sf)
library(dplyr)
library(magrittr)

#' Download shape files of municipalities
#'
#' @param year the year of the data download (defaults to 2010)
#' @param cod_mun 7-digit code of the municipality. If a the two-digit code of a state is used,
#' the function will load all municipalities of that state. If not informed, all municipalities will be loaded.
#' @export
#' @family general area functions
#' @examples \dontrun{
#'
#' library(geobr)
#'
#' # Read specific municipality at a given year
#'   mun <- read_municipio(cod_mun=1200179, year=2017)
#'
#'# Read all municipalities of a state at a given year
#'   mun <- read_municipio(cod_mun=12, year=2010)
#'
#'}

read_municipio <- function(year=NULL, cod_mun=NULL){

# Get metadata with data addresses
  tempf <- file.path(tempdir(), "metadata.rds")

  # check if metadata has already been downloaded
  if (file.exists(tempf)) {
     metadata <- readRDS(tempf)

  } else {
  # download it and save to metadata
    download.file(url="http://www.ipea.gov.br/geobr/metadata/metadata.rds", destfile = tempf, quiet = T,mode = "wb")
    metadata <- readRDS(tempf)
  }


# Select geo
  temp_meta <- subset(metadata, geo=="municipio")


# Verify year input
  if (is.null(year)){ cat("Using data from year 2010 \n")
    temp_meta <- subset(temp_meta, year==2010)

  } else if (year %in% temp_meta$year){ temp_meta <- subset(temp_meta, year== year)

  } else { stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                       paste(unique(temp_meta$year),collapse = " ")))
  }


# Verify cod_mun input

  # Test if cod_mun input is null
    if(is.null(cod_mun)){ stop("Value to argument 'cod_mun' cannot be NULL") }

  # if cod_mun=="all", read the entire country
    else if(cod_mun=="all"){ cat("Loading data for the whole country \n")

      # list paths of files to download
      filesD <-as.character(temp_meta$download_path)


      # download files
      lapply(X=filesD, function(x) download.file(url = x,
                                                 destfile = paste0(tempdir(),"/",unlist(lapply(strsplit(x,"/"),tail,n=1L))),
                                                 quiet = T,mode = "wb"))

      # read files and pile them up
      files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
      files <- paste0(tempdir(),"/",files)
      files <- lapply(X=files, FUN= readRDS)
      shape <- do.call('rbind', files)
      return(shape)
    }

  else if( !(substr(x = cod_mun, 1, 2) %in% temp_meta$code)){
      stop("Error: Invalid Value to argument cod_mun.")

  } else{

    # list paths of files to download
    filesD <-as.character(subset(temp_meta, code==substr(cod_mun, 1, 2))$download_path)

    # download files
   download.file(url = filesD,destfile = paste0(tempdir(),"/",unlist(lapply(strsplit(filesD,"/"),tail,n=1L))),
                                               quiet = T,mode = "wb")

      shape <- readRDS(paste0(tempdir(),"/",unlist(lapply(strsplit(filesD,"/"),tail,n=1L))))

      if(nchar(cod_mun)==2){
        return(shape)

      } else if(cod_mun %in% shape$cod_mun){    # Get Municipio
          x <- cod_mun
          shape %<>% filter(cod_mun==x)
          return(shape)
      } else{
          stop("Error: Invalid Value to argument cod_mun.")
      }
  }
}
