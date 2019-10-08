#' Download official data of Brazilian biomes as an sf object.
#'
#' This data set covers the whole of Brazil and it includes the polygons of all of all biomes present in Brazilian
#' territory. The last update of the data was 2004 (only year for which the data is currently available). The original
#' data comes from IBGE and can be found at https://geoftp.ibge.gov.br/informacoes_ambientais/estudos_ambientais/biomas/ .
#'
#' @param year A date number in YYYY format (defaults to 2004)
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read biomes
#'   b <- read_biomes(year=2004)
#'
#'}
#'

read_biomes <- function(year=NULL){

  # Get metadata with data addresses
  metadata <- download_metadata()


  # Select geo
  temp_meta <- subset(metadata, geo=="biomes")


  # 1.1 Verify year input
  if (is.null(year)){ year <- 2004}

  if(!(year %in% temp_meta$year)){ stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                                               paste(unique(temp_meta$year),collapse = " ")))
  }

  message(paste0("Using data from year ", year))



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
