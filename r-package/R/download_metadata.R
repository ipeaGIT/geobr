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

  # create tempfile to save metadata
  tempf <- file.path(tempdir(), "metadata.csv")

  # check if metadata has already been downloaded
  if (file.exists(tempf)) {
    metadata <- utils::read.csv(tempf, stringsAsFactors=F)

  } else {

    # test server connection
    metadata_link <- 'http://www.ipea.gov.br/geobr/metadata/metadata_gpkg.csv'
    t <- try( open.connection(con = url(metadata_link), open="rt", timeout=2),silent=T)
    if("try-error" %in% class(t)){stop('Internet connection problem. If this is
                                       not a connection problem in your network,
                                       please try geobr again in a few minutes.')}

    suppressWarnings(try(close.connection(conn),silent=T))

    # download it and save to metadata
    httr::GET(url= metadata_link, httr::write_disk(tempf, overwrite = T))
    metadata <- utils::read.csv(tempf, stringsAsFactors=F)
  }

  return(metadata)
  }
