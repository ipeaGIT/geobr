#' Download spatial data of Brazil Regions
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
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
#' # Read specific year
#' reg <- read_region(year=2018)
#'
read_region <- function(year = NULL,
                        simplified = TRUE,
                        as_sf = TRUE,
                        showProgress = TRUE,
                        cache = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography="regions",
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


