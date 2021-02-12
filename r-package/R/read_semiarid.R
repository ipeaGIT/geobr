#' Download spatial data of the Brazilian Semiarid region
#'
#' @description
#' This data set covers the whole of Brazilian Semiarid as defined in the resolution
#' in  23/11/2017). The original data comes from the Brazilian Institute of Geography
#' and Statistics (IBGE) and can be found at \url{https://www.ibge.gov.br/geociencias/cartas-e-mapas/mapas-regionais/15974-semiarido-brasileiro.html?=&t=downloads}
#'
#' @param year A date number in YYYY format (defaults to 2017)
#' @param simplified Logic `FALSE` or `TRUE`, indicating whether the function
#' returns the data set with 'original' resolution or a data set with 'simplified'
#' borders. Defaults to `TRUE)`. For spatial analysis and statistics users should
#' set `simplified = FALSE`. Borders have been simplified by removing vertices of
#' borders using `st_simplify{sf}` preserving topology with a dTolerance of 100.
#' @param showProgress Logical. Defaults to `TRUE` display progress bar
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family general area functions
#' @examples \donttest{
#' # Read Brazilian semiarid
#' a <- read_semiarid(year=2017)
#'}
read_semiarid <- function(year=2017, simplified=TRUE, showProgress=TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="semiarid", year=year, simplified=simplified)

  #list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
  return(temp_sf)

}
