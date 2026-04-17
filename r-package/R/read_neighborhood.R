#' Download spatial data of neighborhood limits of Brazilian municipalities
#'
#' @description
#' This data set includes the neighborhood limits of Brazilian municipalities.
#' The data is only available for those municipalities where neighborhood
#' information was collected in the population census. The data set is based on
#' aggregations of the census tracts from the Brazilian census.
#'
#' @template year
#' @param code_muni The 7-digit identification code of a municipality. If
#'        `code_muni = "all"` (Default), the function downloads all the
#'        neighborhoods data available in the country. Alternatively, if a
#'        two-digit identification code or a two-letter uppercase abbreviation of
#'        a state is passed (e.g. `33` or `"RJ"`), all neighborhoods data of that
#'        state are downloaded. Municipality identification codes can be consulted
#'        with the `geobr::lookup_muni()` function.
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
#' # Read neighborhoods of Brazilian municipalities
#' n <- read_neighborhood(year = 2022)
#'
read_neighborhood <- function(year = NULL,
                              code_muni = "all",
                              simplified = TRUE,
                              as_sf = TRUE,
                              showProgress = TRUE,
                              cache = TRUE,
                              verbose = TRUE){

  # Get metadata
  temp_meta <- select_metadata(
    geography="neighborhood",
    year = year,
    simplified = simplified,
    verbose = verbose
  )

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # download file and open arrow dataset
  temp_arrw <- download_parquet(
    filename_to_download = temp_meta$file_name,
    showProgress = showProgress,
    cache = cache
  )

  # check if download failed
  if (is.null(temp_arrw)) { return(invisible(NULL)) }

  # FILTER
  temp_arrw <- filter_arrw(temp_arrw, code = code_muni)

  # convert to sf
  if(isTRUE(as_sf)){
    temp_arrw <- sf::st_as_sf(temp_arrw)
  }

  return(temp_arrw)
}
