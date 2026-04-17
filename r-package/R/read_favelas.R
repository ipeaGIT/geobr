#' Download spatial data of favelas and urban communities
#'
#' @description
#' This function reads the official data on favelas and urban communities
#' (favelas e comunidades urbanas) of Brazil. Original data from the Institute
#' of Geography and Statistics (IBGE)  For more information about the methodology,
#' see details at \url{https://biblioteca.ibge.gov.br/visualizacao/livros/liv102134.pdf}
#'
#' @template year
#' @param code_muni The 7-digit identification code of a municipality. If
#'        `code_muni = "all"` (Default), the function downloads all the
#'        favelas data available in the country. Alternatively, if a
#'        two-digit identification code or a two-letter uppercase abbreviation
#'        of a state is passed (e.g. `33` or `"RJ"`), all favelas data of that
#'        state are downloaded. Municipality identification codes can be
#'        consulted with the `geobr::lookup_muni()` function.
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
#' # Read all favelas of Brazil
#' n <- read_favela(year = 2022)
#'
#' # Read all favelas of a given municipality
#' n <- read_favela(year = 2022, code_muni = 2927408)
#'
#' # Read all favelas of a given state
#' n <- read_favela(year = 2022, code_muni = "RJ")
#'
read_favela <- function(year = NULL,
                        code_muni = "all",
                        simplified = TRUE,
                        as_sf = TRUE,
                        showProgress = TRUE,
                        cache = TRUE,
                        verbose = TRUE){

  # Get metadata
  temp_meta <- select_metadata(
    geography="favelas",
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
