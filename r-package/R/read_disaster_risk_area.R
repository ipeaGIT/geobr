#' Download spatial data of disaster risk areas
#'
#' @description
#' This function reads the the official data of disaster risk areas in Brazil
#' (currently only available for 2010). It specifically focuses on geodynamic
#' and hydro-meteorological disasters capable of triggering landslides and floods.
#' The data set covers the whole country. Each risk area polygon (known as 'BATER')
#' has unique code id (column 'geo_bater'). The data set brings information on
#' the extent to which the risk area polygons overlap with census tracts and block
#' faces (column "acuracia") and number of ris areas within each risk area (column
#' 'num'). Original data were generated by IBGE and CEMADEN. For more information
#' about the methodology, see deails at \url{https://www.ibge.gov.br/geociencias/organizacao-do-territorio/tipologias-do-territorio/21538-populacao-em-areas-de-risco-no-brasil.html}
#'
#' @template year
#' @template simplified
#' @template showProgress
#' @template cache
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read all disaster risk areas in an specific year
#' d <- read_disaster_risk_area(year=2010)
#'
read_disaster_risk_area <- function(year = NULL,
                                    simplified = TRUE,
                                    showProgress = TRUE,
                                    cache = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="disaster_risk_area", year=year, simplified=simplified)

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url = file_url,
                           showProgress = showProgress,
                           cache = cache)

  # check if download failed
  if (is.null(temp_sf)) { return(invisible(NULL)) }

  return(temp_sf)
}
