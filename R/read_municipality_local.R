#' Download sf files of Brazilian municipalities
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
  if (is.null(year)){ year <- 2010}
    
  if (  year==2010 ){
    cat("Using data from year 2010") 

    # load package data
      data("brazil_2010", envir=environment())
      
      

      
    # 1.2 Verify code_muni Input
      
      # Test if code_muni input is null
        if(is.null(code_muni)){ stop("Value to argument 'code_muni' cannot be NULL") }
  
      # if code_muni=="all", return the entire country
        if(code_muni=="all"){
                              sf <- brazil_2010
                              return( sf )
                              }
        
      
      # Check if code_muni matches an existing state
        else if( !(substr(x = code_muni, 1, 2) %in% unique(brazil_2010$code_state))){
          stop("Error: Invalid Value to argument code_muni.")
    
        } else{
    
      
          # if code_muni is a two-digit code of a state, return the whole state
          
          if(nchar(code_muni)==2){
            
            x <- code_muni
            sf <- subset(brazil_2010, code_state==x)
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

# Select metadata geo
  temp_meta <- subset(metadata, geo=="municipio")
  
  # 2.1 Verify year input
  
  
  
  # Test if code_muni input is null
  if(!(year %in% temp_meta$year)){ stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                                                paste(unique(temp_meta$year),collapse = " ")))
    }

# Select metadata year
  x <- year
  temp_meta <- subset(temp_meta, year==x)
  
  
  
  
  
# 2.2 Verify code_muni Input

  # Test if code_muni input is null
    if(is.null(code_muni)){ stop("Value to argument 'code_muni' cannot be NULL") }

  # if code_muni=="all", read the entire country
    if(code_muni=="all"){ cat("Loading data for the whole country. This might take a few minutes. \n")

      # list paths of files to download
      filesD <- as.character(temp_meta$download_path)


      # download files
      counter <- 0
      lapply(X=filesD, function(X){ counter <<- counter + 1
                                    print(paste("Downloading ", counter, " of 27 files"))
                                    httr::GET(url=X, httr::progress(),
                                              httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(X,"/"),tail,n=1L))), overwrite = T))})
      

      # read files and pile them up
      files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
      files <- paste0(tempdir(),"/",files)
      files <- lapply(X=files, FUN= readr::read_rds)
      sf <- do.call('rbind', files)
      return(sf)
    }

  else if( !(substr(x = code_muni, 1, 2) %in% temp_meta$code)){
      stop("Error: Invalid Value to argument code_muni.")

  } else{

    # list paths of files to download
    filesD <- as.character(subset(temp_meta, code==substr(code_muni, 1, 2))$download_path)

    # download files
    temps <- paste0(tempdir(),"/",unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD,  httr::progress(), httr::write_disk(temps, overwrite = T))
    
    # read sf
    sf <- readr::read_rds(temps)

      if(nchar(code_muni)==2){
        return(sf)

      } else if(code_muni %in% sf$code_muni){    # Get Municipio
          x <- code_muni
          sf <- subset(sf, code_muni==x)
          return(sf)
      } else{
          stop("Error: Invalid Value to argument code_muni.")
      }
  }
}}
