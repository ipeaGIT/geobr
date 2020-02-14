#' Download official data of Brazil's Legal Amazon as an sf object.
#'
#' This data set covers the whole of Brazil's Legal Amazon as defined in the federal law n. 12.651/2012). The original
#' data comes from the Brazilian Ministry of Environment (MMA) and can be found at http://mapas.mma.gov.br/i3geo/datadownload.htm .
#'
#' @param year A date number in YYYY format (defaults to 2012)
#' @param mode Whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Default)
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read Brazilian Legal Amazon
#'   a <- read_amazon(year=2012)
#'}
#'
read_amazon <- function(year=NULL, mode="simplified"){

  # Get metadata with data addresses
  metadata <- download_metadata()


  # Select geo
  temp_meta <- subset(metadata, geo=="amazonia_legal")

  # Select mode
  if(mode=="original"){
    temp_meta <- temp_meta[  grepl(pattern="original", temp_meta$download_path), ]
    } else {
    temp_meta <- temp_meta[  grepl(pattern="simplified", temp_meta$download_path), ]
  }


  # 1.1 Verify year input
  if (is.null(year)){ year <- 2012}

  if(!(year %in% temp_meta$year)){ stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                                               paste(unique(temp_meta$year),collapse = " ")))
  }

  message(paste0("Using data from year ", year))



  # # Select metadata year
  # x <- year
  # temp_meta <- subset(temp_meta, year==x)

  # list paths of files to download
  filesD <- as.character(temp_meta$download_path)

  # download files
  temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
  httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))

  # read sf
  temp_sf <- sf::st_read(temps)
  return(temp_sf)
}
