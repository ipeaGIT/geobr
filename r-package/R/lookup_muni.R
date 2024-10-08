#' Look up municipality codes and names
#'
#' @description
#' Input a municipality \strong{name} \emph{or} \strong{code} and get the names
#' and codes of the municipality's corresponding state, meso, micro, intermediate,
#' and immediate regions
#'
#' @param name_muni The municipality name to be looked up.
#' @param code_muni The municipality code to be looked up.
#' @return A `data.frame` with 13 columns identifying the geographies information
#'         of that municipality.
#'
#' @return A `data.frame`
#'
#' @export
#' @family support functions
#'
#' @details Only available from 2010 Census data so far
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Get lookup table for municipality Rio de Janeiro
#' mun <- lookup_muni(name_muni = "Rio de Janeiro")
#'
#' # Or you can get a lookup table for the same municipality searching for its code
#' mun <- lookup_muni(code_muni = 3304557)
#'
#' # Get lookup table for all municipalities
#' mun_all <- lookup_muni(name_muni = "all")
#'
#' # Or:
#' mun_all <- lookup_muni(code_muni = "all")
#'
lookup_muni <- function(name_muni = NULL, code_muni = NULL) {

  # create tempfile to save metadata
  tempf <- fs::path(fs::path_temp(), "lookup_muni_2010.csv")

  # IF metadata has already been downloaded
  if (file.exists(tempf) &  file.info(tempf)$size != 0) {

    # skip

  } else {

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="lookup_muni", year=2010, simplified=FALSE)

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # get backup links
  filenames <- basename(file_url)
  file_url2 <- paste0('https://github.com/ipeaGIT/geobr/releases/download/v1.7.0/', filenames)

  # test connection with server1
  try(silent = TRUE,
      check_con <- check_connection(file_url[1], silent = TRUE)
  )

  # if server1 fails, replace url and test connection with server2
  if (is.null(check_con) | isFALSE(check_con)) {
    message('Using Github')
    file_url <- file_url2
    check_con <- try(silent = TRUE, check_connection(file_url[1], silent = FALSE))
    if (is.null(check_con) | isFALSE(check_con)) { return(invisible(NULL)) }
  }

  # download data
  try( silent = TRUE,
       downloaded_files <- curl::multi_download(
         urls = file_url,
         destfiles = tempf,
         resume = TRUE,
         progress = FALSE
       )
  )

  # if anything fails, return NULL
  if (any(!downloaded_files$success | is.na(downloaded_files$success))) {
    msg <- paste("File cached locally seems to be corrupted. Please download it again.")
    message(msg)
    return(invisible(NULL))
  }

  }


  ### read/return lookup data
  lookup_table_2010 <- utils::read.csv(tempf, stringsAsFactors = F, encoding = 'UTF-8')


  # code_muni has priority over other arguments

  # if code_muni is empty and name_muni is not empty, search for name_muni
  if (is.null(code_muni) & !is.null(name_muni)) {

    if (name_muni == "all") {


      # Delete formatted column
      lookup_table_2010$name_muni_format <- NULL

      return(lookup_table_2010)

    } else {


      # 1. Format input -----------------

      x <- name_muni
      # to lower
      x <- tolower(x)
      # delete accents
      x <- iconv(x, to="ASCII//TRANSLIT")
      x <- iconv(x, to="UTF-8")
      # trim white spaces
      x <- trimws(x, "both")

      # 2. Search formated input in the lookup table -----------------

      # message(sprintf("Searching for %s", x))

      # Filter muni name
      lookup_filter <- subset(lookup_table_2010, name_muni_format == x)

      if (nrow(lookup_filter) == 0) {

        stop("Please insert a valid municipality name", call. = FALSE)

      } else {

        message(sprintf("Returning results for municipality %s", lookup_filter$name_muni))

        # n_unique <- length(unique(lookup_filter$name_muni_format))

        # Delete formatted column
        lookup_filter$name_muni_format <- NULL

        return(lookup_filter)

      }


    }

  }


  # if both name and code are provided, give a warning saying that the name was ignored
  if (is.numeric(code_muni) & !is.null(name_muni)) {

    warning("Ignoring argument name_muni")
  }


  # code_muni has priority over other arguments
  if (is.numeric(code_muni) | is.character(code_muni)) {

    if (code_muni == "all") {

      # Delete formatted column
      lookup_table_2010$name_muni_format <- NULL

      return(lookup_table_2010)

    } else {

      # 1. Search input in the lookup table -----------------

      x <- code_muni

      # Filter muni name
      lookup_filter <- subset(lookup_table_2010, code_muni == x)

      if (nrow(lookup_filter) == 0) {

        stop("Please insert a valid municipality code", call. = FALSE)

      } else {

        message(sprintf("Returning results for municipality %s", lookup_filter$name_muni))

        # Delete formatted column
        lookup_filter$name_muni_format <- NULL

        return(lookup_filter)

      }

    }

  }

  # if both arguments are empty
  if (is.null(code_muni) & is.null(code_muni)) {

    stop("Please insert either a municipality name or a municipality code")

  }

}
