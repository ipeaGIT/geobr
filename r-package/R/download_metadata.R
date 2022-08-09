#' Support function to download metadata internally used in geobr
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' df <- download_metadata()
#' }}
download_metadata <- function(){ # nocov start

    # create tempfile to save metadata
    tempf <- file.path(tempdir(), "metadata_gpkg.csv")

    # IF metadata has already been successfully downloaded
    if (file.exists(tempf) & file.info(tempf)$size != 0) {

    } else {

      # test server connection
      metadata_link <- 'https://www.ipea.gov.br/geobr/metadata/metadata_gpkg.csv'
      check_con <- check_connection(metadata_link)
      if(is.null(check_con) | isFALSE(check_con)){ return(invisible(NULL)) }

      # download metadata to temp file
      httr::GET(url= metadata_link, httr::write_disk(tempf, overwrite = TRUE))
    }

    # read metadata
    # metadata <- data.table::fread(tempf, stringsAsFactors=FALSE)
    metadata <- utils::read.csv(tempf, stringsAsFactors=FALSE)

    return(metadata)
}



 # nocov end
