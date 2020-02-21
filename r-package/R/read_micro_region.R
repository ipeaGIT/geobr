#' Download shape files of micro region as sf objects
#'
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @param year Year of the data (defaults to 2010)
#' @param code_micro 5-digit code of a micro region. If the two-digit code or a two-letter uppercase abbreviation of
#'  a state is passed, (e.g. 33 or "RJ") the function will load all micro regions of that state. If code_micro="all",
#'  all micro regions of the country are loaded.
#' @param tp Whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Default)
#' @param showProgress Logical. Defaults to (TRUE) display progress bar
#'
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read an specific micro region a given year
#'   micro <- read_micro_region(code_micro=11008, year=2018)
#'
#' # Read micro regions of a state at a given year
#'   micro <- read_micro_region(code_micro=12, year=2017)
#'   micro <- read_micro_region(code_micro="AM", year=2000)
#'
#'# Read all micro regions at a given year
#'   micro <- read_micro_region(code_micro="all", year=2010)
#' }
#'
#'

read_micro_region <- function(code_micro="all", year=2010, tp="simplified", showProgress=TRUE){


  # Get metadata
  temp_meta <- download_metadata(geography="micro_region", data_type=tp)


  # Test year input
  temp_meta <- test_year_input(temp_meta, y=year)


  # Verify code_micro input

  # if code_micro=="all", read the entire country
  if(code_micro=="all"){ message("Loading data for the whole country. This might take a few minutes.\n")

    # list paths of files to download
    file_url <- as.character(temp_meta$download_path)

    # download files
    temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
    return(temp_sf)
  }

  if( !(substr(x = code_micro, 1, 2) %in% temp_meta$code) & !(substr(x = code_micro, 1, 2) %in% temp_meta$code_abrev)){

    stop("Error: Invalid Value to argument code_micro.")

  } else{

    # list paths of files to download
    if (is.numeric(code_micro)){ file_url <- as.character(subset(temp_meta, code==substr(code_micro, 1, 2))$download_path) }
    if (is.character(code_micro)){ file_url <- as.character(subset(temp_meta, code_abrev==substr(code_micro, 1, 2))$download_path) }


    # download files
    sf <- download_gpkg(file_url, progress_bar = showProgress)

    if(nchar(code_micro)==2){
      return(sf)

    } else if(code_micro %in% sf$code_micro){    # Get micro region
      x <- code_micro
      sf <- subset(sf, code_micro==x)
      return(sf)
    } else{
      stop("Error: Invalid Value to argument code_micro. There was no micro region with this code in this year")
    }
  }
}
