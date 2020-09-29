#' Download official data of indigenous lands as an sf object.
#'
#' The data set covers the whole of Brazil and it includes indigenous lands from all ethnicities and
#' in different stages of demarcation. The original data comes from the National Indian Foundation (FUNAI)
#' and can be found at http://www.funai.gov.br/index.php/shape. Although original data is updated monthly,
#' the geobr package will only keep the data for a few months per year.
#'
#'
#' @param date A date numer in YYYYMM format (Defaults to 201907)
#' @param simplified Logic FALSE or TRUE, indicating whether the function returns the
#'  data set with 'original' resolution or a data set with 'simplified' borders (Defaults to TRUE).
#'  For spatial analysis and statistics users should set simplified = FALSE. Borders have been
#'  simplified by removing vertices of borders using st_simplify{sf} preserving topology with a dTolerance of 100.
#' @param showProgress Logical. Defaults to (TRUE) display progress bar
#'
#' @export
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read all indigenous land in an specific date
#'   i <- read_indigenous_land(date=201907)
#'
#' }
#'

read_indigenous_land <- function(date=201907, simplified=TRUE, showProgress=TRUE){

# Get metadata with data url addresses
  temp_meta <- select_metadata(geography="indigenous_land", year=date, simplified=simplified)

# list paths of files to download
  file_url <- as.character(temp_meta$download_path)

# download files
  temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
  return(temp_sf)
}
