#' Download spatial data of the Brazilian Semiarid region
#'
#' @description
#' This data set covers the whole of Brazilian Semiarid as defined in the resolution
#' in  23/11/2017). The original data comes from the Brazilian Institute of Geography
#' and Statistics (IBGE) and can be found at \url{https://www.ibge.gov.br/geociencias/cartas-e-mapas/mapas-regionais/15974-semiarido-brasileiro.html?=&t=downloads}
#'
#' @param year Numeric. Year of the data in YYYY format. Defaults to `2017`.
#' @template simplified
#' @template showProgress
#'
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read Brazilian semiarid
#' a <- read_semiarid(year=2017)
#'
read_semiarid <- function(year=2017, simplified=TRUE, showProgress=TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="semiarid", year=year, simplified=simplified)

  #list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url, progress_bar = showProgress)

  # check if download failed
  if (is.null(temp_sf)) { return(invisible(NULL)) }

  return(temp_sf)

}
