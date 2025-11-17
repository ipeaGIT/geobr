#' Download spatial data of neighborhood limits of Brazilian municipalities
#'
#' @description
#' This data set includes the neighborhood limits of 720 Brazilian municipalities.
#' It is based on aggregations of the census tracts from the Brazilian
#' census. Only 2010 data is currently available.
#'
#' @template year
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
#' # Read neighborhoods of Brazilian municipalities
#' n <- read_neighborhood(year=2010)
#'
read_neighborhood <- function(year = NULL,
                              simplified = TRUE,
                              showProgress = TRUE,
                              cache = TRUE,
                              verbose = TRUE){

  # Get metadata
  temp_meta <- select_metadata(
    geography="neighborhood",
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
