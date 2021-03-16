#' Support function to download metadata internally used in geobr
#'
#' @export
#' @family general support functions
#' @examples \donttest{
#' df <- download_metadata()
#' }
download_metadata <- function(){

  # create tempfile to save metadata
  tempf <- file.path(tempdir(), "metadata.csv")

  # check if metadata has already been downloaded
  if (file.exists(tempf)) {
    metadata <- utils::read.csv(tempf, stringsAsFactors=F)

  } else {

    #supress warnings
    oldw <- getOption("warn")
    options(warn = -1)

    # test server connection
    metadata_link <- 'http://www.ipea.gov.br/geobr/metadata/metadata_gpkg.csv'
    con <- url(metadata_link)
    t <- suppressWarnings({ try( open.connection(con, open="rt", timeout=2), silent=T)[1] })
    if(t %like% "Error in open.connection"){stop('Internet connection problem. If this is not a connection problem in your network, please try geobr again in a few minutes.')}
    suppressWarnings({ try(close.connection(con), silent=T) })

    # return with warnings
    options(warn = oldw)

    # download it and save to metadata
    httr::GET(url= metadata_link, httr::write_disk(tempf, overwrite = T))
    metadata <- utils::read.csv(tempf, stringsAsFactors=F)

    }


  return(metadata)
  }
