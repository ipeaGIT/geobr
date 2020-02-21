#' Download official data of indigenous lands as an sf object.
#'
#' The data set covers the whole of Brazil and it includes indigenous lands from all ethnicities and
#' in different stages of demarcation. The original data comes from the National Indian Foundation (FUNAI)
#' and can be found at http://www.funai.gov.br/index.php/shape. Although original data is updated monthly,
#' the geobr package will only keep the data for a few months per year.
#'
#'
#' @param date A date numer in YYYYMM format (Defaults to 201907)
#' @param tp Whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Default)
#' @param showProgress Logical. Defaults to (TRUE) display progress bar
#'
#' @export
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read all indigenous land in an specific date
#'   i <- read_indigenous_land(date=201907)
#'
#' }
#'

read_indigenous_land <- function(date=201907, tp="simplified", showProgress=TRUE){


# Get metadata with data addresses
  temp_meta <- download_metadata(geography="indigenous_land", data_type=tp)


  # Test year input
  temp_meta <- test_year_input(temp_meta, y=date)


# list paths of files to download
  file_url <- as.character(temp_meta$download_path)

# download files
  temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
  return(temp_sf)
}
