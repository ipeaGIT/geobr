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
                                 simplified_geometry){ # nocov start

  checkmate::assert_logical(simplified_geometry)

  temp_meta <- subset(temp_meta, simplified == simplified_geometry)

  return(temp_meta)
} # nocov end





#' Select year input
#'
#' @param temp_meta A dataframe with the file_url addresses of geobr datasets
#' @param y Year of the dataset (passed by red_ function)
#' @template verbose
#' @keywords internal
#'
select_year_input <- function(temp_meta,
                              y= parent.frame()$year,
                              verbose = parent.frame()$verbose){ # nocov start

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
} # nocov end


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
                            verbose = parent.frame()$verbose){ # nocov start

  # download metadata
  # metadata <- download_metadata()
  metadata <- download_metadata2()

  # check if download failed
  if (is.null(metadata)) { return(invisible(NULL)) }

  # Select geo
  temp_meta <- subset(metadata, geo %in% geography)

  # Select year input
  temp_meta <- select_year_input(temp_meta, y=year, verbose)

  # Select data type
  temp_meta <- select_geometry_type(temp_meta, simplified_geometry=simplified)

  return(temp_meta)
} # nocov end




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

  # Source - https://stackoverflow.com/questions/59796178/r-curlhas-internet-false-even-though-there-are-internet-connection/59800411#59800411
  # Posted by Hong Ooi
  # allow internet connection via proxy. Closes https://github.com/ipeaGIT/geobr/issues/399
  assign("has_internet_via_proxy", TRUE, environment(curl::has_internet))

  # Check if user has internet connection
  if (!httr2::is_online()) {
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
#' @param temp_arrw An internal arrow table
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
  if (all(code %in% geobr_env$all_code_state)) {
    filter_col <- "code_state"
  }


  # filter by the first column whose name starts with "code_".
  if (all(numbers_only(code)) && all(nchar(code)>3)) {
    filter_col <- grep("^code_", names(temp_arrw), value = TRUE)[1] # code_
  }

  # filter by code_muni
  if (all(nchar(code)==7)) {
    filter_col <- "code_muni"
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




#' Support function to download metadata internally used in geobr
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' df <- download_metadata2()
#' }
#' }
download_metadata2 <- function(){ # nocov start

  # path to tempfile of metadata
  tempf <- fs::path(fs::path_temp(), "metadata_geobr_gpkg.parquet")

  # IF metadata has already been successfully downloaded
  if (file.exists(tempf) & file.info(tempf)$size != 0) {

    # read temp metadata
    temp_meta <- arrow_open_dataset(tempf) |> dplyr::collect()

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
    )
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
} # nocov end



#' Download parquet to tempdir
#'
#' @param filename_to_download A string with the file name
#' @template showProgress
#' @template cache
#' @keywords internal
#'
download_parquet <- function(filename_to_download,
                             showProgress = parent.frame()$showProgress,
                             cache = parent.frame()$cache) { # nocov start

  # check input
  checkmate::assert_logical(showProgress, len = 1, any.missing = FALSE)
  checkmate::assert_logical(cache, len = 1, any.missing = FALSE)

  # create temp directory
  temp_dest_dir <- fs::path_temp("geobr")
  fs::dir_create(path = temp_dest_dir, recurse = TRUE)

  # create to local file
  temp_full_file_path <- fs::path(temp_dest_dir, filename_to_download)

  # if file already exists, open and return parquet
  if (isTRUE(cache) && file.exists(temp_full_file_path)) {
    temp_arrw <- arrow_open_dataset(temp_full_file_path)
    return(temp_arrw)
  }

  # download file otherwise

    # build url
    file_url <- paste0(
      "https://github.com/ipeaGIT/geobr/releases/download/",
      geobr_env$data_release,
      "/", filename_to_download
      )

    # prep request
    try(silent=T,
      req <- httr2::request(file_url) |>
        httr2::req_options(
          timeout = 500,
          ssl_verifypeer = 0L
        ))

    # add progress bar
    if (isTRUE(showProgress)) {
      try(silent=T,
          req <- req |> httr2::req_progress()
          )
    }

    # download file
    try(silent=T,
        req |>
          httr2::req_perform(path = temp_full_file_path)
        )

  # Halt function if download failed
  if (!file.exists(temp_full_file_path)) {
    cli::cli_alert_danger(message_failed)
    invisible(NULL)
  }

  # load parquet
  temp_arrw <- arrow_open_dataset(temp_full_file_path) #
  return(temp_arrw)
} # nocov end



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



convert_arrow2sf <- function(temp_arrw, as_sf){ # nocov start

  checkmate::assert_logical(as_sf)

  if(isTRUE(as_sf)){
    temp_arrw <- sf::st_as_sf(temp_arrw)
  }

  return(temp_arrw)
} # nocov end


# place holder to use geoarrow becaue:
#   Namespace in Imports field not imported from: 'geoarrow'
#        All declared Imports should be used.
geoarrow::as_geoarrow_vctr("POINT (0 1)") # nocov
