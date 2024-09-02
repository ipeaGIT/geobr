#' Download spatial data of historically comparable municipalities
#'
#' @description
#' This function downloads the shape file of minimum comparable area of
#' municipalities, known in Portuguese as 'Areas minimas comparaveis (AMCs)'.
#' The data is available for any combination of census years between 1872-2010.
#' These data sets are generated based on the Stata code originally developed by
#' Ehrl (2017) \doi{10.1590/0101-416147182phe}, and translated into `R` by the
#' `geobr` team.
#'
#' @param start_year Numeric. Start year to the period in the YYYY format.
#'        Defaults TO `1970`.
#' @param end_year Numeric. End year to the period in the YYYY format. Defaults
#'        to `2010`.
#' @template simplified
#' @template showProgress
#' @template cache
#'
#' @return An `"sf" "data.frame"` object
#'
#' @details
#' These data sets are generated based on the original Stata code developed by
#' Philipp Ehrl. If you use these data, please cite:
#' - Ehrl, P. (2017). Minimum comparable areas for the period 1872-2010: an
#'   aggregation of Brazilian municipalities. Estudos Econômicos (São Paulo),
#'   47(1), 215-229. https://doi.org/10.1590/0101-416147182phe
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#'   amc <- read_comparable_areas(start_year=1970, end_year=2010)
#'
read_comparable_areas <- function(start_year = 1970,
                                  end_year = 2010,
                                  simplified = TRUE,
                                  showProgress = TRUE,
                                  cache = TRUE){

  # tests
  years_available <- c(1872,1900,1911,1920,1933,1940,1950,1960,1970,1980,1991,2000,2010)

  if( !(start_year %in% years_available) ){  stop(paste0("Invalid 'start_year'. It must be one of the following: ",
                                paste(years_available, collapse = " "))) }

  if( !(end_year %in% years_available) ){  stop(paste0("Invalid 'end_year'. It must be one of the following: ",
                                                         paste(years_available, collapse = " "))) }

  if( end_year <= start_year){  stop(paste0("start_year must be smaller than end_year")) }


  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="amc", year=start_year, simplified=simplified)

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # subset based on end_year
  target_year <- paste0(start_year, '_', end_year)
  file_url <- file_url[ file_url %like% target_year]

  # download files
  temp_sf <- download_gpkg(file_url = file_url,
                           showProgress = showProgress,
                           cache = cache)

  # check if download failed
  if (is.null(temp_sf)) { return(invisible(NULL)) }

  return(temp_sf)

}
