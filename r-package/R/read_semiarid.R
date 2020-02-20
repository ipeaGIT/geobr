#' Download official data of Brazilian Semiarid as an sf object.
#'
#' This data set covers the whole of Brazilian Semiarid as defined in the resolution in  23/11/2017). The original
#' data comes from the Brazilian Institute of Geography and Statistics (IBGE) and can be found at https://www.ibge.gov.br/geociencias/cartas-e-mapas/mapas-regionais/15974-semiarido-brasileiro.html?=&t=downloads
#'
#' @param year A date number in YYYY format (defaults to 2017)
#' @param tp Whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Default)
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read Brazilian semiarid
#'   a <- read_semiarid(year=2017)
#'}
#'
read_semiarid <- function(year=NULL, tp="simplified"){

  # Get metadata with data addresses
  temp_meta <- download_metadata(geography="semiarid", data_type=tp)


  # 1.1 Verify year input
  if (is.null(year)){ year <- 2017}

  if(!(year %in% temp_meta$year)){ stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                                               paste(unique(temp_meta$year),collapse = " ")))
  }

  message(paste0("Using data from year ", year))

  x<-year

  filesD <- as.character(subset(temp_meta, year==x)$download_path)

  # # Select metadata year
  # x <- year
  # temp_meta <- subset(temp_meta, year==x)

  # list paths of files to download
  # filesD <- as.character(temp_meta$download_path)

  # download files
  temps <- download_gpkg(filesD)

  # read sf
  temp_sf <- sf::st_read(temps, quiet=T)
  return(temp_sf)
}
