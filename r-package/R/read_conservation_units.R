#' Download spatial data of Brazilian environmental conservation units
#'
#' @description
#' This data set covers the whole of Brazil and it includes the polygons of all
#' conservation units present in Brazilian territory. The original data and data
#' dictionary can be found comes from MMA and can be found at "https://dados.mma.gov.br/dataset/unidadesdeconservacao".
#'
#' @template date
#' @template simplified
#' @template as_sf
#' @template showProgress
#' @template cache
#' @template verbose
#'
#' @return An `"sf" "data.frame"` OR an `ArrowObject`
#'
#' @export
#' @family general area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read conservation_units
#' uc <- read_conservation_units(date = 202503)
#'
read_conservation_units <- function(date,
                                    simplified = TRUE,
                                    as_sf = TRUE,
                                    showProgress = TRUE,
                                    cache = TRUE,
                                    verbose = TRUE){

  # Get metadata
  temp_meta <- select_metadata(
    geography="conservationunits",
    year = date,
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

  # convert to sf
  output <- convert_arrow2sf(temp_arrw, as_sf)

  return(output)

}
