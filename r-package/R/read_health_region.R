#' Download spatial data of Brazilian health regions and health macro regions
#'
#' @description
#' Health regions are used to guide the the regional and state planning of health
#' services. Macro health regions, in particular, are used to guide the planning
#' of high complexity #' health services. These services involve larger economics
#' of scale and are concentrated in few municipalities because they are generally
#' more technology intensive, costly and face shortages of specialized
#' professionals. A macro region comprises one or more health regions.
#'
#' @template year
#' @template code_state
#' @param macro Logic. If `FALSE` (default), the function downloads health
#'        regions data. If `TRUE`, the function downloads macro regions data.
#' @template simplified
#' @template as_sf
#' @template showProgress
#' @template cache
#' @template verbose
#'
#' @return An `"sf" "data.frame"` OR an `ArrowObject`
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read all health regions for a given year
#' hr <- read_health_region(year = 2024 )
#'
#' # Read all macro health regions
#' mhr <- read_health_region(year=2024, macro =TRUE)
#'
read_health_region <- function(year,
                               code_state = "all",
                               macro = FALSE,
                               simplified = TRUE,
                               as_sf = TRUE,
                               showProgress = TRUE,
                               cache = TRUE,
                               verbose = TRUE){

  if(!is.logical(macro)){stop(paste0("Parameter 'macro' must be either TRUE or FALSE"))}

  # determine which geography to use
  temp_geo <- ifelse(macro==TRUE, "health_region_macro", "health_region")

  # Get metadata
  temp_meta <- select_metadata(
    geography = "healthregions",
    year = year,
    simplified = simplified,
    verbose = verbose
  )

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # download file and open arrow dataset
  temp_arrw <- download_parquet(
    filename_to_download = temp_meta$file_name,
    showProgress = showProgress,
    cache = cache
  )

  # check if download failed
  if (is.null(temp_arrw)) { return(invisible(NULL)) }

  # FILTER
  temp_arrw <- filter_arrw(temp_arrw, code = code_state)

  # convert to sf
  output <- convert_arrow2sf(temp_arrw, as_sf)

  return(output)

# a <- duckspatial::ddbs_union_agg(x = output, by = "code_health_region") |>
#   duckspatial::ddbs_collect() |>
#   sfheaders::sf_remove_holes()
# mapview::mapview(a)

}

