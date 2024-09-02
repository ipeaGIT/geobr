#' Download spatial data of Brazilian health regions and health macro regions
#'
#' @description
#' Health regions are used to guide the the regional and state planning of health services.
#' Macro health regions, in particular, are used to guide the planning of high complexity
#' health services. These services involve larger economics of scale and are concentrated in
#' few municipalities because they are generally more technology intensive, costly and face
#' shortages of specialized professionals. A macro region comprises one or more health regions.
#'
#' @param year Numeric. Year of the data in YYYY format. Defaults to `2013`, the
#'        latest available.
#' @param macro Logic. If `FALSE` (default), the function downloads health
#'        regions data. If `TRUE`, the function downloads macro regions data.
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
#' # Read all health regions for a given year
#' hr <- read_health_region( year=2013 )
#'
#' # Read all macro health regions
#' mhr <- read_health_region( year=2013, macro =TRUE)
#'
read_health_region <- function(year = 2013,
                               macro = FALSE,
                               simplified = TRUE,
                               showProgress = TRUE,
                               cache = TRUE){

  if(!is.logical(macro)){stop(paste0("Parameter 'macro' must be either TRUE or FALSE"))}

  # Get metadata with data url addresses
  if(macro==FALSE){
      temp_meta <- select_metadata(geography="health_region", year=year, simplified=simplified)
      } else {
      temp_meta <- select_metadata(geography="health_region_macro", year=year, simplified=simplified)
      }

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
