#' Download shape files of official metropolitan areas in Brazil as an sf object.
#'
#' The function returns the shapes of municipalities grouped by their respective metro areas.
#' Metropolitan areas are created by each state in Brazil. The data set includes the municipalities that belong to
#' all metropolitan areas in the country according to state legislation in each year. Orignal data were generated
#' by Institute of Geography. Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674).
#'
#'
#' @param year A year number in YYYY format (defaults to 2018)
#' @param tp Whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Default)
#' @param showProgress Logical. Defaults to (TRUE) display progress bar
#'
#' @export
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read all official metropolitan areas for a given year
#'   m <- read_metro_area(2005)
#'
#'   m <- read_metro_area(2018)
#' }
#'
#'
#'
read_metro_area <- function(year=2018, tp="simplified", showProgress=TRUE){


  # Get metadata with data addresses
  temp_meta <- download_metadata(geography="metropolitan_area", data_type=tp)

 # Test year input
  temp_meta <- test_year_input(temp_meta, y=year)


  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
  return(temp_sf)
}
