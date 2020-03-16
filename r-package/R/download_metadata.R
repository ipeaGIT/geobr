#' Support function to download metadata internally used in geobr
#'
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
download_metadata <- function(){

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

  return(metadata)
  }
