## Pacotes
library(stringr)
library(sf)
library(dplyr)
library(magrittr)
library(readr)
library(httr)

#' Download shape files of Brazilian states
#'
#' @param year the year of the data download (defaults to 2010)
#' @param cod_uf 2-digit code of a state. If cod_uf="all", all states will be loaded.
#' @export
#' @family general area functions
#' @examples \dontrun{
#'
#' library(geobr)
#'
#' # Read specific municipality at a given year
#'   mun <- read_uf(cod_uf=12, year=2017)
#'
#'# Read all states at a given year
#'   mun <- read_uf(cod_uf="all", year=2010)
#'
#'}

read_uf <- function(year=NULL, cod_uf=NULL){

  # Get metadata with data addresses
  tempf <- file.path(tempdir(), "metadata.rds")
  
  # check if metadata has already been downloaded
  if (file.exists(tempf)) {
    metadata <- readr::read_rds(tempf)
    
  } else {
    # download it and save to metadata
    httr::GET(url="http://www.ipea.gov.br/geobr/metadata/metadata.rds", httr::write_disk(tempf, overwrite = T))
    metadata <- readr::read_rds(tempf)
  }
  
  
  # Select geo
  temp_meta <- subset(metadata, geo=="uf")
  
  
  # Verify year input
  if (is.null(year)){ cat("Using data from year 2010 \n")
    temp_meta <- subset(temp_meta, year==2010)
    
  } else if (year %in% temp_meta$year){ temp_meta <- temp_meta[temp_meta[,2] == year, ]
  
  } else { stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                       paste(unique(temp_meta$year),collapse = " ")))
  }
  
  
  # Verify cod_uf input
  
  # Test if cod_uf input is null
  if(is.null(cod_uf)){ stop("Value to argument 'cod_uf' cannot be NULL") }
  
  # if cod_uf=="all", read the entire country
  else if(cod_uf=="all"){ cat("Loading data for the whole country \n")
    
    # list paths of files to download
    filesD <- as.character(temp_meta$download_path)
    
    # download files
    lapply(X=filesD, function(x) httr::GET(url=x, 
                                           httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T)) )
    
    
    # read files and pile them up
    files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
    files <- paste0(tempdir(),"/",files)
    files <- lapply(X=files, FUN= readr::read_rds)
    shape <- do.call('rbind', files)
    return(shape)
  }
  
  else if( !(substr(x = cod_uf, 1, 2) %in% temp_meta$code)){
    stop("Error: Invalid Value to argument cod_uf.")
    
  } else{
    
    # list paths of files to download
    filesD <- as.character(subset(temp_meta, code==substr(cod_uf, 1, 2))$download_path)
    
    # download files
    temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD, httr::write_disk(temps, overwrite = T))
    
    # read sf
    shape <- readr::read_rds(temps)
    
    if(nchar(cod_uf)==2){
      return(shape)
      
    } else if(cod_uf %in% shape$cod_uf){
      x <- cod_uf
      shape <- subset(shape, cod_uf==x)
      return(shape)
      
    } else{
      stop("Error: Invalid Value to argument cod_uf.")
    }
  }
}
