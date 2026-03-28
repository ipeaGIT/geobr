#' Download spatial data of Brazil's national borders
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674).
#'
#' @template year
#' @template simplified
#' @template as_sf
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
#' # Read specific year
#' br <- read_country(year = 2018)
#'
read_country <- function(year,
                         simplified = TRUE,
                         as_sf = TRUE,
                         showProgress = TRUE,
                         cache = TRUE,
                         verbose = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography="country",
    year = year,
    simplified = simplified,
    verbose = verbose
  )

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
