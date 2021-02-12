#' Download spatial data of historically comparable municipalities
#'
#' @description
#' This function downloads the shape file of minimum comparable area of
#' municipalities, known in Portuguese as 'Áreas mínimas comparáveis (AMCs)'.
#' The data is available for any combination of census years between 1872-2010.
#' These data sets are generated based on the Stata code originally developed by
#' Philipp Ehrl \url{https://doi.org/10.1590/0101-416147182phe}, and translated
#' into `R` by the `geobr` team. \href{https://doi.org/10.1590/0101-416147182phe}{Philipp Ehrl}
#'
#' @param start_year Numeric. Start year to the period.
#' @param end_year Numeric. End year to the period. (defaults to 2010)
#' @param simplified Logic FALSE or TRUE, indicating whether the function returns the
#'  data set with 'original' resolution or a data set with 'simplified' borders (Defaults to TRUE).
#'  For spatial analysis and statistics users should set simplified = FALSE. Borders have been
#'  simplified by removing vertices of borders using st_simplify{sf} preserving topology with a dTolerance of 100.
#' @param showProgress Logical. Defaults to (TRUE) display progress bar
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#'   amc <- read_amc(start_year=1970, end_year=2010)
#'}
#'

read_amc <- function(start_year=1970, end_year=2010, simplified=TRUE, showProgress=TRUE){

  # tests
  years_available <- c(1872,1900,1911,1920,1933,1940,1950,1960,1970,1980,1991,2000,2010)

  if( !(start_year %in% years_available) ){  stop(paste0("Invalid 'start_year'. It must be one of the following: ",
                                paste(years_available, collapse = " "))) }

  if( !(end_year %in% years_available) ){  stop(paste0("Invalid 'end_year'. It must be one of the following: ",
                                                         paste(years_available, collapse = " "))) }

  if( end_year <= start_year){  stop(paste0("start_year must be smaller than end_year")) }


  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="amc_muni", year=start_year, simplified=simplified)

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # subset based on end_year
  target_year <- paste0(start_year, '-', end_year)
  file_url <- file_url[ file_url %like% target_year]

  # download files
  temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
  return(temp_sf)

}
