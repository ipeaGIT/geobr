#' Download official data of Brazilian biomes as an sf object.
#'
#' @description
#' This data set includes  polygons of all biomes present in Brazilian territory
#' and coastal area. The latest data set dates to 2019 and it is available at
#' scale 1:250.000. The 2004 data set is at the scale 1:5.000.000. The original
#' data comes from IBGE. More information at \url{https://www.ibge.gov.br/apps/biomas/}
#'
#' @param year A date number in YYYY format. Defaults to `2019`
#' @param simplified Logic `FALSE` or `TRUE`, indicating whether the function
#' returns the data set with original' resolution or a data set with 'simplified'
#' borders. Defaults to `TRUE`. For spatial analysis and statistics users should
#' set `simplified = FALSE`. Borders have been simplified by removing vertices of
#' borders using `sf::st_simplify()` preserving topology with a `dTolerance` of 100.
#' @param showProgress Logical. Defaults to `TRUE` display progress bar
#'
#' @export
#' @family general area functions
#' @examples \donttest{
#' # Read biomes
#' b <- read_biomes(year = 2019)
#'}
read_biomes <- function(year=2019, simplified=TRUE, showProgress=TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="biomes", year=year, simplified=simplified)

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
  return(temp_sf)
}
