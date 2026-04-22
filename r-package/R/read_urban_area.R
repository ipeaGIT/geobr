#' Download spatial data of urbanized areas in Brazil
#'
#' @description
#' This function reads the official data on the urban footprint of Brazilian
#' cities. Original data by the Brazilian Institute of Geography and Statistics
#' (IBGE)  For more information about the methodology, see details
#' at \url{https://biblioteca.ibge.gov.br/visualizacao/livros/liv100639.pdf}
#'
#' @template year
#' @param code_muni The 7-digit identification code of a municipality. If
#'        `code_muni = "all"` (Default), the function downloads all the urban
#'        footprints data available in the country. Alternatively, if a
#'        two-digit identification code or a two-letter uppercase abbreviation of
#'        a state is passed (e.g. `33` or `"RJ"`), all urban footprints of that
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
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read urban footprint of Brazilian cities in an specific year
#' d <- read_urban_area(year = 2015)
#'
read_urban_area <- function(year,
                            code_muni = "all",
                            simplified = TRUE,
                            as_sf = TRUE,
                            showProgress = TRUE,
                            cache = TRUE,
                            verbose = TRUE){

  # Get metadata
  temp_meta <- select_metadata(
    geography="urbanareas",
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
  output <- convert_arrow2sf(temp_arrw, as_sf)

  return(output)

}
