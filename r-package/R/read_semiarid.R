#' Download spatial data of the Brazilian Semiarid region
#'
#' @description
#' This data set covers the whole of Brazilian Semiarid as defined in the resolution
#' in  23/11/2017). The original data comes from the Brazilian Institute of Geography
#' and Statistics (IBGE) and can be found at \url{https://www.ibge.gov.br/geociencias/cartas-e-mapas/mapas-regionais/15974-semiarido-brasileiro.html?=&t=downloads}
#'
#' @template year
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
#' # read Brazilian semiarid
#' sa <- read_semiarid(year = 2022)
#'
read_semiarid <- function(year = NULL,
                          simplified = TRUE,
                          as_sf = TRUE,
                          showProgress = TRUE,
                          cache = TRUE){


  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography="semiarid",
    year = year,
    simplified = simplified
    )

  # download files
  file_path <- download_piggyback(temp_meta$file_name, showProgress, cache)

  # check if download failed
  if (is.null(file_path)) { return(invisible(NULL)) }

  # open arrow dataset
  temp_arrw <- arrow::open_dataset(file_path)

  # convert to sf
  if(isTRUE(as_sf)){
    temp_arrw <- sf::st_as_sf(temp_arrw)
  }

  return(temp_arrw)
}
