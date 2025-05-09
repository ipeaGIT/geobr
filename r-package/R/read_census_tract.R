#' Download spatial data of census tracts of the Brazilian Population Census
#'
#' @description
#' Download spatial data of census tracts of the Brazilian Population Census
#'
#' @template year
#' @param code_tract The 7-digit code of a Municipality. If the two-digit code
#'         or a two-letter uppercase abbreviation of a state is passed, (e.g. 33
#'         or "RJ") the function will load all census tracts of that state. If
#'         `code_tract="all"`, the function downloads all census tracts of the
#'         country.
#' @param zone For census tracts before 2010, 'urban' and 'rural' census tracts
#'             are separate data sets.
#' @template simplified
#' @template showProgress
#' @template cache
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family general area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read rural census tracts for years before 2007
#'   c <- read_census_tract(code_tract=5201108, year=2000, zone="rural")
#'
#' # Read all census tracts of a state at a given year
#'   c <- read_census_tract(code_tract=53, year=2010) # or
#'   c <- read_census_tract(code_tract="DF", year=2010)
#'   plot(c)
#'
#' # Read all census tracts of a municipality at a given year
#'   c <- read_census_tract(code_tract=5201108, year=2010)
#'   plot(c)
#'
#' # Read all census tracts of the country at a given year
#'   c <- read_census_tract(code_tract="all", year=2010)
#'
read_census_tract <- function(year = NULL,
                              code_tract,
                              zone = "urban",
                              simplified = TRUE,
                              showProgress = TRUE,
                              cache = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="census_tract", year=year, simplified=simplified)

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # Check zone input urban and rural inputs if year <=2007
  if ( temp_meta$year[1] <= 2007){

    if (zone == "urban") {message("Using data of Urban census tracts\n")
                          temp_meta <- temp_meta[substr(temp_meta[,3],1,1)== "U", ] }

    else if (zone == "rural") {message("Using data of Rural census tracts\n")
                                       temp_meta <- temp_meta[substr(temp_meta[,3],1,1)== "R", ] }

    else { stop( paste0("Error: Invalid Value to argument 'zone'. It must be either 'urban' or 'rural'")) }
    }



  # Verify code_tract input

  # Test if code_tract input is null
  if(is.null(code_tract)){ stop("Value to argument 'code_tract' cannot be NULL") }


    # if code_tract=="all", read the entire country
    if(code_tract=="all"){ message("Loading data for the whole country. This might take a few minutes.\n")

      # list paths of files to download
      file_url <- as.character(temp_meta$download_path)

      # download files
      temp_sf <- download_gpkg(file_url = file_url,
                               showProgress = showProgress,
                               cache = cache)

      # check if download failed
      if (is.null(temp_sf)) { return(invisible(NULL)) }

      return(temp_sf)
    }

    else if( (!(substr(x = code_tract, 1, 2) %in% temp_meta$code) & !(toupper(substr(x = code_tract, 1, 2)) %in% temp_meta$code_abbrev)
              )&(!(paste0("U",substr(x = code_tract, 1, 2)) %in% substr(temp_meta$code, 1, 3)) & !(toupper(substr(x = code_tract, 1, 2)) %in% temp_meta$code_abbrev)
                 )&(!(paste0("R",substr(x = code_tract, 1, 2)) %in% substr(temp_meta$code, 1, 3)) & !(toupper(substr(x = code_tract, 1, 2)) %in% temp_meta$code_abbrev))
            ){

      stop("Error: Invalid Value to argument code_tract.")

    } else{

      # list paths of files to download
      if (temp_meta$year[1] <= 2007 & zone == "urban") {

        if (is.numeric(code_tract)){ file_url <- as.character(subset(temp_meta, code==paste0("U",substr(code_tract, 1, 2)))$download_path) }
        if (is.character(code_tract)){ file_url <- as.character(subset(temp_meta, code_abbrev==toupper(substr(code_tract, 1, 2)))$download_path) }

      } else if (temp_meta$year[1] <= 2007 & zone == "rural") {

        if (is.numeric(code_tract)){ file_url <- as.character(subset(temp_meta, code==paste0("R",substr(code_tract, 1, 2)))$download_path) }
        if (is.character(code_tract)){ file_url <- as.character(subset(temp_meta, code_abbrev==toupper(substr(code_tract, 1, 2)))$download_path) }

      } else {

      if (is.numeric(code_tract)){ file_url <- as.character(subset(temp_meta, code==substr(code_tract, 1, 2))$download_path) }
      if (is.character(code_tract)){ file_url <- as.character(subset(temp_meta, code_abbrev==toupper(substr(code_tract, 1, 2)))$download_path) }

        }
      # download files
      sf <- download_gpkg(file_url = file_url,
                               showProgress = showProgress,
                               cache = cache)

      # check if download failed
      if (is.null(sf)) { return(invisible(NULL)) }

      if(nchar(code_tract)==2){
        return(sf)

      } else if(code_tract %in% sf$code_muni){    # Get Municipio
        x <- code_tract
        sf <- subset(sf, code_muni==x)
        return(sf)
      } else{
        stop("Error: Invalid Value to argument code_tract.")
      }
    }
  }
