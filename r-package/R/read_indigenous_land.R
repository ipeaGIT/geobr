#' Download spatial data of indigenous lands in Brazil
#'
#' @description
#' The data set covers the whole of Brazil and it includes indigenous lands from
#' all ethnicities and in different stages of demarcation. The original data
#' comes from the National Indian Foundation (FUNAI) and can be found at
#' \url{http://www.funai.gov.br/index.php/shape}. Although original data is
#' updated monthly, the geobr package will only keep the data for a few months
#' per year.
#'
#' @param date Numeric. Date of the data in YYYYMM format. Defaults to `201907`.
#' @template simplified
#' @template showProgress
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read all indigenous land in an specific date
#' i <- read_indigenous_land(date=201907)
#'
read_indigenous_land <- function(date=201907, simplified=TRUE, showProgress=TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="indigenous_land", year=date, simplified=simplified)

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url, showProgress = showProgress)

  # check if download failed
  if (is.null(temp_sf)) { return(invisible(NULL)) }

  return(temp_sf)
}
