#' Download geolocated data of health facilities as an sf object.
#'
#' Data comes from the National Registry of Healthcare facilities (Cadastro Nacional de Estabelecimentos de Saúde - CNES),
#' originally collected by the Brazilian Ministry of Health. The date of the last data update is
#' registered in the database in the columns ‘date_update’ and ‘year_update’. These data uses Geodetic reference
#' system "SIRGAS2000" and CRS(4674). The coordinates of each facility was obtained by CNES
#' and validated by means of space operations. These operations verify if the point is in the
#' municipality, considering a radius of 5,000 meters. When the coordinate is not correct,
#' further searches are done in other systems of the Ministry of Health and in web services
#' like Google Maps . Finally, if the coordinates have been correctly obtained in this process,
#' the coordinates of the municipal head office are used. The final source used is registered
#' in the database in a specific column ‘data_source’. Periodically the coordinates are revised
#' with the objective of improving the quality of the data. More information
#' available at http://dados.gov.br/dataset/cnes
#'
#' @export
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read all health facilities of the whole country
#'   h <- read_health_facilities()
#'
#' }
#'

read_health_facilities <- function(){

  # Get metadata with data addresses
  metadata <- download_metadata()


  # Select geo
  temp_meta <- subset(metadata, geo=="health_facilities")


  # list paths of files to download
    filesD <- as.character(temp_meta$download_path)

    # download files
    temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))


  # read sf
    temp_sf <- readr::read_rds(temps)
    return(temp_sf)

    }
