#' Download spatial data of the Brazilian Semiarid region
#'
#' @description
#' This data set returns all the municipalities which are legally included in the
#' Brazilian Semiarid, following changes in the national legislation. The original
#' data comes from the Brazilian Institute of Geography and Statistics (IBGE)
#' and can be found at \url{https://www.ibge.gov.br/geociencias/cartas-e-mapas/mapas-regionais/15974-semiarido-brasileiro.html?=&t=downloads}
#'
#' @template year
#' @template simplified
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
#' # read Brazilian semiarid
#' sa <- read_semiarid(year = 2022)
#'
read_semiarid <- function(year,
                          simplified = TRUE,
                          output = "sf",
                          showProgress = TRUE,
                          cache = TRUE,
                          verbose = TRUE){

  # Get metadata
  temp_meta <- select_metadata(
    geography="semiarid",
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
  temp <- convert_arrow2sf(temp_arrw, output)

  return(temp)

}
