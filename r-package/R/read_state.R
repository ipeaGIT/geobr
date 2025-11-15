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
#' @template as_sf
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
#'   ufs <- read_state(code_state="all", year=2024)
#'
read_state <- function(year = 2010,
                       code_state = "all",
                       simplified  = TRUE,
                       as_sf = TRUE,
                       showProgress = TRUE,
                       cache = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="states", year=year, simplified=simplified)

  # check if metadata download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # download files
  file_path <- download_piggyback(
    filename_to_download = temp_meta$file_name,
    showProgress,
    cache
    )

  # check if download failed
  if (is.null(file_path)) { return(invisible(NULL)) }

  # open arrow dataset
  temp_arrw <- arrow::open_dataset(file_path)

  # return the whole dataset
  if (code_state == 'all') {

    # convert to sf
    if(isTRUE(as_sf)){
      temp_sf <- sf::st_as_sf(temp_arrw)
    }

    return(temp_sf)
  }

  # filter by abbrev
  filter_col <- NULL
  if (code_state %in% geobr_env$all_abbrev_state){
    filter_col <- "sigla_uf"
  }

  # filter by code
  if (code_state %in% geobr_env$all_code_state){
    filter_col <- "cd_uf"
  }

  if (is.null(filter_col)) {
    stop("Error: Invalid Value to argument code_state.")
  }

  # filter
  temp_arrw <- temp_arrw |>
    dplyr::filter( !!rlang::sym(filter_col) == code_state ) |>
    dplyr::compute()

  if  (nrow(temp_arrw) == 0){
    stop("Error: Invalid Value to argument code_state.")
    }

  # convert to sf
  if(isTRUE(as_sf)){
    temp_arrw <- sf::st_as_sf(temp_arrw)
  }

  return(temp_arrw)

  }
