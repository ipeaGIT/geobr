#' Download shape file of Brazil Regions as sf objects.
#'
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @param year Year of the data (defaults to 2010)
#' @param tp Whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Default)
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read specific year
#'   reg <- read_region(year=2018)
#'
#'}

read_region <- function(year=NULL, tp="simplified"){

  # Get metadata with data addresses
  metadata <- download_metadata()

  # Select geo
  temp_meta <- subset(metadata, geo=="regions")

  # Select type
  if(tp=="original"){
    temp_meta <- temp_meta[  !(grepl(pattern="simplified", temp_meta$download_path)), ]
  } else {
    temp_meta <- temp_meta[  grepl(pattern="simplified", temp_meta$download_path), ]
  }

  # Verify year input
  if (is.null(year)){ message("Using data from year 2010\n")
    temp_meta <- subset(temp_meta, year==2010)

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
  temp_sf <- sf::st_read(temps, quiet=T)

  return(temp_sf)
}


