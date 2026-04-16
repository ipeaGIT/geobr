############# Support functions for geobr
# nocov start

# globals
geobr_data_release <- 'v2.0.0'

message_failed <- "A file must have been corrupted during download. Please restart your R session and try again."


#' Select data type: 'original' or 'simplified' (default)
#'
#'
#' @param temp_meta A data.frame with the metadata of geobr datasets
#' @param simplified_geometry Logical `TRUE` or `FALSE` indicating  whether the
#'        function should return a dataset with the 'original' geometry or a
#'        dataset with 'simplified' geometry (Defaults to `TRUE`)
#' @keywords internal
select_geometry_type <- function(temp_meta,
                                 simplified_geometry){

  checkmate::assert_logical(simplified_geometry)

  temp_meta <- subset(temp_meta, simplified == simplified_geometry)

  return(temp_meta)
}





#' Select year input
#'
#' @param temp_meta A dataframe with the file_url addresses of geobr datasets
#' @param y Year of the dataset (passed by red_ function)
#' @template verbose
#' @keywords internal
#'
select_year_input <- function(temp_meta,
                              y= parent.frame()$year,
                              verbose = parent.frame()$verbose){

  checkmate::assert_logical(verbose)

  years_available <- unique(temp_meta$year)

  # # NULL = use latest year available
  # if (is.null(y)) {
  #   y <- max(years_available)
  # }

  # invalid input
  if (y %in% years_available) {

    if (isTRUE(verbose)) {
      cli::cli_alert_info(paste0("Using year/date ", y))
      }

    temp_meta <- subset(temp_meta, year == y)
    return(temp_meta)
    }

  # invalid input
  else {
    years_available <- paste(years_available, collapse = " ")
    cli::cli_abort(
      "Data currently available only for the following year/date: {years_available}.",
      call = rlang::caller_env()
      )

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
select_metadata <- function(geography,
                            year = parent.frame()$year,
                            simplified = parent.frame()$simplified,
                            verbose = parent.frame()$verbose){

  # download metadata
  # metadata <- download_metadata()
  metadata <- download_metadata2()

  # check if download failed
  if (is.null(metadata)) { return(invisible(NULL)) }

  # Select geo
  temp_meta <- subset(metadata, geo == geography)

  # Select year input
  temp_meta <- select_year_input(temp_meta, y=year, verbose)

  # Select data type
  temp_meta <- select_geometry_type(temp_meta, simplified_geometry=simplified)

  return(temp_meta)
}


#' Support function to download metadata internally used in geobr
#'
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' df <- download_metadata()
#' }}
download_metadata <- function(){ # nocov start

  # create tempfile to save metadata
  tempf <- fs::path(fs::path_temp(), "metadata_geobr_gpkg.csv")

  # IF metadata has already been successfully downloaded
  if (file.exists(tempf) & file.info(tempf)$size != 0) {

  } else {

  # test server connection with github
  metadata_link <- 'https://github.com/ipeaGIT/geobr/releases/download/v1.7.0/metadata_1.7.0_gpkg.csv'
  try( silent = TRUE,
       check_con <- check_connection(metadata_link, silent = TRUE)
  )

  # if connection with github fails, try connection with ipea
  if (is.null(check_con) | isFALSE(check_con)) {
    metadata_link <- 'https://www.ipea.gov.br/geobr/metadata/metadata_1.7.0_gpkg.csv'
    try( silent = TRUE,
         check_con <- check_connection(metadata_link, silent = FALSE)
    )

    if (is.null(check_con) | isFALSE(check_con)) { return(invisible(NULL)) }
  }

  # download metadata to temp file
  try( silent = TRUE,
       downloaded_files <- curl::multi_download(
         urls = metadata_link,
         destfiles = tempf,
         resume = TRUE,
         progress = FALSE
       )
  )

  # if anything fails, return NULL
  if (any(!downloaded_files$success | is.na(downloaded_files$success))) {
    cli::cli_alert_danger(message_failed)
    return(invisible(NULL))
    }
  }

  # read metadata
  # metadata <- data.table::fread(tempf, stringsAsFactors=FALSE)
  metadata <- utils::read.csv(tempf, stringsAsFactors=FALSE)

  # check if data was read Ok
  if (nrow(metadata)==0) {
    cli::cli_alert_danger(message_failed)
    return(invisible(NULL))
  }

  return(metadata)
} # nocov end



#' Download geopackage to tempdir
#'
#' @param file_url A string with the file_url address of a geobr dataset
#' @template showProgress
#' @template cache
#' @keywords internal
#'
download_gpkg <- function(file_url = parent.frame()$file_url,
                          showProgress = parent.frame()$showProgress,
                          cache = parent.frame()$cache){

  if (!is.logical(showProgress)) { stop("'showProgress' must be of type 'logical'") }
  if (!is.logical(cache)) { stop("'cache' must be of type 'logical'") }

  # get backup links
  filenames <- basename(file_url)
  file_url2 <- paste0('https://github.com/ipeaGIT/geobr/releases/download/v1.7.0/', filenames)

  # dest files
  # temps <- paste0(fs::path_temp(),"/", unlist(lapply(strsplit(file_url,"/"),tail,n=1L)))
  temps <- fs::path(fs::path_temp(), basename(file_url))

  # test connection with server1
    try( silent = TRUE, check_con <- check_connection(file_url[1], silent = TRUE))

    # if server1 fails, replace url and test connection with server2
    if (is.null(check_con) | isFALSE(check_con)) {
      file_url <- file_url2
      try( silent = TRUE, check_con <- check_connection(file_url[1], silent = FALSE))
      if (is.null(check_con) | isFALSE(check_con)) { return(invisible(NULL)) }
    }

  # # this is necessary to silence download message when reading local file
  # if(file.exists(temps) & isTRUE(cache)){
  #   showProgress <- FALSE
  # }

  # download files
  try(silent = TRUE,
      downloaded_files <- curl::multi_download(
        urls = file_url,
        destfiles = temps,
        progress = showProgress,
        resume = cache
        )
      )

  # if anything fails, return NULL
  if (any(!downloaded_files$success | is.na(downloaded_files$success))) {
    cli::cli_alert_danger(message_failed)
    return(invisible(NULL))
  }

  # load gpkg
  temp_sf <- load_gpkg(temps) #
  return(temp_sf)
}



#' Download geopackage to tempdir
#'
#' @param file_url A string with the file_url address of a geobr dataset
#' @template showProgress
#' @template cache
#' @keywords internal
#'
download_geopackage <- function(file_url = parent.frame()$file_url,
                             showProgress = parent.frame()$showProgress,
                             cache = parent.frame()$cache){

  # check input
  checkmate::assert_logical(showProgress)
  checkmate::assert_logical(cache)

  # get backup links
  filenames <- basename(file_url)
  file_url2 <- paste0('https://github.com/ipeaGIT/geobr/releases/download/v1.7.0/', filenames)

  # dest files
  # temps <- paste0(fs::path_temp(),"/", unlist(lapply(strsplit(file_url,"/"),tail,n=1L)))
  temps <- fs::path(fs::path_temp(), basename(file_url))

  # test connection with server1
  try( silent = TRUE, check_con <- check_connection(file_url[1], silent = TRUE))

  # if server1 fails, replace url and test connection with server2
  if (is.null(check_con) | isFALSE(check_con)) {
    file_url <- file_url2
    try( silent = TRUE, check_con <- check_connection(file_url[1], silent = FALSE))
    if (is.null(check_con) | isFALSE(check_con)) { return(invisible(NULL)) }
  }

  # # this is necessary to silence download message when reading local file
  # if(file.exists(temps) & isTRUE(cache)){
  #   showProgress <- FALSE
  # }

  # download files
  try(silent = TRUE,
      downloaded_files <- curl::multi_download(
        urls = file_url,
        destfiles = temps,
        progress = showProgress,
        resume = cache
      )
  )

  # if anything fails, return NULL
  if (any(!downloaded_files$success | is.na(downloaded_files$success))) {
    cli::cli_alert_danger(message_failed)
    return(invisible(NULL))
  }

  # load gpkg
  temp_sf <- load_gpkg(temps) #
  return(temp_sf)
}





#' Load geopackage from tempdir to global environment
#'
#' @param temps The address of a gpkg file stored in tempdir. Defaults to NULL
#' @keywords internal
#'
load_gpkg <- function(temps=NULL){

  ### one single file

  if (length(temps)==1) {

    # read sf
    temp_sf <- sf::st_read(temps, quiet=TRUE)
  }

  else if(length(temps) > 1){

    # read files and pile them up
    files <- lapply(X=temps, FUN= sf::st_read, quiet=TRUE)
    # temp_sf <- sf::st_as_sf(data.table::rbindlist(files, fill = TRUE)) # do.call('rbind', files)
    temp_sf <- dplyr::bind_rows(files)

    # closes issue 284
    col1 <- names(temp_sf)[1]
    temp_sf <- subset(temp_sf, get(col1) != 'data_table_sf_bug')

    # remove data.table from object class. Closes #279.
    class(temp_sf) <- c("sf", "data.frame")

  }

  # check if data was read Ok
  if (nrow(temp_sf)==0) {
    cli::cli_alert_danger(message_failed)
    return(invisible(NULL))
  }
  return(temp_sf)

  # load gpkg to memory
  temp_sf <- load_gpkg(temps)
  return(temp_sf)
}


# nocov end



#' Check internet connection with Ipea server
#'
#' @description
#' Checks if there is an internet connection with Ipea server.
#'
#' @param url A string with the url address of an aop dataset
#' @param silent Logical. Throw a message when silent is `FALSE` (default)
#'
#' @return Logical. `TRUE` if url is working, `FALSE` if not.
#'
#' @keywords internal
#'
check_connection <- function(url = 'https://www.ipea.gov.br/geobr/metadata/metadata_gpkg.csv',
                             silent = FALSE){ # nocov start
  # url <- 'https://google.com/'               # ok
  # url <- 'https://www.google.com:81/'   # timeout
  # url <- 'https://httpbin.org/status/300' # error

  # Check if user has internet connection
  if (!curl::has_internet()) {
    if (isFALSE(silent)) {
      cli::cli_alert_danger("No internet connection.")
    }
    return(FALSE)
  }

  # Message for connection issues
  msg <- "Problem connecting to data server. Please try again in a few minutes."

  # Test server connection using curl
  handle <- curl::new_handle(ssl_verifypeer = FALSE)
  response <- try(curl::curl_fetch_memory(url, handle = handle), silent = TRUE)

  # Check if there was an error during the fetch attempt
  if (inherits(response, "try-error")) {
    if (isFALSE(silent)) {
      cli::cli_alert_danger(msg)
    }
    return(FALSE)
  }

  # Check the status code
  status_code <- response$status_code

  # Link working fine
  if (status_code == 200L) {
    return(TRUE)
  }

  # Link not working or timeout
  if (status_code != 200L) {
    if (isFALSE(silent)) {
      cli::cli_alert_danger(msg)
    }
    return(FALSE)
  }
} # nocov end



#' Check if vector only has numeric characters
#'
#' @description
#' Checks if vector only has numeric characters
#'
#' @param x A vector.
#'
#' @return Logical. `TRUE` if vector only has numeric characters.
#'
#' @keywords internal
numbers_only <- function(x){ !grepl("\\D", x) } # nocov



#' Filter data set to return specific states
#'
#' @param temp_sf An internal simple feature or data.frame
#' @param code The two-digit code of a state or a two-letter uppercase
#'             abbreviation (e.g. 33 or "RJ"). If `code_state="all"` (the
#'             default), the function downloads all states.
#'
#' @return A simple feature `sf` or `data.frame`.
#'
#' @keywords internal
filter_arrw <- function(temp_arrw = parent.frame()$temp_arrw,
                        code){ # nocov start

  # all states
  if (any(code == 'all')) {return(temp_arrw)}

  # DETECT WHICH COLUMN TO FILTER ON
  filter_col <- NULL

  # filter by abbrev
  if (all(code %in% geobr_env$all_abbrev_state)) {
    filter_col <- "abbrev_state"
  }

  # filter by code_state
  if (all(code %in% geobr_env$all_code_state)){
    filter_col <- "code_state"
  }

  # filter by the first column whose name starts with "code_".
  if (all(numbers_only(code)) && all(nchar(code)>3)) {
    filter_col <- grep("^code_", names(temp_arrw), value = TRUE)[1] # code_
    }


  # check
  if (is.null(filter_col)) {
    cli::cli_abort("Invalid value to argument `code_`.")
    }

  # filter
  temp_arrw <- temp_arrw |>
    dplyr::filter( !!rlang::sym(filter_col) %in% code ) |>
    dplyr::compute()

  # check
  if  (nrow(temp_arrw) == 0){
    cli::cli_abort("Invalid value to argument `code_`.")
  }

  return(temp_arrw)

} # nocov end





download_metadata2 <- function(){

  # path to tempfile of metadata
  tempf <- fs::path(fs::path_temp(), "metadata_geobr_gpkg.parquet")

  # IF metadata has already been successfully downloaded
  if (file.exists(tempf) & file.info(tempf)$size != 0) {

    # read temp metadata
    temp_meta <- arrow_read_dataset(tempf)

    # check if data was read Ok
    if (nrow(temp_meta)==0) {
      cli::cli_alert_danger(message_failed)
      return(invisible(NULL))
    }

    return(temp_meta)
  }


  # test server connection with github
  metadata_link <- paste0("https://github.com/ipeaGIT/geobr/")
  try( silent = TRUE,
       check_con <- check_connection(metadata_link, silent = FALSE)
       )

  # if server fails, fail gracefully
  if (is.null(check_con) | isFALSE(check_con)) {
    return(invisible(NULL))
  }

  # download metadata to temp file
  temp_meta <- NULL

  try(silent = TRUE,
    temp_meta <- piggyback::pb_list(
      repo = "ipeaGIT/geobr",
      tag = geobr_env$data_release
    ),
  )

  # check if download failed
  if (is.null(temp_meta)) {
    cli::cli_alert_danger(message_failed)
    return(invisible(NULL))
  }

  # parse metadata
  temp_meta <- temp_meta |>
    dplyr::select(file_name) |>
    dplyr::mutate(
      geo = stringr::str_extract(file_name, "^[^_]+"),
      year  = stringr::str_extract(file_name, "\\d+"),
      simplified = ifelse(stringr::str_detect(file_name, "simplified"), TRUE, FALSE)
    )

  # save temp metadata
  arrow::write_parquet(temp_meta, tempf)

  return(temp_meta)
}



#' Download parquet to tempdir
#'
#' @param filename_to_download A string with the file name
#' @template showProgress
#' @template cache
#' @keywords internal
#'
download_parquet <- function(filename_to_download,
                             showProgress = parent.frame()$showProgress,
                             cache = parent.frame()$cache) {

  # check input
  checkmate::assert_logical(showProgress)
  checkmate::assert_logical(cache)

  # Defining our temporary directory
  temp_dest_dir <- fs::path_temp("geobr")

  # Creating the temporary folder effectively
  fs::dir_create(path = temp_dest_dir, recurse = TRUE)

  # Creating path + filename and saving to "temporary_filename"
  temp_full_file_path <- paste0(temp_dest_dir, "/", filename_to_download)

  # downloading the file
  try(silent=T,
      suppressMessages(
        piggyback::pb_download(
          file = filename_to_download,
          repo = "ipeaGIT/geobr",
          tag = geobr_env$data_release,
          dest = temp_dest_dir,
          show_progress = showProgress,
          overwrite = !cache
          )
      )
  )

  # Halt function if download failed
  if (!file.exists(temp_full_file_path)) {
    cli::cli_alert_danger(message_failed)
    invisible(NULL)
  }

  # load parquet
  temp_arrw <- arrow_open_dataset(temp_full_file_path) #
  return(temp_arrw)
}



#' Safely use arrow to open a Parquet file
#'
#' This function handles some failure modes, including if the Parquet file is
#' corrupted.
#'
#' @param filename A local Parquet file
#' @return An `arrow::Dataset`
#'
#' @keywords internal
arrow_open_dataset <- function(filename){ # nocov start

  temp_arrw <- NULL
  try(silent = TRUE,
    temp_arrw <- arrow::open_dataset(filename)
  )

  if(is.null(temp_arrw)){
    cli::cli_alert_danger(message_failed)
  }

  return(temp_arrw)
} # nocov end



#' Safely use arrow to read a Parquet file
#'
#' This function handles some failure modes, including if the Parquet file is
#' corrupted.
#'
#' @param filename A local Parquet file
#' @return An `arrow::Dataset`
#'
#' @keywords internal
arrow_read_dataset <- function(filename){ # nocov start

  temp_arrw <- NULL
  try(silent = TRUE,
      temp_arrw <- arrow::read_parquet(filename)
  )

  if(is.null(temp_arrw)){
    cli::cli_alert_danger(message_failed)
  }

  return(temp_arrw)

} # nocov end
