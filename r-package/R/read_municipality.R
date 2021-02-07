#' Download shape files of Brazilian municipalities as sf objects
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674).
#'
#' @param year Year of the data. Defaults to `2010`.
#' @param code_muni The 7-digit identification code of a municipality. If
#' `code_muni = "all"` (default), all municipalities of the country will be
#' downloaded. Alternativelly, if the two-digit identification code or a
#' two-letter uppercase abbreviation of a state is passed, e.g. `33` or `"RJ"`,
#' all municipalities of that state will be downloaded. Municipality identification
#' codes are defined in \url{https://www.ibge.gov.br/explica/codigos-dos-municipios.php}.
#' @param simplified Logic `FALSE` or `TRUE`, indicating whether the function
#' returns the data set with original' resolution or a data set with 'simplified'
#' borders. Defaults to `TRUE`. For spatial analysis and statistics users should
#' set `simplified = FALSE`. Borders have been simplified by removing vertices of
#' borders using `sf::st_simplify()` preserving topology with a `dTolerance` of 100.
#' @param showProgress Logical. Defaults to `TRUE` display progress bar
#'
#' @export
#' @family general area functions
#' @examples \donttest{
#' # Read specific municipality at a given year
#' mun <- read_municipality(code_muni = 1200179, year = 2017)
#'
#' # Read all municipalities of a state at a given year
#' mun <- read_municipality(code_muni = 33, year = 2010)
#' mun <- read_municipality(code_muni = "RJ", year = 2010)
#'
#' # Read all municipalities of the country at a given year
#' mun <- read_municipality(code_muni = "all", year = 2018)
#'}
#'
read_municipality <-
  function(code_muni = "all", year = 2010, simplified = TRUE, showProgress = TRUE) {

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="municipality", year=year, simplified=simplified)


# BLOCK 2.1 From 1872 to 1991  ----------------------------

  if( year < 1992){

    # First download the data
      # list paths of files to download
      file_url <- as.character(temp_meta$download_path)

      # download gpkg
      temp_sf <- download_gpkg(file_url, progress_bar = showProgress)

    # if code_muni=="all", simply return the full data set
      if( is.null(code_muni) | code_muni=="all"){ message("Loading data for the whole country\n")
        return(temp_sf)
        }

    # if input is a state code
      else if(nchar(code_muni)==2){

      # invalid state code
      if( !(code_muni %in% substr(temp_sf$code_muni,1,2)) & !(code_muni %in% temp_meta$abbrev_state)){
        stop("Error: Invalid value to argument code_muni")}

        else if (is.numeric(code_muni)){
          x <- code_muni
          temp_sf <- subset(temp_sf, substr(code_muni,1,2)==x)
          return(temp_sf)}

        else if (is.character(code_muni)){
          x <- code_muni
          temp_sf <- subset(temp_sf, substr(abbrev_state,1,2)==x)
          return(temp_sf)}
        }


  # if input is a muni_code
      else if(nchar(code_muni)==7) {

    # invalid muni_code

      if( !( code_muni %in% temp_sf$code_muni)){
        stop("Error: Invalid value to argument code_muni")}

    # valid muni_code
        else {
            x <- code_muni
            temp_sf <- subset(temp_sf, code_muni==x)
            return(temp_sf)}
      }

      else if(nchar(code_muni)!=7 | nchar(code_muni)!=2) {
        stop("Error: Invalid value to argument code_muni")}

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
      sf <- subset(sf, code_state==substr(code_muni, 1, 2))
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

