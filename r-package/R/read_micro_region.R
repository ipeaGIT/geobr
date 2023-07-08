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
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family general area functions
#' @examples \dontrun{ if (interactive()) {
#' # Read an specific micro region a given year
#'   micro <- read_micro_region(code_micro=11008, year=2018)
#'
#' # Read micro regions of a state at a given year
#'   micro <- read_micro_region(code_micro=12, year=2017)
#'   micro <- read_micro_region(code_micro="AM", year=2000)
#'
#' # Read all micro regions at a given year
#'   micro <- read_micro_region(code_micro="all", year=2010)
#' }}
read_micro_region <- function(code_micro="all", year=2010, simplified=TRUE, showProgress=TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="micro_region", year=year, simplified=simplified)

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # Verify code_micro input

  # if code_micro=="all", read the entire country
  if(code_micro=="all"){

    # list paths of files to download
    file_url <- as.character(temp_meta$download_path)

    # download files
    temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
    return(temp_sf)
  }

  if( !(substr(x = code_micro, 1, 2) %in% temp_meta$code) & !(substr(x = code_micro, 1, 2) %in% temp_meta$code_abbrev)){

    stop("Error: Invalid Value to argument code_micro.")

  } else{

    # list paths of files to download
    if (is.numeric(code_micro)){ file_url <- as.character(subset(temp_meta, code==substr(code_micro, 1, 2))$download_path) }
    if (is.character(code_micro)){ file_url <- as.character(subset(temp_meta, code_abbrev==substr(code_micro, 1, 2))$download_path) }


    # download files
    sf <- download_gpkg(file_url, progress_bar = showProgress)

    if(nchar(code_micro)==2){
      return(sf)

    } else if(code_micro %in% sf$code_micro){    # Get micro region
      x <- code_micro
      sf <- subset(sf, code_micro==x)
      return(sf)
    } else{
      stop("Error: Invalid Value to argument code_micro. There was no micro region with this code in this year")
    }
  }
}
