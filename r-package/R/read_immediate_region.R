#' Download shape files of Brazil's Immediate Geographic Areas as sf objects
#'
#' The Immediate Geographic Areas are part of the geographic division of Brazil created in 2017 by IBGE to
#' replace the "Micro Regions" division. Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @param year A date number in YYYY format (defaults to 2017)
#' @param code_immediate 6-digit code of an immediate region. If the two-digit code or a two-letter uppercase abbreviation of
#'  a state is passed, (e.g. 33 or "RJ") the function will load all immediate regions of that state. If code_immediate="all",
#'  all immediate regions of the country are loaded (defaults to "all").
#' @param simplified Logic FALSE or TRUE, indicating whether the function returns the
#' data set with 'original' resolution or a data set with 'simplified' borders (Defaults to TRUE).
#' For spatial analysis and statistics users should set simplified = FALSE. Borders have been
#' simplified by removing vertices using st_simplify{sf} preserving topology with a dTolerance of 100.
#' @param showProgress Logical. Defaults to (TRUE) display progress bar
#' @param tp Argument deprecated. Please use argument 'simplified'
#'
#' @export
#' @family general area functions
#' @examples \dontrun{
#'
#' library(geobr)
#'
#' # Read an specific immediate region
#'   im <- read_immediate_region(code_immediate=110006)
#'
#' # Read immediate regions of a state
#'   im <- read_immediate_region(code_immediate=12)
#'   im <- read_immediate_region(code_immediate="AM")
#'
#'# Read all immediate regions of the country
#'   im <- read_immediate_region()
#'   im <- read_immediate_region(code_immediate="all")
#' }
#'
#'
read_immediate_region <- function(code_immediate="all", year=2017, simplified=TRUE, showProgress=TRUE, tp){

  # deprecated 'tp' argument
  if (!missing("tp")){stop(" 'tp' argument deprecated. Please use argument 'simplified' TRUE or FALSE")}

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="immediate_regions", year=year, simplified=simplified)

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path)

  # download files
  temp_sf <- download_gpkg(file_url, progress_bar = showProgress)


  # check code_immediate input
  if(code_immediate=="all"){ message("Loading data for the whole country. This might take a few minutes.\n")

  # abbrev_state
  } else if(code_immediate %in% temp_sf$abbrev_state){
    y <- code_immediate
    temp_sf <- subset(temp_sf, abbrev_state == y)

  # code_state
  } else if(code_immediate %in% temp_sf$code_state){
    y <- code_immediate
    temp_sf <- subset(temp_sf, code_state == y)

  # code_immediate
  } else if(code_immediate %in% temp_sf$code_immediate){
    y <- code_immediate
    temp_sf <- subset(temp_sf, code_immediate == y)

  } else {stop(paste0("Error: Invalid Value to argument 'code_immediate'",collapse = " "))}

  return(temp_sf)
}
