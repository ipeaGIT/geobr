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
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family general area functions
#' @examples \dontrun{ if (interactive()) {
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
#' } }
read_weighting_area <- function(code_weighting="all", year=2010, simplified=TRUE, showProgress=TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="weighting_area", year=year, simplified=simplified)

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # Verify code_weighting input
        # if code_weighting=="all", read the entire country
        if(code_weighting=="all"){ message("Loading data for the whole country. This might take a few minutes.\n")

        # list paths of files to download
        file_url <- as.character(temp_meta$download_path)

        # download files
        temp_sf <- download_gpkg(file_url, progress_bar = showProgress)

        # check if download failed
        if (is.null(temp_sf)) { return(invisible(NULL)) }

        return(temp_sf)

      }

  else if( !(substr(x = code_weighting, 1, 2) %in% temp_meta$code) & !(substr(x = code_weighting, 1, 2) %in% temp_meta$code_abbrev)){
      stop("Error: Invalid Value to argument code_weighting.")

  } else {

    # list paths of files to download
      if (is.numeric(code_weighting)){ file_url <- as.character(subset(temp_meta, code==substr(code_weighting, 1, 2))$download_path) }
      if (is.character(code_weighting)){ file_url <- as.character(subset(temp_meta, code_abbrev==substr(code_weighting, 1, 2))$download_path) }

    # download files
    temp_sf <- download_gpkg(file_url, progress_bar = showProgress)

    # check if download failed
    if (is.null(temp_sf)) { return(invisible(NULL)) }

    # return whole state
    if(nchar(code_weighting)==2){
      return(temp_sf)

    # return municipality
    } else if(code_weighting %in% temp_sf$code_muni){    # Get weighting area
      x <- code_weighting
      temp_sf <- subset(temp_sf, code_muni==x)
      return(temp_sf)

    # return code weighting area

    } else if(code_weighting %in% temp_sf$code_weighting){    # Get weighting area
      x <- code_weighting
      temp_sf <- subset(temp_sf, code_weighting==x)
      return(temp_sf)

    } else{
      stop("Error: Invalid Value to argument code_weighting.")
    }
  }
}
