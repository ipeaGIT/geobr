#' Support function to download metadata internally used in geobr
#'
#' @export
#' @family general support functions
#' @examples \dontrun{ if (interactive()) {
#' df <- download_metadata()
#' }}
download_metadata <- function(){ # nocov start

  # create tempfile to save metadata
  tempf <- file.path(tempdir(), "metadata_geobr.csv")

  # IF metadata has already been downloaded
  if (file.exists(tempf)) {

    # skip

  } else {

    # test server connection
    metadata_link <- 'https://www.ipea.gov.br/geobr/metadata/metadata_gpkg.csv'
    check_connection(metadata_link)

    # download metadata to temp file
    try( httr::GET(url= metadata_link, httr::write_disk(tempf, overwrite = T)), silent = T)

    }

  # read/return metadata
  metadata <- utils::read.csv(tempf, stringsAsFactors=FALSE)
  return(metadata)
  } # nocov end
