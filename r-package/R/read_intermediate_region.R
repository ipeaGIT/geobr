#' Download spatial data of Brazil's Intermediate Geographic Areas
#'
#' @description
#' The intermediate Geographic Areas are part of the geographic division of
#' Brazil created in 2017 by IBGE. These regions were created to replace the
#' "Meso Regions" division. Data at scale 1:250,000, using Geodetic reference
#' system "SIRGAS2000" and CRS(4674)
#'
#' @template year
#' @param code_intermediate 4-digit code of an intermediate region. If the
#'        two-digit code or a two-letter uppercase abbreviation of a state is
#'        passed, (e.g. 33 or "RJ") the function will load all intermediate
#'        regions of that state. If `code_intermediate="all"` (Default), the
#'        function downloads all intermediate regions of the country.
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
read_intermediate_region <- function(year = NULL,
                                     code_intermediate = "all",
                                     simplified = TRUE,
                                     as_sf = TRUE,
                                     showProgress = TRUE,
                                     cache = TRUE,
                                     verbose = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography="immediateregions",
    year = year,
    simplified = simplified,
    verbose = verbose
  )

  # check if metadata download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # download files
  temp_arrw <- download_parquet(
    filename_to_download = temp_meta$file_name,
    showProgress,
    cache
  )

  # check if download failed
  if (is.null(temp_arrw)) { return(invisible(NULL)) }

  # FILTER
  temp_arrw <- filter_arrw(temp_arrw, code = code_intermediate)

  # convert to sf
  if(isTRUE(as_sf)){
    temp_arrw <- sf::st_as_sf(temp_arrw)
  }

  return(temp_arrw)

}
