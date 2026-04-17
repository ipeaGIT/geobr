#' Download spatial data of municipal seats (sede dos municipios) of Brazil
#'
#' @description
#' This function reads the official data on the municipal seats (sede dos
#' municipios) of Brazil. The data brings the geographical coordinates (lat lon)
#' of municipal seats for various years since 1872. Original data by the
#' Brazilian Institute of Geography and Statistics (IBGE).
#'
#' @template year
#' @template as_sf
#' @template showProgress
#' @template cache
#' @template verbose
#'
#' @return An `"sf" "data.frame"` OR an `ArrowObject`
#'
#' @export
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read municipal seats in an specific year
#' m <- read_municipal_seat(year = 2022)
#'
read_municipal_seat <- function(year = NULL,
                                as_sf = TRUE,
                                showProgress = TRUE,
                                cache = TRUE,
                                verbose = TRUE){

  # Get metadata
  temp_meta <- select_metadata(
    geography="municipalseats",
    year = year,
    simplified = FALSE,
    verbose = verbose
  )

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # download file and open arrow dataset
  temp_arrw <- download_parquet(
    filename_to_download = temp_meta$file_name,
    showProgress = showProgress,
    cache = cache
  )

  # check if download failed
  if (is.null(temp_arrw)) { return(invisible(NULL)) }

  # convert to sf
  if(isTRUE(as_sf)){
    temp_arrw <- sf::st_as_sf(temp_arrw)
  }

  return(temp_arrw)
}
