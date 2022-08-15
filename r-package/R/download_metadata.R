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

      # test server connection with github
      metadata_link <- 'https://www.ipea.gov.br/geobr/metadata/metadata_1.7.0_gpkg.csv'

      check_con <- check_connection(metadata_link, silent = TRUE)

      # if connection with github fails, try connection with ipea
      if(is.null(check_con) | isFALSE(check_con)){
        metadata_link <- 'https://github.com/ipeaGIT/geobr/releases/download/v1.7.0/metadata_1.7.0_gpkg.csv'
        check_con <- check_connection(metadata_link)

        if(is.null(check_con) | isFALSE(check_con)){ return(invisible(NULL)) }
      }

      # download metadata to temp file
      httr::GET(url= metadata_link, httr::write_disk(tempf, overwrite = TRUE))
    }


    # read metadata
    # metadata <- data.table::fread(tempf, stringsAsFactors=FALSE)
    metadata <- utils::read.csv(tempf, stringsAsFactors=FALSE)

    return(metadata)
}



 # nocov end
