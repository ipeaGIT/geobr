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
#' @param code The 7-digit code of a municipality. If the two-digit code or a two-letter
#' abbreviation of a state is passed, (e.g. 33 or "RJ") the function will load all healthcare
#' facilities of that state. If code="all", all facilities of the country are loaded.
#' @export
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read the health facilities of state 11
#'   h <- read_health_facilities(code=11)
#'
#' # Read the health facilities of state "AM"
#'   h <- read_health_facilities(code="AM")
#'
#' # Read all health facilities of the country
#'   h <- read_health_facilities(code="all")
#'
#' }
#'

read_health_facilities <- function(code){


# Test if code input is null
  if(is.null(code)){ stop("Value to argument 'code' cannot be NULL") }


  # Get metadata with data addresses
  tempf <- file.path(tempdir(), "metadata.rds")

  # check if metadata has already been downloaded
  if (file.exists(tempf)) {
    metadata <- readr::read_rds(tempf)

  } else {
    # download it and save to metadata
    httr::GET(url="http://www.ipea.gov.br/geobr/metadata/metadata.rds", httr::write_disk(tempf, overwrite = T))
    metadata <- readr::read_rds(tempf)
  }


  # Select geo
  temp_meta <- subset(metadata, geo=="health_facilities")


  # list paths of files to download
    filesD <- as.character(temp_meta$download_path)

    # download files
    temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))


  # read sf
    temp_sf <- readr::read_rds(temps)


  # Return the whole dataset if code==all
    if(code=="all"){ return(temp_sf) }


  # If user passed two-digit numeric code of a state
    if(nchar(code)==2 & is.numeric(code)){
                                            x <- code
                                            temp_sf <- subset(temp_sf, code_state==x)
                                            return(temp_sf)
                                          }


  # If user passed two-letter abbreviation of a state
    if(nchar(code)==2 & is.character(code)){
                                              x <- code
                                              temp_sf <- subset(temp_sf, abbrev_state== toupper(code))
                                              return(temp_sf)
                                            }


  # If user passed seven-digit numeric code of a municipality
    if(nchar(code)==7 & is.numeric(code)){
                                            x <- code
                                            temp_sf <- subset(temp_sf, code_muni==x)
                                            return(temp_sf)
                                          }

else{ stop("Error: Invalid Value to argument code_meso.") }
}
