#' Download shape files of municipalities
#'
#' @param year Year of the data (defaults to 2010)
#' @param code_muni The 7-digit code of a municipality. If the two-digit code of a state is used,
#' the function will load all municipalities of that state. If code_muni="all", all municipalities will be loaded.
#' @export
#' @family general area functions
#' @examples \dontrun{
#'
#' library(geobr)
#'
#' # Read specific municipality at a given year
#'   mun <- read_municipality(code_muni=1200179, year=2017)
#'
#'# Read all municipalities of a state at a given year
#'   mun <- read_municipality(code_muni=12, year=2010)
#'
#'}

read_municipality2 <- function(code_muni, year=NULL){

  
# BLOCK 1. Using 2010 data ---------------------------- 

  # 1.1 Verify year input
  
  if ( length(year) == 1 | year==2010 ){
    cat("Using data from year 2010") 

    # load package data
      data("brazil_2010", envir=environment())
      
      
    # 1.2 Verify code_muni Input
  
      
      # Test if code_muni input is null
        if(is.null(code_muni)){ stop("Value to argument 'code_muni' cannot be NULL") }
  
      # if code_muni=="all", return the entire country
        if(code_muni=="all"){ return(brazil_2010)}
        
      
      # Check if code_muni matches an existing state
        else if( !(substr(x = code_muni, 1, 2) %in% unique(brazil_2010$code_state))){
          stop("Error: Invalid Value to argument code_muni.")
    
        } else{
    
      
          # if code_muni is a two-digit code of a state, return the whole state
          
          if(nchar(code_muni)==2){
            
            sf <- subset(brazil_2010, code_state==code_muni)
            
            return(sf)
    
          # if code_muni is a 7-digit code of a muni, return that specific muni
            
          } else if(code_muni %in% brazil_2010$code_muni){    # Get Municipio
            x <- code_muni
            sf <- subset(brazil_2010, code_muni==x)
            return(sf)
          } else{
            stop("Error: Invalid Value to argument code_muni.") }
    
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




# Verify code_muni input

  # Test if code_muni input is null
    if(is.null(code_muni)){ stop("Value to argument 'code_muni' cannot be NULL") }

  # if code_muni=="all", read the entire country
    else if(code_muni=="all"){ cat("Loading data for the whole country. This might take a few minutes. \n")

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

  else if( !(substr(x = code_muni, 1, 2) %in% temp_meta$code)){
      stop("Error: Invalid Value to argument code_muni.")

  } else{

    # list paths of files to download
    filesD <- as.character(subset(temp_meta, code==substr(code_muni, 1, 2))$download_path)

    # download files
    temps <- paste0(tempdir(),"/",unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD, httr::write_disk(temps, overwrite = T))
    
    # read sf
    shape <- readr::read_rds(temps)

      if(nchar(code_muni)==2){
        return(shape)

      } else if(code_muni %in% shape$code_muni){    # Get Municipio
          x <- code_muni
          shape <- subset(shape, code_muni==x)
          return(shape)
      } else{
          stop("Error: Invalid Value to argument code_muni.")
      }
  }
}}
