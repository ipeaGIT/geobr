#' Download spatial data of Brazil's Legal Amazon
#'
#' @description
#' This data set covers the whole of Brazil's Legal Amazon as defined in the
#' federal law n. 12.651/2012). The original data comes from the Brazilian
#' Ministry of Environment (MMA) and can be found at "http://mapas.mma.gov.br/i3geo/datadownload.htm".
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
#' # Read Brazilian Legal Amazon
#' a <- read_amazon(year = 2012)
#'
read_amazon <- function(year = NULL,
                        simplified = TRUE,
                        showProgress = TRUE,
                        cache = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="amazonia_legal", year=year, simplified=simplified)

  # # check if download failed
  # if (is.null(temp_meta)) { return(invisible(NULL)) }

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
