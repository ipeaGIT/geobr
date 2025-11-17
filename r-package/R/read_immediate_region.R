#' Download spatial data of Brazil's Immediate Geographic Areas
#'
#' @description
#' The Immediate Geographic Areas are part of the geographic division of Brazil created in 2017 by IBGE. These regions
#' were created to replace the "Micro Regions" division. Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @template year
#' @param code_immediate 6-digit code of an immediate region. If the two-digit
#'        code or a two-letter uppercase abbreviation of a state is passed, (e.g.
#'        33 or "RJ") the function will load all immediate regions of that state.
#'        If `code_immediate="all"` (Default), the function downloads all
#'        immediate regions of the country.
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
#' # Read an specific immediate region
#' im <- read_immediate_region(code_immediate=110006)
#'
#' # Read immediate regions of a state
#' im <- read_immediate_region(code_immediate=12)
#' im <- read_immediate_region(code_immediate="AM")
#'
#' # Read all immediate regions of the country
#' im <- read_immediate_region()
#' im <- read_immediate_region(code_immediate="all")
#'
read_immediate_region <- function(year = NULL,
                                  code_immediate = "all",
                                  simplified = TRUE,
                                  as_sf = TRUE,
                                  showProgress = TRUE,
                                  cache = TRUE,
                                  verbose = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography="immediateregions",
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
  temp_arrw <- filter_arrw(temp_arrw, code = code_immediate)

  # convert to sf
  if(isTRUE(as_sf)){
    temp_arrw <- sf::st_as_sf(temp_arrw)
  }

  return(temp_arrw)

}
