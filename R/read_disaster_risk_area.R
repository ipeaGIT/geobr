#' Download official data of disaster risk areas as an sf object.
#'
#' This function reads the database calculated by IBGE and CEMADEN for all Brazil and return the code of the state,
#' code and name of county, polygon geocode of statistical territorial base of risk area (BATER), origin of the
#' census sector, accuracy (coincidence of the risk area in relation to the census area), observations considered
#' relevant in relation to delimitation of areas, number of risk areas included in the BATER polygon,states
#' abbreviation and the geometry. It specifically focuses on hydrometeorological disasters capable of triggering floods,
#' runoffs, and mass movements. For more information, visit: https://www.ibge.gov.br/geociencias/organizacao-do-territorio/tipologias-do-territorio/21538-populacao-em-areas-de-risco-no-brasil.html
#'
#' @param year A year number in YYYY format.
#' @export
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read all disaster risk areas in an specific year
#'   i <- read_disaster_risk_area(year=2018)
#'
#' }
#'
#'

read_disaster_risk_area <- function(year){

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
  temp_meta <- subset(metadata, geo=="disaster_risk_area")

  # Verify year input
  if(is.null(year)){ stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                                 paste(unique(temp_meta$year),collapse = " ")))

  } else if (year %in% temp_meta$year){ temp_meta <- temp_meta[temp_meta[,2] == year, ]

  } else { stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                       paste(unique(temp_meta$year),collapse = " ")))
  }


  # list paths of files to download
  filesD <- as.character(temp_meta$download_path)

  # download files
  temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
  httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))

  # read sf
  temp_sf <- readr::read_rds(temps)
  return(temp_sf)
}
