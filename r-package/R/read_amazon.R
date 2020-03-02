#' Download official data of Brazil's Legal Amazon as an sf object.
#'
#' This data set covers the whole of Brazil's Legal Amazon as defined in the federal law n. 12.651/2012). The original
#' data comes from the Brazilian Ministry of Environment (MMA) and can be found at http://mapas.mma.gov.br/i3geo/datadownload.htm .
#'
#' @param year A date number in YYYY format (defaults to 2012)
#' @param simplified Logic TRUE or FALSE, indicating whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Defaults to TRUE)
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
read_amazon <- function(year=2012, simplified=TRUE, showProgress=TRUE){

  # Get metadata with data url addresses
  temp_meta <- download_metadata(geography="amazonia_legal", data_type=simplified)


  # Test year input
  temp_meta <- test_year_input(temp_meta, y=year)



  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
  return(temp_sf)
}
