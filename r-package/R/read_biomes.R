#' Download spatial data of Brazilian biomes
#'
#' @description
#' This data set includes  polygons of all biomes present in the Brazilian territory
#' and coastal area. Data comes from IBGE. More information at \url{https://www.ibge.gov.br/apps/biomas/}
#'
#' @template year
#' @template simplified
#' @template output
#' @template showProgress
#' @template cache
#' @template verbose
#'
#' @return An `"sf" "data.frame"` OR an `ArrowObject`
#'
#' @export
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read biomes
#' b <- read_biomes(year = 2025)
#'
read_biomes <- function(year,
                        simplified = TRUE,
                        output = "sf",
                        showProgress = TRUE,
                        cache = TRUE,
                        verbose = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography="biomes",
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
    temp <- convert_arrow2sf(temp_arrw, output)

    return(temp)
}
