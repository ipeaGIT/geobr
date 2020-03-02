#' Support function to download metadata internally used in geobr
#'
#' @param geography Which geography will be downloaded
#' @param data_type Data type (passed as 'simplified' from read_ functions)
#' @export
#' @family general support functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' df <- download_metadata()
#'
#' }
#'
download_metadata <- function(geography=NULL, data_type=TRUE){

  # Get metadata with data addresses
  tempf <- file.path(tempdir(), "metadata.csv")

  # check if metadata has already been downloaded
  if (file.exists(tempf)) {
    metadata <- utils::read.csv(tempf, stringsAsFactors=F)

  } else {
    # download it and save to metadata
    httr::GET(url="http://www.ipea.gov.br/geobr/metadata/metadata_gpkg.csv", httr::write_disk(tempf, overwrite = T))
    metadata <- utils::read.csv(tempf, stringsAsFactors=F)
  }


  # Select geo
  temp_meta <- subset(metadata, geo == geography)

  # Select data type
  temp_meta <- select_data_type(temp_meta, simplified=data_type)

  return(temp_meta)
  }
