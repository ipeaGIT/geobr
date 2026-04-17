#' Download spatial data of Brazil's Legal Amazon
#'
#' @description
#' This data set covers the whole of Brazil's Legal Amazon as defined in the
#' federal law n. 12.651/2012). The original data comes from the Brazilian
#' Ministry of Environment (MMA) and can be found at "http://mapas.mma.gov.br/i3geo/datadownload.htm".
#'
#' @template year
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
#' # Read Brazilian Legal Amazon
#' a <- read_amazon(year = 2024)
#'
read_amazon <- function(year = NULL,
                        simplified = TRUE,
                        as_sf = TRUE,
                        showProgress = TRUE,
                        cache = TRUE,
                        verbose = TRUE){

  # Get metadata
  temp_meta <- select_metadata(
    geography="amazonialegal",
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

  # convert to sf
  output <- convert_arrow2sf(temp_arrw, as_sf)

  return(output)
}
