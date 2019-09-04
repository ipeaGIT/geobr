#' Download official data of indigenous lands as an sf object.
#'
#' The data set covers the whole of Brazil and it includes indigenous lands from all ethnicities and
#' in different stages of demarcation. The original data comes from the National Indian Foundation (FUNAI)
#' and can be found at http://www.funai.gov.br/index.php/shape. Although original data is updated monthly,
#' the geobr package will only keep the data for a few months per year.
#'
#'
#' @param date A date numer in YYYYMM format.
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

read_indigenous_land <- function(date){


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
  temp_meta <- subset(metadata, geo=="indigenous_land")



# Verify date input
  if(is.null(date)){ stop(paste0("Error: Invalid Value to argument 'date'. It must be one of the following: ",
                                 paste(unique(temp_meta$year),collapse = " ")))

  } else if (date %in% temp_ano$year){ temp_ano <- temp_ano[temp_ano[,2] == year, ]

  } else { stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                       paste(unique(temp_ano$year),collapse = " ")))
  }


# list paths of files to download
  filesD <- as.character(temp_ano$download_path)

# download files
  temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
  httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))

# read sf
  temp_sf <- readr::read_rds(temps)
  return(temp_sf)
}
