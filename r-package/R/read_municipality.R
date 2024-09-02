#' Download spatial data of Brazilian municipalities
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674).
#'
#' @param year Numeric. Year of the data in YYYY format. Defaults to `2010`.
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
#'
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
read_municipality <- function(code_muni = "all",
                              year = 2010,
                              simplified = TRUE,
                              showProgress = TRUE,
                              cache = TRUE) {

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="municipality", year=year, simplified=simplified)

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

# BLOCK 2.1 From 1872 to 1991  ----------------------------

  if( year < 1992){

    # First download the data
      # list paths of files to download
      file_url <- as.character(temp_meta$download_path)

      # download gpkg
      temp_sf <- download_gpkg(file_url = file_url,
                               showProgress = showProgress,
                               cache = cache)

      # check if download failed
      if (is.null(temp_sf)) { return(invisible(NULL)) }

    # if code_muni=="all", simply return the full data set
      if( is.null(code_muni) | code_muni=="all"){
        return(temp_sf)
        }

    # if input is a state code
      else if(nchar(code_muni)==2){

      # invalid state code
      if( !(code_muni %in% substr(temp_sf$code_muni,1,2)) & !(code_muni %in% temp_sf$abbrev_state)){
        stop("Error: Invalid value to argument code_muni")}

        else if (is.numeric(code_muni)){
          x <- code_muni
          temp_sf <- subset(temp_sf, substr(code_muni,1,2)==x)
          return(temp_sf)}

        else if (is.character(code_muni)){
          x <- code_muni
          temp_sf <- subset(temp_sf, substr(abbrev_state,1,2)==x)
          return(temp_sf)}
        }


  # if input is a muni_code
      else if(nchar(code_muni)==7) {

    # invalid muni_code

      if( !( code_muni %in% temp_sf$code_muni)){
        stop("Error: Invalid value to argument code_muni")}

    # valid muni_code
        else {
            x <- code_muni
            temp_sf <- subset(temp_sf, code_muni==x)
            return(temp_sf)}
      }

      else if(nchar(code_muni)!=7 | nchar(code_muni)!=2) {
        stop("Error: Invalid value to argument code_muni")}

        } else {


# BLOCK 2.2 From 2000 onwards  ----------------------------

# 2.2 Verify code_muni Input

  # if code_muni=="all", read the entire country
    if(code_muni=="all"){

      # list paths of files to download
      file_url <- as.character(temp_meta$download_path)

      # download files
      temp_sf <- download_gpkg(file_url = file_url,
                               showProgress = showProgress,
                               cache = cache)

      # check if download failed
      if (is.null(temp_sf)) { return(invisible(NULL)) }

      return(temp_sf)
    }

  else if( !(substr(x = code_muni, 1, 2) %in% temp_meta$code) & !(substr(x = code_muni, 1, 2) %in% temp_meta$code_abbrev)){

      stop("Error: Invalid Value to argument code_muni.")

  } else{

    # list paths of files to download
    if (is.numeric(code_muni)){ file_url <- as.character(subset(temp_meta, code==substr(code_muni, 1, 2))$download_path) }
    if (is.character(code_muni)){ file_url <- as.character(subset(temp_meta, code_abbrev==substr(code_muni, 1, 2))$download_path) }

    # download files
    sf <- download_gpkg(file_url = file_url,
                             showProgress = showProgress,
                             cache = cache)

    # check if download failed
    if (is.null(sf)) { return(invisible(NULL)) }

    # input is a state code
    if(nchar(code_muni)==2){
      sf <- subset(sf, code_state==substr(code_muni, 1, 2))
        return(sf) }

    # input is a municipality code
    else if(code_muni %in% sf$code_muni){
          x <- code_muni
          sf <- subset(sf, code_muni==x)
          return(sf)
      } else{
          stop("Error: Invalid Value to argument code_muni.")
      }
    }
    }
  }

