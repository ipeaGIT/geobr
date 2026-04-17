#' Download spatial data of Brazilian municipalities
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674).
#'
#' @template year
#' @param code_muni The 7-digit identification code of a municipality. If
#'        `code_muni = "all"` (Default), the function downloads all
#'        municipalities of the country. Alternatively, if a two-digit
#'        identification code or a two-letter uppercase abbreviation of a state
#'        is passed (e.g. `33` or `"RJ"`), all municipalities of that state will
#'        be downloaded. Municipality identification codes can be consulted with
#'        the `geobr::lookup_muni()` function.
#' @template simplified
#' @template as_sf
#' @template showProgress
#' @template cache
#' @template verbose
#' @param keep_areas_operacionais Logic. Whether the function should keep the
#'        polygons of Lagoas dos Patos and Lagoa Mirim in the State of Rio Grande
#'        do Sul (considered as areas estaduais operacionais). Defaults to `FALSE`.
#'
#' @return An `"sf" "data.frame"` OR an `ArrowObject`
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
read_municipality <- function(year,
                              code_muni = "all",
                              simplified = TRUE,
                              as_sf = TRUE,
                              showProgress = TRUE,
                              cache = TRUE,
                              verbose = TRUE,
                              keep_areas_operacionais = FALSE) {

  # check input
  if (!is.logical(keep_areas_operacionais)) { stop("'keep_areas_operacionais' must be of type 'logical'") }


  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography="municipalities",
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
  temp_arrw <- filter_arrw(temp_arrw, code = code_muni)

  # keep_areas_operacionais
  if (isFALSE(keep_areas_operacionais)) {
    temp_arrw <- temp_arrw |>
      dplyr::filter(code_muni != 4300001) |>
      dplyr::filter(code_muni != 4300002) |>
      dplyr::compute()
    }

  # convert to sf
  output <- convert_arrow2sf(temp_arrw, as_sf)

  return(output)

}



