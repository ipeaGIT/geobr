#' Download shape files of Brazilian Regional Inter-Management Committees as sf objects. Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' Directory 1991 (Valid for 1991 and 1992)
#' Directory 1994 (Valid for 1993 to 1996)
#' Directory 1997 (Valid for 1997 to 2000)
#' Directory 2001 (Valid for 2001 to 2004)
#' Directory 2005 (Valid for 2005 to 2008)
#' Directory 2013 (Valid for 2009+)
#'
#' @param year Year of the data (defaults to 2010)
#' @param code_sus The 5-digit code of Regional Inter-Management Committees. If the two-digit code or a two-letter uppercase abbreviation of
#'  a state is passed, (e.g. 33 or "RJ") the function will load all municipalities of that state. If code_muni="all", all municipalities of the country will be loaded.
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read specific municipality at a given year
#'   mun <- read_municipality(code_sus=12001, year=2013)
#'
#'# Read all municipalities of a state at a given year
#'   mun <- read_municipality(code_muni=33, year=2013)
#'   mun <- read_municipality(code_muni="RJ", year=2013)
#'
#'# Read all municipalities of the country at a given year
#'   mun <- read_municipality(code_muni="all", year=2013)
#'
#''
#'}

read_sus_region <- function(code_sus, year=NULL){
  
# Get metadata with data addresses
  metadata <- geobr::download_metadata()

  
# Select metadata geo
  temp_meta <- subset(metadata, geo=="sus")
  

  # 2.1 Verify year input
  # Verify year input
  if (is.null(year)){ year <- 2013
  message(paste0("Using the most recent data",collapse = " "))}
  # Test if year exist
  if (year<1991 | year>2019){stop(paste0("Error: Invalid Value to argument 'year'.It must be one of the following: \n
                                         1991 - 2018",collapse = " "))}
  # Test if code_muni input is null
  if(is.null(code_sus)){stop(paste0("Value to argument 'code_sus' cannot be NULL",collapse = " "))}
  # if code_muni=="all", read the entire country


# BLOCK 2.1 From 1872 to 1991  ----------------------------
  # Select metadata year  
  
    if(year >= 1991 & year <= 1992){
   
    x <- 1991
    temp_meta <- subset(temp_meta, year==x)
    message(paste0("Using data from year ", x))  
    
    
    filesD <- as.character(temp_meta$download_path)
    
    # Input for progress bar
    total <- length(filesD)
    pb <- utils::txtProgressBar(min = 0, max = total, style = 3)
    
    
    lapply(X=filesD, function(x){
      i <- match(c(x),filesD);
      httr::GET(url=x, #httr::progress(),
                httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T));
      utils::setTxtProgressBar(pb, i)
    })
    close(pb)
    
    # read files and pile them up
    files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
    files <- paste0(tempdir(),"/",files)
    sf <- readr::read_rds(files)
    }
    
   if(year >= 1993 & year <= 1996){

    x <- 1994
    temp_meta <- subset(temp_meta, year==x)
    message(paste0("Using data from year ", x))  
    
    
    filesD <- as.character(temp_meta$download_path)
    
    # Input for progress bar
    total <- length(filesD)
    pb <- utils::txtProgressBar(min = 0, max = total, style = 3)
    
    
    lapply(X=filesD, function(x){
      i <- match(c(x),filesD);
      httr::GET(url=x, #httr::progress(),
                httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T));
      utils::setTxtProgressBar(pb, i)
    })
    close(pb)
    
    # read files and pile them up
    files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
    files <- paste0(tempdir(),"/",files)
    sf <- readr::read_rds(files)
      
    } 
  
    if(year >= 1997 & year <= 2000){
    
      x <- 1997
      temp_meta <- subset(temp_meta, year==x)
      message(paste0("Using data from year ", x))  
      
      
      filesD <- as.character(temp_meta$download_path)
      
      # Input for progress bar
      total <- length(filesD)
      pb <- utils::txtProgressBar(min = 0, max = total, style = 3)
      
      
      lapply(X=filesD, function(x){
        i <- match(c(x),filesD);
        httr::GET(url=x, #httr::progress(),
                  httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T));
        utils::setTxtProgressBar(pb, i)
      })
      
      close(pb)
      
      # read files and pile them up
      files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
      files <- paste0(tempdir(),"/",files)
      sf <- readr::read_rds(files)
    } 
  
    if(year >= 2001 & year <= 2004){
      
      x <- 2001
      temp_meta <- subset(temp_meta, year==x)
      message(paste0("Using data from year ", x))  
      
      filesD <- as.character(temp_meta$download_path)
      
      # Input for progress bar
      total <- length(filesD)
      pb <- utils::txtProgressBar(min = 0, max = total, style = 3)
      
      
      lapply(X=filesD, function(x){
        i <- match(c(x),filesD);
        httr::GET(url=x, #httr::progress(),
                  httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T));
        utils::setTxtProgressBar(pb, i)
      })
      close(pb)
      
      # read files and pile them up
      files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
      files <- paste0(tempdir(),"/",files)
      sf <- readr::read_rds(files)
    }
  
    if(year >= 2005 & year <= 2008){
    
      x <- 2005
      temp_meta <- subset(temp_meta, year==x)
      message(paste0("Using data from year ", x))  
      
      
      filesD <- as.character(temp_meta$download_path)
      
      # Input for progress bar
      total <- length(filesD)
      pb <- utils::txtProgressBar(min = 0, max = total, style = 3)
      
      
      lapply(X=filesD, function(x){
        i <- match(c(x),filesD);
        httr::GET(url=x, #httr::progress(),
                  httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T));
        utils::setTxtProgressBar(pb, i)
      })
      close(pb)
      
      # read files and pile them up
      files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
      files <- paste0(tempdir(),"/",files)
      sf <- readr::read_rds(files)
    }
  
   if (year >= 2009 & year <= 2018){
    
      x <- 2013
      temp_meta <- subset(temp_meta, year==x)
      message(paste0("Using data from year ", x))
      
      
      filesD <- as.character(temp_meta$download_path)
      
      # Input for progress bar
      total <- length(filesD)
      pb <- utils::txtProgressBar(min = 0, max = total, style = 3)
      
      lapply(X=filesD, function(x){
        i <- match(c(x),filesD);
        httr::GET(url=x, #httr::progress(),
                  httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T));
        utils::setTxtProgressBar(pb, i)
      })
      close(pb)
      
      # read files and pile them up
      files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
      files <- paste0(tempdir(),"/",files)
      sf <- readr::read_rds(files)
    } 

   #  Verify code_muni Input
    
      if(code_sus=="all"){ message("Loading data for the whole country. This might take a few minutes.\n")
      # list paths of files to download

      return(sf)
      
      } else if ( !(substr(x = code_sus, 1, 2) %in% sf$code_state) & !(substr(x = code_sus, 1, 2) %in% sf$abbrev_state)){
      
      stop("Error: Invalid Value to argument code_sus.")
      
    } else{
      
      # List paths of files to download
      
      x<-substr(code_sus, 1, 2)
      
      if (is.numeric(code_sus)){sf <- as.character(subset(sf,code_state==x)) }
      
      if (is.character(code_sus)){sf <- subset(sf,abbrev_state %in% x) }
      
      if(nchar(code_sus)==2){
        return(sf)
        
      } 
      else{
        stop("Error: Invalid Value to argument code_sus")
      }
    }
}
