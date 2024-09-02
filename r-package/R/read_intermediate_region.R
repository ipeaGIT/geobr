#' Download spatial data of Brazil's Intermediate Geographic Areas
#'
#' @description
#' The intermediate Geographic Areas are part of the geographic division of
#' Brazil created in 2017 by IBGE. These regions were created to replace the
#' "Meso Regions" division. Data at scale 1:250,000, using Geodetic reference
#' system "SIRGAS2000" and CRS(4674)
#'
#' @param year Numeric. Year of the data in YYYY format. Defaults to `2019`.
#' @param code_intermediate 4-digit code of an intermediate region. If the
#'        two-digit code or a two-letter uppercase abbreviation of a state is
#'        passed, (e.g. 33 or "RJ") the function will load all intermediate
#'        regions of that state. If `code_intermediate="all"` (Default), the
#'        function downloads all intermediate regions of the country.
#' @template simplified
#' @template showProgress
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read an specific intermediate region
#'   im <- read_intermediate_region(code_intermediate=1202)
#'
#' # Read intermediate regions of a state
#'   im <- read_intermediate_region(code_intermediate=12)
#'   im <- read_intermediate_region(code_intermediate="AM")
#'
#'# Read all intermediate regions of the country
#'   im <- read_intermediate_region()
#'   im <- read_intermediate_region(code_intermediate="all")
#'
read_intermediate_region <- function(code_intermediate="all", year=2019, simplified=TRUE, showProgress=TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="intermediate_regions", year=year, simplified=simplified)

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url, showProgress = showProgress)

  # check if download failed
  if (is.null(temp_sf)) { return(invisible(NULL)) }

  # input "all"
  if(code_intermediate=="all"){

    # abbrev_state
  } else if(code_intermediate %in% temp_sf$abbrev_state){
    y <- code_intermediate
    temp_sf <- subset(temp_sf, abbrev_state == y)

    # code_state
  } else if(code_intermediate %in% temp_sf$code_state){
    y <- code_intermediate
    temp_sf <- subset(temp_sf, code_state == y)

    # code_intermediate
  } else if(code_intermediate %in% temp_sf$code_intermediate){
    y <- code_intermediate
    temp_sf <- subset(temp_sf, code_intermediate == y)

  } else {stop(paste0("Error: Invalid Value to argument 'code_intermediate'",collapse = " "))}

  return(temp_sf)
}
