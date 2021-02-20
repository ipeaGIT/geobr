#' Download spatial data of Brazilian health regions
#'
#' @description
#' Download spatial data of Brazilian health regions
#'
#' @param year Year of the data. Ddefaults to 2013, latest available.
#' @param simplified Logic `FALSE` or `TRUE`, indicating whether the function
#' returns the data set with original' resolution or a data set with 'simplified'
#' borders. Defaults to `TRUE`. For spatial analysis and statistics users should
#' set `simplified = FALSE`. Borders have been simplified by removing vertices of
#' borders using `sf::st_simplify()` preserving topology with a `dTolerance` of 100.
#' @param showProgress Logical. Defaults to `TRUE` display progress bar
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family general area functions
#' @examples \donttest{
#' # Read all health regions for a given year
#' hr <- read_health_region( year=2013)
#'}
read_health_region <- function(year=2013, simplified=TRUE, showProgress=TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="health_region", year=year, simplified=simplified)

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
  return(temp_sf)

}
