#' Download shape files of micro region.
#'
#' @param year Year of the data (defaults to 2010)
#' @param cod_micro 5-digit code of a micro region. If the two-digit code of a state is passed,
#' the function will load all micro regions of that state. If cod_micro="all", all micro regions of the country are loaded.
#' @export
#' @family general area functions
#' @examples \dontrun{
#'
#' library(geobr)
#'
#' # Read all micro regions of a state at a given year
#'   micro <- read_microregiao(cod_micro=12, year=2017)
#'
#'# Read all micro regions at a given year
#'   micro <- read_microregiao(cod_micro="all", year=2010)
#' }
#'
#'

read_microregiao <- function(year=NULL, cod_micro=NULL){

  
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
  temp_meta <- subset(metadata, geo=="micro_regiao")
  
  
  # Verify year input
  if (is.null(year)){ cat("Using data from year 2010 \n")
    temp_meta <- subset(temp_meta, year==2010)
    
  } else if (year %in% temp_meta$year){ temp_meta <- temp_meta[temp_meta[,2] == year, ]
  
  } else { stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                       paste(unique(temp_meta$year),collapse = " ")))
  }
  
  
  # Verify cod_micro input
  
  # Test if cod_micro input is null
  if(is.null(cod_micro)){ stop("Value to argument 'cod_micro' cannot be NULL") }
  
  # if cod_micro=="all", read the entire country
  else if(cod_micro=="all"){ cat("Loading data for the whole country \n")
    
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
  
  else if( !(substr(x = cod_micro, 1, 2) %in% temp_meta$code)){
    stop("Error: Invalid Value to argument cod_micro.")
    
  } else{
    
    # list paths of files to download
    filesD <- as.character(subset(temp_meta, code==substr(cod_micro, 1, 2))$download_path)
    
    # download files
    temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD, httr::write_disk(temps, overwrite = T))
    
    # read sf
    shape <- readr::read_rds(temps)
    
    if(nchar(cod_micro)==2){
      return(shape)
      
    } else if(cod_micro %in% shape$cod_micro){    # Get micro region
      x <- cod_micro
      shape <- subset(shape, cod_micro==x)
      return(shape)
    } else{
      stop("Error: Invalid Value to argument cod_micro.")
    }
  }
}
