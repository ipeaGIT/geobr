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
                                  cache = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography="immediateregions",
    year=year,
    simplified=simplified
  )

  # check if metadata download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # download files
  file_path <- download_piggyback(
    filename_to_download = temp_meta$file_name,
    showProgress,
    cache
  )

  # check if download failed
  if (is.null(file_path)) { return(invisible(NULL)) }

  # open arrow dataset
  temp_arrw <- arrow::open_dataset(file_path)

  # codes of all regions
  all_code <- temp_arrw |> dplyr::pull(cd_rgi, as_vector = TRUE)

  ## FILTERS
  y <- code_immediate

  # check code_immediate input
  if(code_immediate=="all"){

    # abbrev_state
  } else if(code_immediate %in% geobr_env$all_abbrev_state){
    temp_arrw <- dplyr::filter(temp_arrw, abbrev_state == y) |>
      dplyr::compute()

    # code_state
  } else if(code_immediate %in% geobr_env$all_code_state){
    temp_arrw <- dplyr::filter(temp_arrw, code_state == y) |>
      dplyr::compute()

    # code_immediate
  } else if(code_immediate %in% all_code){
    temp_arrw <- dplyr::filter(temp_arrw, code_immediate == y) |>
      dplyr::compute()

  } else {stop(paste0("Error: Invalid Value to argument 'code_immediate'",collapse = " "))}

  # convert to sf
  if(isTRUE(as_sf)){
    temp_arrw <- sf::st_as_sf(temp_arrw)
  }

  return(temp_arrw)
}
