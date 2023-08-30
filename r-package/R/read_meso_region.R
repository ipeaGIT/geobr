#' Download spatial data of meso regions
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @param year Numeric. Year of the data in YYYY format. Defaults to `2010`.
#' @param code_meso The 4-digit code of a meso region. If the two-digit code or
#'        a two-letter uppercase abbreviation of a state is passed, (e.g. 33 or
#'        "RJ") the function will load all meso regions of that state. If
#'        `code_meso="all"` (Default), the function downloads all meso
#'        regions of the country.
#' @template simplified
#' @template showProgress
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read specific meso region at a given year
#'   meso <- read_meso_region(code_meso=3301, year=2018)
#'
#' # Read all meso regions of a state at a given year
#'   meso <- read_meso_region(code_meso=12, year=2017)
#'   meso <- read_meso_region(code_meso="AM", year=2000)
#'
#' # Read all meso regions of the country at a given year
#'   meso <- read_meso_region(code_meso="all", year=2010)
#'
read_meso_region <- function(code_meso="all", year=2010, simplified=TRUE, showProgress=TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="meso_region", year=year, simplified=simplified)

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

# Verify code_meso input

  # if code_meso=="all", read the entire country
  if(code_meso=="all"){

    # list paths of files to download
    file_url <- as.character(temp_meta$download_path)

    # download files
    temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
    return(temp_sf)

  }

  if( !(substr(x = code_meso, 1, 2) %in% temp_meta$code) & !(substr(x = code_meso, 1, 2) %in% temp_meta$code_abbrev)){
    stop("Error: Invalid Value to argument code_meso.")

  } else{

    # list paths of files to download
    if (is.numeric(code_meso)){ file_url <- as.character(subset(temp_meta, code==substr(code_meso, 1, 2))$download_path) }
    if (is.character(code_meso)){ file_url <- as.character(subset(temp_meta, code_abbrev==substr(code_meso, 1, 2))$download_path) }



    # download files
    temp_sf <- download_gpkg(file_url, progress_bar = showProgress)


    if(nchar(code_meso)==2){
      return(temp_sf)

    } else if(code_meso %in% temp_sf$code_meso){    # Get meso region
      x <- code_meso
      temp_sf <- subset(temp_sf, code_meso==x)
      return(temp_sf)
    } else{
      stop("Error: Invalid Value to argument code_meso.")
    }
  }
}
