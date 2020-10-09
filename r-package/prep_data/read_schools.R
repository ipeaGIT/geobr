#' Download geolocated data of schools as an sf object.
#'
#' Data comes from the School Census collected by INEP, the National Institute
#' for Educational Studies and Research "Anísio Teixeira".
#'
#' The date of the last data update is
#' registered in the database in the columns 'date_update' and 'year_update'. These data uses Geodetic reference
#' system "SIRGAS2000" and CRS(4674). The coordinates of each facility was obtained by CNES
#' and validated by means of space operations. These operations verify if the point is in the
#' municipality, considering a radius of 5,000 meters. When the coordinate is not correct,
#' further searches are done in other systems of the Ministry of Health and in web services
#' like Google Maps . Finally, if the coordinates have been correctly obtained in this process,
#' the coordinates of the municipal head office are used. The final source used is registered
#' in the database in a specific column 'data_source'. Periodically the coordinates are revised
#' with the objective of improving the quality of the data. More information
#' available at http://dados.gov.br/dataset/cnes
#'
#' @param showProgress Logical. Defaults to (TRUE) display progress bar
#'
#' @export
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read all schools in the country
#'   s <- read_schools()
#'
#' }
#'

read_schools <- function( showProgress=TRUE ){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="schools", year=2020, simplified=F)

  # list paths of files to download
    file_url <- as.character(temp_meta$download_path)

  # download files
    temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
    return(temp_sf)

    }
