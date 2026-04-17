#' Download spatial data of micro regions
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @template year
#' @param code_micro 5-digit code of a micro region. If the two-digit code or a
#'        two-letter uppercase abbreviation of a state is passed, (e.g. 33 or
#'        "RJ") the function will load all micro regions of that state. If
#'        `code_micro="all"` (Default), the function downloads all micro regions of the
#'        country.
#' @template simplified
#' @template as_sf
#' @template showProgress
#' @template cache
#' @template verbose
#'
#' @return An `"sf" "data.frame"` OR an `ArrowObject`
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read an specific micro region a given year
#' micro <- read_micro_region(code_micro=11008, year=2018)
#'
#' # Read micro regions of a state at a given year
#' micro <- read_micro_region(code_micro="AM", year=2018)
#' micro <- read_micro_region(code_micro=12, year=2018)
#'
#' # Read all micro regions at a given year
#'  micro <- read_micro_region(code_micro="all", year=2018)
#'
read_micro_region <- function(year = NULL,
                              code_micro = "all",
                              simplified = TRUE,
                              as_sf = TRUE,
                              showProgress = TRUE,
                              cache = TRUE,
                              verbose = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography="microregions",
    year = year,
    simplified = simplified,
    verbose = verbose
  )

  # check if metadata download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # download files
  temp_arrw <- download_parquet(
    filename_to_download = temp_meta$file_name,
    showProgress,
    cache
  )

  # check if download failed
  if (is.null(temp_arrw)) { return(invisible(NULL)) }

  # FILTER
  temp_arrw <- filter_arrw(temp_arrw, code = code_micro)

  # convert to sf
  if(isTRUE(as_sf)){
    temp_arrw <- sf::st_as_sf(temp_arrw)
  }

  return(temp_arrw)

}
