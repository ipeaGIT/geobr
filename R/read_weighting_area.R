#' Download shape files of Census Weighting Areas (área de ponderação) of the Brazilian Population Census
#'
#' @param CODE One can either pass the 7-digit code of a Municipality or the 2-digit code of a State. The function will load the shape files of all weighting areas in the specified geography
#' @param year the year of the data download (defaults to 2010)
#' @export
#' @family general area functions
#' @examples \dontrun{
#'
#' library(geobr)
#'
#'dados <- read_weighting_area(year=2010)
#'dados <- read_weighting_area(3500000,2010)
#'dados <- read_weighting_area(123,2010)
#'dados <- read_weighting_area("df",2010)
#'dados <- read_weighting_area(1302603,2010)
#'dados <- read_weighting_area(35)
#'dados <- read_weighting_area(14,2010)
#'dados <- read_weighting_area("all")
#'
#'# map it
#'library(mapview)
#'mapview(dados)
#' }
#'
#'
#'
#'
read_weighting_area <- function(code_weighting, year = NULL){ #code_weighting=1400100
  
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
  temp_meta <- subset(metadata, geo=="area_ponderacao")
  
  # Verify year input
  if (is.null(year)){ cat("Using data from year 2010 \n")
    temp_meta <- subset(temp_meta, year==2010)
    
  } else if (year %in% temp_meta$year){ temp_meta <- temp_meta[as.vector(temp_meta[,2] == year), ]
  
  } else { stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                       paste(unique(temp_meta$year),collapse = " ")))
  }
  
  # Verify code_weighting input
  
  # Test if code_weighting input is null
  if(is.null(code_weighting)){ stop("Value to argument 'code_weighting' cannot be NULL") }
  
  # if code_weighting=="all", read the entire country
  else if(code_weighting=="all"){ cat("Loading data for the whole country. This might take a few minutes. \n")
    
    # list paths of files to download
    filesD <- as.character(temp_meta$download_path)
    
    
    # download files
    lapply(X=filesD, function(x) httr::GET(url=x, httr::progress(),
                                           httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T)) )
    
    
    # read files and pile them up
    files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
    files <- paste0(tempdir(),"/",files)
    files <- lapply(X=files, FUN= readr::read_rds)
    shape <- do.call('rbind', files)
    return(shape)
  }
  
  else if( !(substr(x = code_weighting, 1, 2) %in% temp_meta$code)){
    stop("Error: Invalid Value to argument code_weighting.")
    
  }else{
    
    # list paths of files to download
    filesD <- as.character(subset(temp_meta, code==substr(code_weighting, 1, 2))$download_path)
    
    # download files
    temps <- paste0(tempdir(),"/",unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD, httr::write_disk(temps, overwrite = T))
    
    # read sf
    shape <- readr::read_rds(temps)
    
    if(nchar(code_weighting)==2){
      return(shape)
      
    } else if(code_weighting %in% shape$cod_muni){    # Get weighting
      x <- code_weighting
      shape <- subset(shape, cod_muni==x)
      return(shape)
    } else{
      stop("Error: Invalid Value to argument code_weighting.")
    }
  }
}

