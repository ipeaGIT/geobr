#' Download shape files of Census Weighting Areas (area de ponderacao) of the Brazilian Population Census.
#'
#' Only 2010 data is currently available.
#'
#' @param code_weighting The 7-digit code of a Municipality. If the two-digit code or a two-letter uppercase abbreviation of
#'  a state is passed, (e.g. 33 or "RJ") the function will load all weighting areas of that state. If code_weighting="all",
#'  all weighting areas of the country are loaded.
#' @param year Year of the data (defaults to 2010)
#' @param tp Whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Default)
#' @param showProgress Logical. Defaults to (TRUE) display progress bar
#'
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read specific weighting area at a given year
#'   w <- read_weighting_area(code_weighting=5201108005004, year=2010)
#'
#' # Read all weighting areas of a state at a given year
#'   w <- read_weighting_area(code_weighting=53, year=2010) # or
#'   w <- read_weighting_area(code_weighting="DF", year=2010)
#'   plot(w)
#'
#' # Read all weighting areas of a municipality at a given year
#'   w <- read_weighting_area(code_weighting=5201108, year=2010)
#'   plot(w)
#'
#' # Read all weighting areas of the country at a given year
#'   w <- read_weighting_area(code_weighting="all", year=2010)
#'
#' }
#'
#'
#'
#'
read_weighting_area <- function(code_weighting="all", year=2010, tp="simplified", showProgress=TRUE){

  # Get metadata with data addresses
  temp_meta <- download_metadata(geography="weighting_area", data_type=tp)


  # Test year input
  temp_meta <- test_year_input(temp_meta, y=year)


# Verify code_weighting input

  # if code_weighting=="all", read the entire country
    if(code_weighting=="all"){ message("Loading data for the whole country. This might take a few minutes.\n")

        # list paths of files to download
        file_url <- as.character(temp_meta$download_path)

        # download files
        temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
        return(temp_sf)

      }

  else if( !(substr(x = code_weighting, 1, 2) %in% temp_meta$code) & !(substr(x = code_weighting, 1, 2) %in% temp_meta$code_abrev)){
      stop("Error: Invalid Value to argument code_weighting.")

  } else {

    # list paths of files to download
      if (is.numeric(code_weighting)){ file_url <- as.character(subset(temp_meta, code==substr(code_weighting, 1, 2))$download_path) }
      if (is.character(code_weighting)){ file_url <- as.character(subset(temp_meta, code_abrev==substr(code_weighting, 1, 2))$download_path) }

    # download files
    temp_sf <- download_gpkg(file_url, progress_bar = showProgress)

    # return whole state
    if(nchar(code_weighting)==2){
      return(temp_sf)

    # return municipality
    } else if(code_weighting %in% temp_sf$code_muni){    # Get weighting area
      x <- code_weighting
      temp_sf <- subset(temp_sf, code_muni==x)
      return(temp_sf)

    # return code weighting area

    } else if(code_weighting %in% temp_sf$code_weighting_area){    # Get weighting area
      x <- code_weighting
      temp_sf <- subset(temp_sf, code_weighting_area==x)
      return(temp_sf)

    } else{
      stop("Error: Invalid Value to argument code_weighting.")
    }
  }
}
