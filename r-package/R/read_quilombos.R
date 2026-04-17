#' Download spatial data of quilombo areas in Brazil
#'
#' @description
#' ......
#'
#' @template date
#' @template simplified
#' @template showProgress
#' @template cache
#' @template verbose
#'
#' @return An `"sf" "data.frame"` OR an `ArrowObject`
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read all indigenous land in an specific date
#' i <- read_indigenous_land(date=201907)
#'
read_quilombo <- function(date = NULL,
                          simplified = TRUE,
                          showProgress = TRUE,
                          cache = TRUE,
                          verbose = TRUE){

  # Get metadata
  temp_meta <- select_metadata(
    geography="quilombo",
    year = year,
    simplified = simplified,
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
