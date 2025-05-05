#' Download spatial data of Brazilian states
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @template year
#' @param code_state The two-digit code of a state or a two-letter uppercase
#'                   abbreviation (e.g. 33 or "RJ"). If `code_state="all"` (the
#'                   default), the function downloads all states.
#' @template simplified
#' @template showProgress
#' @template cache
#'
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read specific state at a given year
#'   uf <- read_state(code_state=12, year=2017)
#'
#' # Read specific state at a given year
#'   uf <- read_state(code_state="SC", year=2000)
#'
#' # Read all states at a given year
#'   ufs <- read_state(code_state="all", year=2010)
#'
read_state <- function(year = 2010,
                       code_state = "all",
                       simplified  = TRUE,
                       showProgress = TRUE,
                       cache = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="state", year=year, simplified=simplified)

  # check if metadata download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # check code_state exists in metadata
  if (!any(code_state == 'all' |
           code_state %in% temp_meta$code |
           code_state %in% temp_meta$code_abbrev |
           (year < 1992 & temp_meta$code == "st")
           )) {
    stop("Error: Invalid Value to argument code_state.")
    }


  # get file url
  if (code_state=="all" | year < 1992) {
    file_url <- as.character(temp_meta$download_path)

      } else if (is.numeric(code_state)) { # if using numeric code_state
        file_url <- as.character(subset(temp_meta, code==substr(code_state, 1, 2))$download_path)

        } else if (is.character(code_state)) { # if using chacracter code_abbrev
          file_url <- as.character(subset(temp_meta, code_abbrev==substr(code_state, 1, 2))$download_path)
        }

  # download gpkg
  temp_sf <- download_gpkg(file_url = file_url,
                           showProgress = showProgress,
                           cache = cache)

  # check if download failed
  if (is.null(temp_sf)) { return(invisible(NULL)) }

  ## FILTERS
  y <- code_state

  # input "all" & data files before 1992 do not have state code nor state abbrev
  if (year < 1992 | code_state=="all") {

    # abbrev_state
  } else if(code_state %in% temp_sf$abbrev_state){
    temp_sf <- subset(temp_sf, abbrev_state == y)

    # code_state
  } else if(code_state %in% temp_sf$code_state){
    temp_sf <- subset(temp_sf, code_state == y)

  } else {stop(paste0("Error: Invalid Value to argument 'read_state'",collapse = " "))}

  return(temp_sf)
  }
