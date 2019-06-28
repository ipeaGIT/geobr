#' Download shape file of Brazil as sf objects. Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @param year Year of the data (defaults to 2010)
#' @export
#' @family general area functions
#' @examples \dontrun{
#'
#' library(geobr)
#'
#' # Read specific year
#'   br <- read_country(year=2018)
#'
#'}

read_country <- function(year=NULL){
  
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
  temp_ano <- subset(metadata, geo=="country")
  
  
  # Verify year input
  if (is.null(year)){ cat("Using data from year 2010\n")
    temp_ano <- subset(temp_ano, year==2010)
    
  } else if (year %in% temp_ano$year){ temp_ano <- temp_ano[temp_ano[,2] == year, ]
  
  } else { stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                       paste(unique(temp_ano$year),collapse = " ")))
  }
  
  
  # list paths of files to download
  filesD <- as.character(temp_ano$download_path)
  
  # download files
  temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
  httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))
  
  # read sf
  temp_sf <- readr::read_rds(temps)
  
  return(temp_sf)
}
