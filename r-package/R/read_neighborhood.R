#' Download spatial data of neighborhood limits of Brazilian municipalities
#'
#' @description
#' This data set includes the neighborhood limits of 720 Brazilian municipalities.
#' It is based on aggregations of the census tracts from the Brazilian
#' census. Only 2010 data is currently available.
#'
#' @param year Year of the data. Defaults to `2010`
#' @param simplified Logic `FALSE` or `TRUE`, indicating whether the function
#' returns the data set with 'original' resolution or a data set with 'simplified'
#' borders. Defaults to `TRUE`. For spatial analysis and statistics users should
#' set `simplified = FALSE`. Borders have been simplified by removing vertices of
#' borders using `st_simplify{sf}` preserving topology with a `dTolerance` of 100.
#' @param showProgress Logical. Defaults to `TRUE`` display progress bar
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family general area functions
#' @examples \dontrun{
#' # Read neighborhoods of Brazilian municipalities
#' n <- read_neighborhood(year=2010)
#'}
read_neighborhood <- function(year=2010, simplified=TRUE, showProgress=TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="neighborhood", year=year, simplified=simplified)

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
  return(temp_sf)
}
