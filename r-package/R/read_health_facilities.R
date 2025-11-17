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
#' `year_update`. More information in the CNES data set available at \url{https://dados.gov.br/}.
#' These data use Geodetic reference system "SIRGAS2000" and CRS(4674).
#'
#' @template date
#' @template as_sf
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
#' # Read all health facilities of the whole country
#' h <- read_health_facilities( date = 202303)
#'
read_health_facilities <- function(date = NULL,
                                   as_sf = TRUE,
                                   showProgress = TRUE,
                                   cache = TRUE,
                                   verbose = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="health_facilities", year=date, simplified=F)

  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography="healthfacilities",
    year = year,
    simplified = FALSE
  )

  # download files
  file_path <- download_piggyback(
    filename_to_download = temp_meta$file_name,
    showProgress = showProgress,
    cache = cache
  )

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
