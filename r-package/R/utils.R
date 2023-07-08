############# Support functions for geobr
# nocov start



#' Select data type: 'original' or 'simplified' (default)
#'
#'
#' @param temp_meta A dataframe with the file_url addresses of geobr datasets
#' @param simplified Logical TRUE or FALSE indicating  whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Defaults to TRUE)
#' @keywords internal
#'
select_data_type <- function(temp_meta, simplified=NULL){

  if (!is.logical(simplified)) { stop(paste0("Argument 'simplified' needs to be either TRUE or FALSE")) }

  if(isTRUE(simplified)){
    temp_meta <- temp_meta[  grepl(pattern="simplified", temp_meta$download_path), ]
  }

  if(isFALSE(simplified)){
    temp_meta <- temp_meta[  !(grepl(pattern="simplified", temp_meta$download_path)), ]
  }

  return(temp_meta)
}





#' Select year input
#'
#' @param temp_meta A dataframe with the file_url addresses of geobr datasets
#' @param y Year of the dataset (passed by red_ function)
#' @keywords internal
#'
select_year_input <- function(temp_meta, y=year){

  # NULL
  if (is.null(y)){  stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                                   paste(unique(temp_meta$year),collapse = " "))) }

  # invalid input
  else if (y %in% temp_meta$year){ message(paste0("Using year ", y))
                                  temp_meta <- subset(temp_meta, year == y)
                                  return(temp_meta) }

  # invalid input
  else { stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                         paste(unique(temp_meta$year), collapse = " ")))
    }
}


#' Select metadata
#'
#' @param geography Which geography will be downloaded.
#' @param simplified Logical TRUE or FALSE indicating  whether the function
#'        returns the 'original' dataset with high resolution or a dataset with
#'        'simplified' borders (Defaults to TRUE).
#' @param year Year of the dataset (passed by read_ function).
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#'
#' library(geobr)
#'
#' df <- download_metadata()
#'
#' }}
#'
select_metadata <- function(geography, year=NULL, simplified=NULL){

# download metadata
  metadata <- download_metadata()

  # check if download failed
  if (is.null(metadata)) { return(invisible(NULL)) }

  # Select geo
  temp_meta <- subset(metadata, geo == geography)

  # Select year input
  temp_meta <- select_year_input(temp_meta, y=year)

  # Select data type
  temp_meta <- select_data_type(temp_meta, simplified=simplified)

  return(temp_meta)
}


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
      check_con <- check_connection(metadata_link, silent = FALSE)

      if(is.null(check_con) | isFALSE(check_con)){ return(invisible(NULL)) }
    }

    # download metadata to temp file
    httr::GET(url= metadata_link, httr::write_disk(tempf, overwrite = TRUE))
  }

  # read metadata
  # metadata <- data.table::fread(tempf, stringsAsFactors=FALSE)
  metadata <- utils::read.csv(tempf, stringsAsFactors=FALSE)

  return(metadata)
} # nocov end



#' Download geopackage to tempdir
#'
#' @param file_url A string with the file_url address of a geobr dataset
#' @param progress_bar Logical. Defaults to (TRUE) display progress bar
#' @keywords internal
#'
download_gpkg <- function(file_url, progress_bar = showProgress){

  if (!is.logical(progress_bar)) { stop("'showProgress' must be of type 'logical'") }

  # get backup links
  filenames <- basename(file_url)
  file_url2 <- paste0('https://github.com/ipeaGIT/geobr/releases/download/v1.7.0/', filenames)


## one single file

  if (length(file_url)==1) {

    # location of temp_file
    temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(file_url,"/"),tail,n=1L)))

    # check if file has not been downloaded already. If not, download it
    if (!file.exists(temps) | file.info(temps)$size == 0) {

    # test connection with server1
    check_con <- check_connection(file_url[1], silent = TRUE)

    # if server1 fails, replace url and test connection with server2
    if (is.null(check_con) | isFALSE(check_con)) {
      message('using github')
      file_url <- file_url2
      check_con <- check_connection(file_url[1], silent = FALSE)
      if(is.null(check_con) | isFALSE(check_con)){ return(invisible(NULL)) }
    }

    # download data
    try( httr::GET(url=file_url,
                   if(isTRUE(progress_bar)){httr::progress()},
                   httr::write_disk(temps, overwrite = T),
                   config = httr::config(ssl_verifypeer = FALSE)
                   ), silent = TRUE)
      }

    # load gpkg to memory
    temp_sf <- load_gpkg(file_url, temps)
    return(temp_sf)
    }

## multiple files

  else if(length(file_url) > 1) {

    # input for progress bar
    total <- length(file_url)
    if(isTRUE(progress_bar)){
      pb <- utils::txtProgressBar(min = 0, max = total, style = 3)
      }


    # test connection with server1
    check_con <- check_connection(file_url[1], silent = TRUE)

    # if server1 fails, replace url and test connection with server2
    if (is.null(check_con) | isFALSE(check_con)) {
      file_url <- file_url2
      check_con <- check_connection(file_url[1], silent = FALSE)
      if(is.null(check_con) | isFALSE(check_con)){ return(invisible(NULL)) }
    }

    # download files
    lapply(X=file_url, function(x){

      # location of temp_file
      temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L)))

      # check if file has not been downloaded already. If not, download it
      if (!file.exists(temps) | file.info(temps)$size == 0) {
                                i <- match(c(x),file_url)
                                try( httr::GET(url=x, #httr::progress(),
                                          httr::write_disk(temps, overwrite = T),
                                          config = httr::config(ssl_verifypeer = FALSE)
                                          ), silent = TRUE)

                                if(isTRUE(progress_bar)){ utils::setTxtProgressBar(pb, i) }
                                }
      })

    # closing progress bar
    if(isTRUE(progress_bar)){close(pb)}

    # load gpkg
    temp_sf <- load_gpkg(file_url)
    return(temp_sf)

    }
}







#' Load geopackage from tempdir to global environment
#'
#' @param file_url A string with the file_url address of a geobr dataset
#' @param temps The address of a gpkg file stored in tempdir. Defaults to NULL
#' @keywords internal
#'
load_gpkg <- function(file_url, temps=NULL){

  ### one single file

  if (length(file_url)==1) {

    # read sf
    temp_sf <- sf::st_read(temps, quiet=T)
    return(temp_sf)
  }

  else if(length(file_url) > 1){

    # read files and pile them up
    files <- unlist(lapply(strsplit(file_url,"/"), tail, n = 1L))
    files <- paste0(tempdir(),"/",files)
    files <- lapply(X=files, FUN= sf::st_read, quiet=T)
    temp_sf <- sf::st_as_sf(data.table::rbindlist(files, fill = TRUE)) # do.call('rbind', files)

    # closes issue 284
    col1 <- names(temp_sf)[1]
    temp_sf <- subset(temp_sf, get(col1) != 'data_table_sf_bug')

    # remove data.table from object class. Closes #279.
    class(temp_sf) <- c("sf", "data.frame")

    return(temp_sf)
  }

  # load gpkg to memory
  temp_sf <- load_gpkg(file_url, temps)
  return(temp_sf)
}


# nocov end


#' Check internet connection with Ipea server
#'
#' @description
#' Checks if there is an internet connection with Ipea server to download aop data.
#'
#' @param url A string with the url address of an aop dataset
#' @param silent Logical. Throw a message when silent is `FALSE` (default)
#'
#' @return Logical. `TRUE` if url is working, `FALSE` if not.
#'
#' @keywords internal
#'
check_connection <- function(url = 'https://www.ipea.gov.br/geobr/metadata/metadata_gpkg.csv', silent = FALSE){ # nocov start

  # url <- 'https://google.com/'               # ok
  # url <- 'https://www.google.com:81/'   # timeout
  # url <- 'https://httpbin.org/status/300' # error

  # check if user has internet connection
  if (!curl::has_internet()) {
    if(isFALSE(silent)){ message("No internet connection.") }

    return(FALSE)
  }

  # message
  msg <- "Problem connecting to data server. Please try again in a few minutes."

  # test server connection
  x <- try(silent = TRUE,
           httr::GET(url, # timeout(5),
                     config = httr::config(ssl_verifypeer = FALSE)))
  # link offline
  if (methods::is(x)=="try-error") {
    if(isFALSE(silent)){ message( msg ) }
    return(FALSE)
  }

  # link working fine
  else if ( identical(httr::status_code(x), 200L)) {
    return(TRUE)
  }

  # link not working or timeout
  else if (! identical(httr::status_code(x), 200L)) {
    if(isFALSE(silent)){ message( msg ) }
    return(FALSE)

  } else if (httr::http_error(x) == TRUE) {
    if(isFALSE(silent)){ message( msg ) }
    return(FALSE)
  }

} # nocov end

