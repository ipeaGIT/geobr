#' Download geolocated data of health facilities
#'
#' @description
#' Data comes from the National Registry of Healthcare facilities (Cadastro
#' Nacional de Estabelecimentos de Saude - CNES), originally collected by the
#' Brazilian Ministry of Health. According to the Ministry of Health: "The
#' coordinates of each facility were obtained by CNES and validated by means of
#' space operations. These operations verify if the point is in the municipality,
#' considering a radius of 5,000 meters. When the coordinate is not correct,
#' further searches are done in other systems of the Ministry of Health and in
#' web services like Google Maps. Finally, if the coordinates have been correctly
#' obtained in this process, the coordinates of the municipal head office are
#' used. The geocode source used is registered in the database in a specific
#' column `data_source`. Periodically the coordinates are revised with the
#' objective of improving the quality of the data." The date of the last data
#' update is registered in the database in the columns `date_update` and
#' `year_update`. More information available at \url{https://dados.gov.br/dataset?q=CNES}.
#' These data use Geodetic reference system "SIRGAS2000" and CRS(4674).
#'
#' @param showProgress Logical. Defaults to `TRUE` display progress bar
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @examples \dontrun{ if (interactive()) {
#' # Read all health facilities of the whole country
#' h <- read_health_facilities()
#' }}
read_health_facilities <- function( showProgress=TRUE ){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="health_facilities", year=2015, simplified=F)

  # list paths of files to download
    file_url <- as.character(temp_meta$download_path)

  # download files
    temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
    return(temp_sf)

    }
