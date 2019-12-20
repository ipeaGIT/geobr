#' Lookup municipality codes and names
#'
#' Input a municipality \strong{name} \emph{or} \strong{code} and get the names and codes of the
#' municipality's corresponding state, meso, micro, intermediate, and immediate regions
#'
#'
#' @param name_muni The municipality name to be looked up
#' @param code_muni The municipality code to be looked up
#' @return A data.frame with 13 columns identifying the geographies information of that municipality
#' @export
#' @details Only available from 2010 Census data so far
#' @examples \donttest{
#' library(geobr)
#'
#' # Get lookup table for municipality Rio de Janeiro
#' mun <- lookup_muni(name_muni = "Rio de Janeiro")
#'
#' # Or you can get a lookup table for the same municipality searching for its code
#' mun <- lookup_muni(code_muni = 3304557)
#'
#' # Get lookup table for all municipalities
#' mun_all <- lookup_muni(name_muni == "all")
#'
#' # Or:
#' mun_all <- lookup_muni(code_muni == "all")
#'
#'}

lookup_muni <- function(name_muni = NULL, code_muni = NULL) {



  # Get metadata with data addresses
  metadata <- download_metadata()

  # Open lookup table
  temp_meta <- subset(metadata, geo == "lookup_muni")

  # list paths of files to download
  filesD <- as.character(temp_meta$download_path)

  # download files
  temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
  httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))

  # read file
  lookup_table_2010 <- readr::read_rds(temps)


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
