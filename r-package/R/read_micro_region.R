#' Download spatial data of micro regions
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @param year Numeric. Year of the data in YYYY format. Defaults to `2010`.
#' @param code_micro 5-digit code of a micro region. If the two-digit code or a
#'        two-letter uppercase abbreviation of a state is passed, (e.g. 33 or
#'        "RJ") the function will load all micro regions of that state. If
#'        `code_micro="all"` (Default), the function downloads all micro regions of the
#'        country.
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
#' # Read an specific micro region a given year
#'   micro <- read_micro_region(code_micro=11008, year=2018)
#'
#' # Read micro regions of a state at a given year
#'   micro <- read_micro_region(code_micro=12, year=2017)
#'   micro <- read_micro_region(code_micro="AM", year=2000)
#'
#' # Read all micro regions at a given year
#'   micro <- read_micro_region(code_micro="all", year=2010)
#'
read_micro_region <- function(code_micro = "all",
                              year = 2010,
                              simplified = TRUE,
                              showProgress = TRUE,
                              cache = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="micro_region", year=year, simplified=simplified)

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # Verify code_micro input
  if (!any(code_micro == 'all' |
           code_micro %in% temp_meta$code |
           substring(code_micro, 1, 2) %in% temp_meta$code |
           code_micro %in% temp_meta$code_abbrev
           )) {
    stop("Error: Invalid Value to argument code_micro.")
    }

  # get file url
  if (code_micro=="all") {
    file_url <- as.character(temp_meta$download_path)

  } else if (is.numeric(code_micro)) { # if using numeric code_micro
    file_url <- as.character(subset(temp_meta, code==substr(code_micro, 1, 2))$download_path)

  } else if (is.character(code_micro)) { # if using chacracter code_abbrev
    file_url <- as.character(subset(temp_meta, code_abbrev==substr(code_micro, 1, 2))$download_path)
    }

  # download gpkg
  temp_sf <- download_gpkg(file_url = file_url,
                           showProgress = showProgress,
                           cache = cache)

  # check if download failed
  if (is.null(temp_sf)) { return(invisible(NULL)) }

  ## FILTERS
  y <- code_micro

  # input "all"
  if(code_micro=="all"){

    # abbrev_state
  } else if(code_micro %in% temp_sf$abbrev_state){
    temp_sf <- subset(temp_sf, abbrev_state == y)

    # code_state
  } else if(code_micro %in% temp_sf$code_state){
    temp_sf <- subset(temp_sf, code_state == y)

    # code_micro
  } else if(code_micro %in% temp_sf$code_micro){
    temp_sf <- subset(temp_sf, code_micro == y)

  } else {stop(paste0("Error: Invalid Value to argument 'code_micro'",collapse = " "))}

  return(temp_sf)
}
