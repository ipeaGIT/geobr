#' Download shape files of official metropolitan areas in Brazil as an sf object.
#'
#' The function returns the shapes of municipalities grouped by their respective metro areas.
#' Metropolitan areas are created by each state in Brazil. The data set includes the municipalities that belong to
#' all metropolitan areas in the country according to state legislation in each year. Orignal data were generated
#' by Institute of Geography. Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674).
#'
#'
#' @param year A year number in YYYY format
#' @param mode Whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Default)
#' @export
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read all official metropolitan areas for a given year
#'   m <- read_metro_area(2005)
#'
#'   m <- read_metro_area(2018)
#' }
#'
#'
#'
read_metro_area <- function(year, mode="simplified"){


  # Get metadata with data addresses
  metadata <- download_metadata()

  # Select geo
  temp_meta <- subset(metadata, geo=="metropolitan_area")

  # 1.1 Verify year input
  if (is.null(year)){  stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                                   paste(unique(temp_meta$year),collapse = " "))) }

  # 1.2 Verify year input
  if (year %in% temp_meta$year){ message(paste0("Using year ",year))
    temp_meta <- temp_meta[temp_meta[,2] == year,]
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
