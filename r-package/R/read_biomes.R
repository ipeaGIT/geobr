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
#' @template as_sf
#' @template showProgress
#' @template cache
#'
#' @return An `"sf" "data.frame"` OR an `ArrowObject`
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
                        as_sf = TRUE,
                        showProgress = TRUE,
                        cache = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography="biomes",
    year = year,
    simplified = simplified
  )

  # download files
  file_path <- download_piggyback(
    filename_to_download = temp_meta$file_name,
    showProgress = showProgress,
    cache = cache
  )

  # check if download failed
  if (is.null(file_path)) { return(invisible(NULL)) }

  # open arrow dataset
  temp_arrw <- arrow::open_dataset(file_path)

  # convert to sf
  if(isTRUE(as_sf)){
    temp_arrw <- sf::st_as_sf(temp_arrw)
  }

  return(temp_arrw)
}
