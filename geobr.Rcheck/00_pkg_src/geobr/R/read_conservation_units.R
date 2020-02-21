#' Download official data of Brazilian conservation untis as an sf object.
#'
#' This data set covers the whole of Brazil and it includes the polygons of all conservation untis present in Brazilian
#' territory. The last update of the data was 09-2019. The original
#' data comes from MMA and can be found at http://mapas.mma.gov.br/i3geo/datadownload.htm .
#'
#' @param date A date number in YYYYMM format
#' @param tp Whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Default)
#' @param showProgress Logical. Defaults to (TRUE) display progress bar
#'
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read conservation_units
#'   b <- read_conservation_units(date=201909)
#'}
read_conservation_units <- function(date=NULL, tp="simplified", showProgress=TRUE){

  # Get metadata with data addresses
  temp_meta <- download_metadata(geography="conservation_units", data_type=tp)


  # 1.1 Verify year input
  if (is.null(date)){ date <- 201909
                      message(paste0("Using data from year ", date))
                      }

  if(!(date %in% temp_meta$year)){ stop(paste0("Error: Invalid Value to argument 'date'. It must be one of the following: ",
                                               paste(unique(temp_meta$year),collapse = " ")))
  }

  # # Select metadata year
  # x <- year
  # temp_meta <- subset(temp_meta, year==x)

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
  return(temp_sf)
}
