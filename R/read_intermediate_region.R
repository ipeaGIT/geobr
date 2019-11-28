#' Download shape files of Brazil's Intermediate Geographic Areas as sf objects.
#'
#' The intermediate Geographic Areas are part of the geographic division of Brazil created in 2017 by IBGE to
#' replace the "Meso Regions" division. Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @param year A date number in YYYY format (defaults to 2017)
#' @param code_intermediate 6-digit code of an intermediate region. If the two-digit code or a two-letter uppercase abbreviation of
#'  a state is passed, (e.g. 33 or "RJ") the function will load all intermediate regions of that state. If code_micro="all",
#'  all micro regions of the country are loaded (defaults to "all").
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read an specific intermediate region
#'   im <- read_intermediate_region(code_intermediate=110006)
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
read_rgint <- function(code_rgint, year = NULL){


  # Get metadata with data addresses
  metadata <- geobr::download_metadata()

  # verify input type
  #if(is.null(type)){type <- "reg_mun"}
  #if(all(type != c("rgint","rgi","reg_mun"))) stop("type must be 'rgint' or 'rgi' or 'reg_mun'")

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

    if(code_rgint=="all"){ message("Loading data for the whole country. This might take a few minutes.\n")
     temp_sf <- temp_sf
    } else if(code_rgint %in% temp_sf$abbrev_state){
      y <- code_rgint
      temp_sf <- subset(temp_sf, abbrev_state == y)
    } else if(code_rgint %in% temp_sf$code_state){
      y <- code_rgint
      temp_sf <- subset(temp_sf, code_state == y)
    } else {stop(paste0("Error: Invalid Value to argument 'code_rgint'. UF must be valid",collapse = " "))}

  return(temp_sf)
}
