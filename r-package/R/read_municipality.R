#' Download shape files of Brazilian municipalities as sf objects.
#'
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#'
#' @param year Year of the data (defaults to 2010)
#' @param code_muni The 7-digit code of a municipality. If the two-digit code or a two-letter uppercase abbreviation of
#'  a state is passed, (e.g. 33 or "RJ") the function will load all municipalities of that state. If code_muni="all", all municipalities of the country will be loaded.
#' @param simplified Logic TRUE or FALSE, indicating whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Defaults to TRUE)
#' @param showProgress Logical. Defaults to (TRUE) display progress bar
#'
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read specific municipality at a given year
#'   mun <- read_municipality(code_muni=1200179, year=2017)
#'
#'# Read all municipalities of a state at a given year
#'   mun <- read_municipality(code_muni=33, year=2010)
#'   mun <- read_municipality(code_muni="RJ", year=2010)
#'
#'# Read all municipalities of the country at a given year
#'   mun <- read_municipality(code_muni="all", year=2018)
#'}
#'

read_municipality <- function(code_muni="all", year=2010, simplified=TRUE, showProgress=TRUE){


  # Get metadata with data addresses
  temp_meta <- download_metadata(geography="municipality", data_type=simplified)


  # Test year input
  temp_meta <- test_year_input(temp_meta, y=year)



# BLOCK 2.1 From 1872 to 1991  ----------------------------

  if( year < 1992){

    # list paths of files to download
    file_url <- as.character(temp_meta$download_path)

    # download files
    temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
    return(temp_sf)

    } else {


# BLOCK 2.2 From 2000 onwards  ----------------------------

# 2.2 Verify code_muni Input

  # if code_muni=="all", read the entire country
    if(code_muni=="all"){ message("Loading data for the whole country. This might take a few minutes.\n")

      # list paths of files to download
      file_url <- as.character(temp_meta$download_path)

      # download files
      temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
      return(temp_sf)
    }

  else if( !(substr(x = code_muni, 1, 2) %in% temp_meta$code) & !(substr(x = code_muni, 1, 2) %in% temp_meta$code_abrev)){

      stop("Error: Invalid Value to argument code_muni.")

  } else{

    # list paths of files to download
    if (is.numeric(code_muni)){ file_url <- as.character(subset(temp_meta, code==substr(code_muni, 1, 2))$download_path) }
    if (is.character(code_muni)){ file_url <- as.character(subset(temp_meta, code_abrev==substr(code_muni, 1, 2))$download_path) }

    # download files
    sf <- download_gpkg(file_url, progress_bar = showProgress)

    # input is a state code
    if(nchar(code_muni)==2){
        return(sf) }

    # input is a municipality code
    else if(code_muni %in% sf$code_muni){
          x <- code_muni
          sf <- subset(sf, code_muni==x)
          return(sf)
      } else{
          stop("Error: Invalid Value to argument code_muni.")
      }
    }
    }
  }
