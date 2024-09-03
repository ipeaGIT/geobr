#' Download spatial data of Brazilian municipalities
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674).
#'
#' @param year Numeric. Year of the data in YYYY format. Defaults to `2010`.
#' @param code_muni The 7-digit identification code of a municipality. If
#'        `code_muni = "all"` (Default), the function downloads all
#'        municipalities of the country. Alternatively, if a two-digit
#'        identification code or a two-letter uppercase abbreviation of a state
#'        is passed (e.g. `33` or `"RJ"`), all municipalities of that state will
#'        be downloaded. Municipality identification codes can be consulted with
#'        the `geobr::lookup_muni()` function.
#' @template simplified
#' @template showProgress
#' @template cache
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read specific municipality at a given year
#' mun <- read_municipality(code_muni = 1200179, year = 2017)
#'
#' # Read all municipalities of a state at a given year
#' mun <- read_municipality(code_muni = 33, year = 2010)
#' mun <- read_municipality(code_muni = "RJ", year = 2010)
#'
#' # Read all municipalities of the country at a given year
#' mun <- read_municipality(code_muni = "all", year = 2018)
#'
read_municipality <- function(code_muni = "all",
                              year = 2010,
                              simplified = TRUE,
                              showProgress = TRUE,
                              cache = TRUE) {

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="municipality", year=year, simplified=simplified)

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # check code_muni exists in metadata
  if (!any(code_muni == 'all' |
           code_muni %in% temp_meta$code |
           substring(code_muni, 1, 2) %in% temp_meta$code |
           code_muni %in% temp_meta$code_abbrev |
           (year < 1992 & temp_meta$code %in% "mu")
  )) {
    stop("Error: Invalid Value to argument code_muni.")
  }

  # get file url
  if (code_muni=="all" | year < 1992) {
    file_url <- as.character(temp_meta$download_path)

  } else if (is.numeric(code_muni)) { # if using numeric code_muni
    file_url <- as.character(subset(temp_meta, code==substr(code_muni, 1, 2))$download_path)

  } else if (is.character(code_muni)) { # if using chacracter code_abbrev
    file_url <- as.character(subset(temp_meta, code_abbrev==substr(code_muni, 1, 2))$download_path)
  }

  # download gpkg
  temp_sf <- download_gpkg(file_url = file_url,
                           showProgress = showProgress,
                           cache = cache)

  # check if download failed
  if (is.null(temp_sf)) { return(invisible(NULL)) }

  # data files before 1992 do not have state code nor state abbrev
  if (code_muni =='all' ){
    return(temp_sf)
  }

  # FILTER particular state or muni
  x <- code_muni

  if (!any(code_muni %in% temp_sf$code_muni |
           code_muni %in% temp_sf$code_state |
           code_muni %in% temp_sf$abbrev_state)) {
    stop("Error: Invalid Value to argument code_muni.")
  }


  # particular state
  if(nchar(code_muni)==2){

    if (is.numeric(code_muni)) {
        temp_sf <- subset(temp_sf, code_state == x)
        }

    if (is.character(code_muni)) {
        temp_sf <- subset(temp_sf, abbrev_state == x)
        }
  }

  # particular muni
  if(nchar(code_muni)>2){
    if (is.numeric(code_muni)) {
      temp_sf <- subset(temp_sf, code_state == x)
    }
  }
  return(temp_sf)
}
