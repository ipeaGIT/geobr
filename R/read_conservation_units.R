#' Download official data of Brazilian conservation untis as an sf object.
#'
#' This data set covers the whole of Brazil and it includes the polygons of all conservation untis present in Brazilian
#' territory. The last update of the data was 09-2019. The original
#' data comes from MMA and can be found at http://mapas.mma.gov.br/i3geo/datadownload.htm .
#'
#' @param date A date number in YYYYMM format
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read conservation_units
#'   b <- read_conservation_units(date=201909)
#'
#'
#'

read_conservation_units <- function(date=NULL){

  # Get metadata with data addresses
  metadata <- download_metadata()


  # Select geo
  temp_meta <- subset(metadata, geo=="conservation_units")


  # 1.1 Verify year input
  if (is.null(date)){ date <- 201909
                      message(paste0("Using data from year ", date))
                      }

  if(!(date %in% temp_meta$year)){ stop(paste0("Error: Invalid Value to argument 'date'. It must be one of the following: ",
                                               paste(unique(temp_meta$year),collapse = " ")))
  }





  # # Select metadata year
  # x <- year
  # temp_meta <- subset(temp_meta, year==x)

  # list paths of files to download
  filesD <- as.character(temp_meta$download_path)

  # download files
  temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
  httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))

  # read sf
  temp_sf <- readr::read_rds(temps)
  return(temp_sf)
}


b <- read_conservation_units(date=201909)
