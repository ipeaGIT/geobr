#' Download spatial data of Brazilian biomes
#'
#' @description
#' This data set includes  polygons of all biomes present in Brazilian territory
#' and coastal area. The latest data set dates to 2019 and it is available at
#' scale 1:250.000. The 2004 data set is at the scale 1:5.000.000. The original
#' data comes from IBGE. More information at \url{https://www.ibge.gov.br/apps/biomas/}
#'
#' @template year
#' @template simplified
#' @template showProgress
#' @template cache
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read biomes
#' b <- read_biomes(year = 2019)
#'
read_biomes <- function(year = NULL,
                        simplified = TRUE,
                        showProgress = TRUE,
                        cache = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="biomes", year=year, simplified=simplified)

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url = file_url,
                           showProgress = showProgress,
                           cache = cache)

  # check if download failed
  if (is.null(temp_sf)) { return(invisible(NULL)) }

  return(temp_sf)
}
