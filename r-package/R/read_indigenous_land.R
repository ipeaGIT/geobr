#' Download spatial data of indigenous lands in Brazil
#'
#' @description
#' The data set covers the whole of Brazil and it includes indigenous lands from
#' all ethnic groups and at different stages of demarcation. The original data
#' comes from the National Indian Foundation (FUNAI) and can be found at
#' \url{https://www.gov.br/funai/pt-br/atuacao/terras-indigenas/geoprocessamento-e-mapas}. Although original data is
#' updated monthly, the geobr package will only keep the data for a few months
#' per year.
#'
#' @template year
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
#' # Read all indigenous land in an specific year
#' i <- read_indigenous_land(year = 2025)
#'
read_indigenous_land <- function(year,
                                 simplified = TRUE,
                                 as_sf = TRUE,
                                 showProgress = TRUE,
                                 cache = TRUE,
                                 verbose = TRUE){

  # Get metadata
  temp_meta <- select_metadata(
    geography="indigenouslands",
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

  # convert to sf
  output <- convert_arrow2sf(temp_arrw, as_sf)

  return(output)

}
