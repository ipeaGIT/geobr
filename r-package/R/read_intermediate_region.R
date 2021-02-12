#' Download spatial data of Brazil's Intermediate Geographic Areas
#'
#' @description
#' The intermediate Geographic Areas are part of the geographic division of
#' Brazil created in 2017 by IBGE. These regions were created to replace the
#' "Meso Regions" division. Data at scale 1:250,000, using Geodetic reference
#' system "SIRGAS2000" and CRS(4674)
#'
#' @param year A year number in YYYY format. Defaults to `2019`
#' @param code_intermediate 4-digit code of an intermediate region. If the
#' two-digit code or a two-letter uppercase abbreviation of a state is passed,
#' (e.g. 33 or "RJ") the function will load all intermediate regions of that
#' state. If `code_intermediate="all"` (Default), all intermediate regions of
#' the country are loaded.
#' @param simplified Logic `FALSE` or `TRUE`, indicating whether the function
#' returns the data set with original' resolution or a data set with 'simplified'
#' borders. Defaults to `TRUE`. For spatial analysis and statistics users should
#' set `simplified = FALSE`. Borders have been simplified by removing vertices of
#' borders using `sf::st_simplify()` preserving topology with a `dTolerance` of 100.
#' @param showProgress Logical. Defaults to `TRUE` display progress bar
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family general area functions
#' @examples \dontrun{
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
#' }
read_intermediate_region <- function(code_intermediate="all", year=2019, simplified=TRUE, showProgress=TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="intermediate_regions", year=year, simplified=simplified)

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url, progress_bar = showProgress)


  # input "all"
  if(code_intermediate=="all"){ message("Loading data for the whole country. This might take a few minutes.\n")

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
