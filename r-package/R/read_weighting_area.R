#' Download spatial data of Census Weighting Areas (area de ponderacao) of the Brazilian Population Census
#'
#' @description
#' Only 2010 data is currently available.
#'
#' @param code_weighting The 7-digit code of a Municipality. If the two-digit code
#' or a two-letter uppercase abbreviation of a state is passed, (e.g. 33 or "RJ")
#' the function will load all weighting areas of that state. If `code_weighting="all"`,
#' all weighting areas of the country are loaded.
#' @param year Numeric. Year of the data. Defaults to `2010`.
#' @template simplified
#' @template showProgress
#' @template cache
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read specific weighting area at a given year
#' w <- read_weighting_area(code_weighting=5201108005004, year=2010)
#'
#' # Read all weighting areas of a state at a given year
#' w <- read_weighting_area(code_weighting=53, year=2010) # or
#' w <- read_weighting_area(code_weighting="DF", year=2010)
#' plot(w)
#'
#' # Read all weighting areas of a municipality at a given year
#' w <- read_weighting_area(code_weighting=5201108, year=2010)
#' plot(w)
#'
#' # Read all weighting areas of the country at a given year
#' w <- read_weighting_area(code_weighting="all", year=2010)
#'
read_weighting_area <- function(code_weighting = "all",
                                year = 2010,
                                simplified = TRUE,
                                showProgress = TRUE,
                                cache = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="weighting_area", year=year, simplified=simplified)

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # if code_weighting=="all", read the entire country
  if(code_weighting=="all"){ message("Loading data for the whole country. This might take a few minutes.\n")}

  # check code_weighting exists in metadata
  if (!any(code_weighting == 'all' |
           code_weighting %in% temp_meta$code |
           substring(code_weighting, 1, 2) %in% temp_meta$code |
           code_weighting %in% temp_meta$code_abbrev |
           (year < 1992 & temp_meta$code %in% "mu")
  )) {
    stop("Error: Invalid Value to argument code_weighting.")
  }

  # get file url
  if (code_weighting=="all" | year < 1992) {
    file_url <- as.character(temp_meta$download_path)

  } else if (is.numeric(code_weighting)) { # if using numeric code_weighting
    file_url <- as.character(subset(temp_meta, code==substr(code_weighting, 1, 2))$download_path)

  } else if (is.character(code_weighting)) { # if using chacracter code_abbrev
    file_url <- as.character(subset(temp_meta, code_abbrev==substr(code_weighting, 1, 2))$download_path)
  }

  # download gpkg
  temp_sf <- download_gpkg(file_url = file_url,
                           showProgress = showProgress,
                           cache = cache)

  # check if download failed
  if (is.null(temp_sf)) { return(invisible(NULL)) }

  ## FILTERS
  y <- code_weighting

  # input "all"
  if(code_weighting=="all"){

    # abbrev_state
  } else if(code_weighting %in% temp_sf$abbrev_state){
    temp_sf <- subset(temp_sf, abbrev_state == y)

    # code_state
  } else if(code_weighting %in% temp_sf$code_state){
    temp_sf <- subset(temp_sf, code_state == y)

    # code_muni
  } else if(code_weighting %in% temp_sf$code_muni){
    temp_sf <- subset(temp_sf, code_muni == y)

    # code_weighting
  } else if (code_weighting %in% temp_sf$code_weighting) {
    temp_sf <- subset(temp_sf, code_weighting == y)

  } else {stop(paste0("Error: Invalid Value to argument 'code_weighting'",collapse = " "))}

  return(temp_sf)
}
