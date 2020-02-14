#' Download shape files of Brazil's Intermediate Geographic Areas as sf objects.
#'
#' The intermediate Geographic Areas are part of the geographic division of Brazil created in 2017 by IBGE to
#' replace the "Meso Regions" division. Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @param year A date number in YYYY format (defaults to 2017)
#' @param code_intermediate 4-digit code of an intermediate region. If the two-digit code or a two-letter uppercase abbreviation of
#'  a state is passed, (e.g. 33 or "RJ") the function will load all intermediate regions of that state. If code_intermediate="all",
#'  all intermediate regions of the country are loaded (defaults to "all").
#' @param mode Whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Default)
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read an specific intermediate region
#'   im <- read_intermediate_region(code_intermediate=1202)
#'
#' # Read intermediate regions of a state
#'   im <- read_intermediate_region(code_intermediate=12)
#'   im <- read_intermediate_region(code_intermediate="AM")
#'
#'# Read all intermediate regions of the country
#'   im <- read_intermediate_region()
#'   im <- read_intermediate_region(code_intermediate="all")
#' }
#'
#'
read_intermediate_region <- function(code_intermediate= NULL, year = NULL, mode="simplified"){

  # Get metadata with data addresses
  metadata <- download_metadata()

  # Select geo
  temp_meta <- subset(metadata, geo=="intermediate_regions")

  # 1.1 Verify year input
  if (is.null(year)){ year <- 2017
  message(paste0("Using data from year ", year))}

  if(!(year %in% temp_meta$year)){ stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                                               paste(unique(temp_meta$year),collapse = " ")))
  } else {

    # # Select metadata year
    x <- year
    temp_meta <- subset(temp_meta, year==x)

    # list paths of files to download
    filesD <- as.character(temp_meta$download_path)

    # download files
    temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))

    # read sf
    temp_sf <- readr::read_rds(temps)

  }

  if(is.null(code_intermediate)){ message("Loading data for the whole country. This might take a few minutes.\n")

  } else if(code_intermediate=="all"){ message("Loading data for the whole country. This might take a few minutes.\n")

    # abbrev_state
  } else if(code_intermediate %in% temp_sf$abbrev_state){
    y <- code_intermediate
    temp_sf <- subset(temp_sf, abbrev_state == y)

    # code_state
  } else if(code_intermediate %in% temp_sf$code_state){
    y <- code_intermediate
    temp_sf <- subset(temp_sf, code_state == y)

    # code_intermediate
  } else if(code_intermediate %in% temp_sf$code_intermediate){
    y <- code_intermediate
    temp_sf <- subset(temp_sf, code_intermediate == y)

  } else {stop(paste0("Error: Invalid Value to argument 'code_intermediate'",collapse = " "))}

  return(temp_sf)
}
