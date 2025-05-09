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
#' @template showProgress
#' @template cache
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read an specific immediate region
#'   im <- read_immediate_region(code_immediate=110006)
#'
#' # Read immediate regions of a state
#'   im <- read_immediate_region(code_immediate=12)
#'   im <- read_immediate_region(code_immediate="AM")
#'
#'# Read all immediate regions of the country
#'   im <- read_immediate_region()
#'   im <- read_immediate_region(code_immediate="all")
#'
read_immediate_region <- function(year = NULL,
                                  code_immediate = "all",
                                  simplified = TRUE,
                                  showProgress = TRUE,
                                  cache = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="immediate_regions", year=year, simplified=simplified)

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url = file_url,
                           showProgress = showProgress,
                           cache = cache)

  # check if download failed
  if (is.null(temp_sf)) { return(invisible(NULL)) }

  ## FILTERS
  y <- code_immediate

  # check code_immediate input
  if(code_immediate=="all"){

    # abbrev_state
  } else if(code_immediate %in% temp_sf$abbrev_state){
    temp_sf <- subset(temp_sf, abbrev_state == y)

    # code_state
  } else if(code_immediate %in% temp_sf$code_state){
    temp_sf <- subset(temp_sf, code_state == y)

    # code_immediate
  } else if(code_immediate %in% temp_sf$code_immediate){
    temp_sf <- subset(temp_sf, code_immediate == y)

  } else {stop(paste0("Error: Invalid Value to argument 'code_immediate'",collapse = " "))}

  return(temp_sf)
}
