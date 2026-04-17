#' Download spatial data of meso regions
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @template year
#' @param code_meso The 4-digit code of a meso region. If the two-digit code or
#'        a two-letter uppercase abbreviation of a state is passed, (e.g. 33 or
#'        "RJ") the function will load all meso regions of that state. If
#'        `code_meso="all"` (Default), the function downloads all meso
#'        regions of the country.
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
#' # Read specific meso region at a given year
#' meso <- read_meso_region(code_meso=3301, year = 2018)
#'
#' # Read all meso regions of a state at a given year
#' meso <- read_meso_region(code_meso="AM", year = 2018)
#' meso <- read_meso_region(code_meso=12, year = 2018)
#'
#' # Read all meso regions of the country at a given year
#' meso <- read_meso_region(code_meso="all", year = 2018)
#'
read_meso_region <- function(year,
                             code_meso = "all",
                             simplified = TRUE,
                             as_sf = TRUE,
                             showProgress = TRUE,
                             cache = TRUE,
                             verbose = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography="mesoregions",
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
  temp_arrw <- filter_arrw(temp_arrw, code = code_meso)

  # convert to sf
  if(isTRUE(as_sf)){
    temp_arrw <- sf::st_as_sf(temp_arrw)
  }

  return(temp_arrw)

}
