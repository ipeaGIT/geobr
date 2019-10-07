#' test function
#'
#' Testintg function
#'
#' @export
#'
download_fun <- function(x) {
  # Get data
  tempf <- file.path(tempdir(), "41ME.rds")

  # check if data has already been downloaded
  if (file.exists(tempf)) {
    temp_sf <- readr::read_rds(tempf)

  } else {

    # download data
    httr::GET(url="http://www.ipea.gov.br/geobr/data/meso_regiao/2014/41ME.rds", httr::write_disk(tempf, overwrite = T))
    temp_sf <- readr::read_rds(tempf)
  }

  t <- min(temp_sf$code_meso) + x
  return(t)

}



