#' Download official data of Brazil's Legal Amazon as an sf object.
#'
#' This data set covers the whole of Brazil's Legal Amazon as defined in the federal law n. 12.651/2012). The original
#' data comes from the Brazilian Ministry of Environment (MMA) and can be found at http://mapas.mma.gov.br/i3geo/datadownload.htm .
#'
#' @param year A date number in YYYY format (defaults to 2012)
#' @param simplified Logic FALSE or TRUE, indicating whether the function returns the
#'  data set with 'original' resolution or a data set with 'simplified' borders (Defaults to TRUE).
#'  For spatial analysis and statistics users should set simplified = FALSE. Borders have been
#'  simplified by removing vertices of borders using st_simplify{sf} preserving topology with a dTolerance of 100.
#' @param showProgress Logical. Defaults to (TRUE) display progress bar
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read Brazilian Legal Amazon
#'   a <- read_amazon(year=2012)
#'}
#'
read_amazon <- function(year=2012, simplified=TRUE, showProgress=TRUE, tp){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="amazonia_legal", year=year, simplified=simplified)

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
  return(temp_sf)
}
