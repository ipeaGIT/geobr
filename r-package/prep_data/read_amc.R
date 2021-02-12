#' Download shape file of the longitudinal databases of municipalities as sf objects.
#'
#'
#' @description
#' Áreas mínimas comparáveis (AMCs). These are based
#' Stata code originally developed by Philipp Ehrl \url{https://doi.org/10.1590/0101-416147182phe},
#' and translated to R by the geobr team.
#'Minimum Comparable Areas for the period 1872-2010: an aggregation of Brazilian municipalities
#'Data available for combination of census years.
#'
#' @param start_year Numeric. Start year to the period.
#' @param end_year Numeric. End year to the period. (defaults to 2010)

#' @param simplified Logic FALSE or TRUE, indicating whether the function returns the
#'  data set with 'original' resolution or a data set with 'simplified' borders (Defaults to TRUE).
#'  For spatial analysis and statistics users should set simplified = FALSE. Borders have been
#'  simplified by removing vertices of borders using st_simplify{sf} preserving topology with a dTolerance of 100.
#' @param showProgress Logical. Defaults to (TRUE) display progress bar
#'
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#'   amc <- read_amc(start_year=1970, end_year=2010)
#'}
#'

read_amc <- function(start_year=1970, end_year=2010, simplified=TRUE, showProgress=TRUE){

  ## tests
  start_year in available years
  end_year in available years
  start_year < end_year

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
