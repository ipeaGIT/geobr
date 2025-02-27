#' Download spatial data of Brazilian municipalities
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674).
#'
#' @template year
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
#' @param keep_areas_operacionais Logic. Whether the function should keep the
#'        polygons of Lagoas dos Patos and Lagoa Mirim in the State of Rio Grande
#'        do Sul (considered as areas estaduais operacionais). Defaults to `FALSE`.

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
read_municipality <- function(year = NULL,
                              code_muni = "all",
                              simplified = TRUE,
                              showProgress = TRUE,
                              cache = TRUE,
                              keep_areas_operacionais = FALSE) {

  # check input
  if (!is.logical(keep_areas_operacionais)) { stop("'keep_areas_operacionais' must be of type 'logical'") }


  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="municipality", year=year, simplified=simplified)

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # check code_muni exists in metadata
  if (!any(code_muni == 'all' |
           code_muni %in% temp_meta$code |
           substring(code_muni, 1, 2) %in% temp_meta$code |
           code_muni %in% temp_meta$code_abbrev |
           (temp_meta$year[1] < 1992 & temp_meta$code %in% "mu")
  )) {
    stop("Error: Invalid Value to argument code_muni.")
  }

  # get file url
  if (code_muni=="all" | temp_meta$year[1] < 1992) {
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

  ## FILTERS
  y <- code_muni

  # input "all"
  if(code_muni=="all"){

    # abbrev_state
  } else if(code_muni %in% temp_sf$abbrev_state){
    temp_sf <- subset(temp_sf, abbrev_state == y)

    # code_state
  } else if(code_muni %in% temp_sf$code_state){
    temp_sf <- subset(temp_sf, code_state == y)

    # code_muni
  } else if(code_muni %in% temp_sf$code_muni){
    temp_sf <- subset(temp_sf, code_muni == y)

  } else {stop(paste0("Error: Invalid Value to argument 'code_muni'",collapse = " "))}

  # keep_areas_operacionais
  if(isFALSE(keep_areas_operacionais)){
    temp_sf <- subset(temp_sf, code_muni != 4300001)
    temp_sf <- subset(temp_sf, code_muni != 4300002)
    }

  return(temp_sf)
  }
