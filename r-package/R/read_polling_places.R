#' Download geolocated data of polling places
#'
#' @description
#' Data comes from the Superior Electoral Court (TSE).
#' The spatial coordinates used in geobr are a combination of the coordinates
#' produced by the original data producer and the coordinates found via geocoding
#' with the geocodebr package \url{https://CRAN.R-project.org/package=geocodebr}.
#' Whenever the distance between the coordinates from both sources is smaller than
#' 800 meters, geobr uses coordinates from the data producer. When the distance
#' between the two sources is greater than 800 meters and the results from
#' geocodebr have a precision level finer than 800 meters, geobr uses the
#' coordinates from geocodebr. When the coordinates from the original source are
#' missing, geobr also uses geocodebr coordinates, regardless of precision level.
#' The source of the spatial coordinates used in each observation is registered
#' in the data in a specific column `coords_source`. Additional columns
#' indicating the precision level of geocodebr geocoding are also included in
#' the data.
#'
#' @template year
#' @template code_muni
#' @template output
#' @template showProgress
#' @template cache
#' @template verbose
#'
#' @return An `"sf" "data.frame"` OR an `ArrowObject`
#'
#' @export
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read health facilities of a given municipality
#' h <- read_polling_places(
#'   year = 2022,
#'   code_muni = 2800308
#'   )
#'
#' # Read health facilities of a given state
#' h <- read_polling_places(
#'   year = 2022,
#'   code_muni = "SE"
#'   )
#'
#' # Read all health facilities of the whole country
#' h <- read_polling_places(year = 2022)
#'
read_polling_places <- function(year,
                                code_muni = "all",
                                output = "sf",
                                showProgress = TRUE,
                                cache = TRUE,
                                verbose = TRUE){

  # Get metadata
  temp_meta <- select_metadata(
    geography="pollingplaces",
    year = year,
    simplified = FALSE,
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
  temp <- convert_output(temp_arrw, output)

  return(temp)

}
