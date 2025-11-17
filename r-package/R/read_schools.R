#' Download geolocated data of schools
#'
#' @description
#' Data comes from the School Census collected by INEP, the National Institute
#' for Educational Studies and Research Anisio Teixeira. The date of the last
#' data update is registered in the database in the column 'date_update'. These
#' data uses Geodetic reference system "SIRGAS2000" and CRS(4674). The coordinates
#' of each school if collected by INEP. Periodically the coordinates are revised
#' with the objective of improving the quality of the data. More information
#' available at \url{https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/inep-data/catalogo-de-escolas/}
#'
#' @template year
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
#' # Read all schools in the country
#' s <- read_schools( year = 2020)
#'
read_schools <- function(year = NULL,
                         showProgress = TRUE,
                         cache = TRUE,
                         verbose = TRUE){

  # Get metadata
  temp_meta <- select_metadata(
    geography="schools",
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
  if(isTRUE(as_sf)){
    temp_arrw <- sf::st_as_sf(temp_arrw)
  }

  return(temp_arrw)
}
