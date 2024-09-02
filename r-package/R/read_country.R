#' Download spatial data of Brazil's national borders
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674).
#'
#' @param year Numeric. Year of the data in YYYY format. Defaults to `2010`.
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
#' # Read specific year
#' br <- read_country(year = 2018)
#'
read_country <- function(year = 2010,
                         simplified = TRUE,
                         showProgress = TRUE,
                         cache = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="country", year=year, simplified=simplified)

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
