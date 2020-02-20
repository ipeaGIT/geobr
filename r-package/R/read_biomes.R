#' Download official data of Brazilian biomes as an sf object.
#'
#' This data set includes  polygons of all biomes present in Brazilian territory and coastal area.
#' The latest data set dates to 2019 and it is available at scale 1:250.000. The 2004 data set is at
#' the scale 1:5.000.000. The original data comes from IBGE. More information at https://www.ibge.gov.br/apps/biomas/
#'
#' @param year A date number in YYYY format (defaults to 2019)
#' @param tp Whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Default)
#'
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read biomes
#'   b <- read_biomes(year=2019)
#'
#'}
#'
read_biomes <- function(year=NULL, tp="simplified"){

  # Get metadata with data addresses
  temp_meta <- download_metadata(geography="biomes", data_type=tp)


  # 1.1 Verify year input
  if (is.null(year)){ year <- 2019}

  if(!(year %in% temp_meta$year)){ stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                                               paste( unique(temp_meta$year) ,collapse = " ") ))
  }

  message(paste0("Using data from year ", year))


  # Select metadata year
  x <- year
  temp_meta <- subset(temp_meta, year==x)

  # list paths of files to download
  filesD <- as.character(temp_meta$download_path)

  # download files
  temps <- download_gpkg(filesD)

  # read sf
  temp_sf <- sf::st_read(temps, quiet=T)
  return(temp_sf)
}
