#' Download spatial data of quilombo areas in Brazil
#'
#' @description
#' The data set covers the whole of Brazil and it includes quilombo areas. The original data
#' comes from the National Institute of Colonization and Agrarian Reform (INCRA) and can be found at
#' \url{ttps://certificacao.incra.gov.br/csv_shp/export_shp.py}. 
#'
#' 
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
#' @examples \dontrun{ if (interactive()) {
#' # Read all quilombo areas
#' i <- read_quilombo_area()
#' }}
read_quilombo_area <- function(simplified=TRUE, showProgress=TRUE){
  
  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="quilombo_area", simplified=simplified)
  
  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)
  
  # download files
  temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
  return(temp_sf)
}
