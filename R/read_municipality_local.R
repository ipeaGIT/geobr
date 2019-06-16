#' Download shape files of municipalities
#'
#' @param year Year of the data (defaults to 2010)
#' @param cod_muni The 7-digit code of a municipality. If the two-digit code of a state is used,
#' the function will load all municipalities of that state. If cod_muni="all", all municipalities will be loaded.
#' @export
#' @family general area functions
#' @examples \dontrun{
#'
#' library(geobr)
#'
#' # Read specific municipality at a given year
#'   mun <- read_municipality(cod_muni=1200179, year=2017)
#'
#'# Read all municipalities of a state at a given year
#'   mun <- read_municipality(cod_muni=12, year=2010)
#'
#'}

read_municipality2 <- function(cod_muni, year=NULL){

  
# BLOCK 1. Using 2010 data ---------------------------- 

  # 1.1 Verify year input
  
  if ( length(year) == 1 | year==2010 ){
    cat("Using data from year 2010") 

    # load package data
      data("brazil_2010", envir=environment())
      
      
    # 1.2 Verify cod_muni Input
  
      
      # Test if cod_muni input is null
        if(is.null(cod_muni)){ stop("Value to argument 'cod_muni' cannot be NULL") }
  
      # if cod_muni=="all", return the entire country
        if(cod_muni=="all"){ return(brazil_2010)}
        
      
      # Check if cod_muni matches an existing state
        else if( !(substr(x = cod_muni, 1, 2) %in% unique(brazil_2010$cod_state))){
          stop("Error: Invalid Value to argument cod_muni.")
    
        } else{
    
      
          # if cod_muni is a two-digit code of a state, return the whole state
          
          if(nchar(cod_muni)==2){
            
            sf <- subset(brazil_2010, cod_state==cod_muni)
            
            return(sf)
    
          # if cod_muni is a 7-digit code of a muni, return that specific muni
            
          } else if(cod_muni %in% brazil_2010$cod_muni){    # Get Municipio
            x <- cod_muni
            sf <- subset(brazil_2010, cod_muni==x)
            return(sf)
          } else{
            stop("Error: Invalid Value to argument cod_muni.") }
    
        }
      } else{
# BLOCK 2 other years ---------------------------- 
  
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
  temp_meta <- subset(metadata, geo=="municipio")




# Verify cod_muni input

  # Test if cod_muni input is null
    if(is.null(cod_muni)){ stop("Value to argument 'cod_muni' cannot be NULL") }

  # if cod_muni=="all", read the entire country
    else if(cod_muni=="all"){ cat("Loading data for the whole country. This might take a few minutes. \n")

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

  else if( !(substr(x = cod_muni, 1, 2) %in% temp_meta$code)){
      stop("Error: Invalid Value to argument cod_muni.")

  } else{

    # list paths of files to download
    filesD <- as.character(subset(temp_meta, code==substr(cod_muni, 1, 2))$download_path)

    # download files
    temps <- paste0(tempdir(),"/",unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD, httr::write_disk(temps, overwrite = T))
    
    # read sf
    shape <- readr::read_rds(temps)

      if(nchar(cod_muni)==2){
        return(shape)

      } else if(cod_muni %in% shape$cod_muni){    # Get Municipio
          x <- cod_muni
          shape <- subset(shape, cod_muni==x)
          return(shape)
      } else{
          stop("Error: Invalid Value to argument cod_muni.")
      }
  }
}}
