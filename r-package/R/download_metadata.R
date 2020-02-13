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
  tempf <- file.path(tempdir(), "metadata.rds")

  # check if metadata has already been downloaded
  if (file.exists(tempf)) {
    metadata <- readr::read_rds(tempf)

  } else {
    # download it and save to metadata
    httr::GET(url="http://www.ipea.gov.br/geobr/metadata/metadata.rds", httr::write_disk(tempf, overwrite = T))
    metadata <- readr::read_rds(tempf)
  }

  return(metadata)
}
