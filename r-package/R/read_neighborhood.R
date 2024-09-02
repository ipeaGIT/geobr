#' Download spatial data of neighborhood limits of Brazilian municipalities
#'
#' @description
#' This data set includes the neighborhood limits of 720 Brazilian municipalities.
#' It is based on aggregations of the census tracts from the Brazilian
#' census. Only 2010 data is currently available.
#'
#' @param year Numeric. Year of the data in YYYY format. Defaults to `2010`.
#' @template simplified
#' @template showProgress
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read neighborhoods of Brazilian municipalities
#' n <- read_neighborhood(year=2010)
#'
read_neighborhood <- function(year=2010, simplified=TRUE, showProgress=TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="neighborhood", year=year, simplified=simplified)

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url, showProgress = showProgress)

  # check if download failed
  if (is.null(temp_sf)) { return(invisible(NULL)) }

  return(temp_sf)
}
