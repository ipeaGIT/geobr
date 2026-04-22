#' Download spatial data of Census Weighting Areas (area de ponderacao) of the Brazilian Population Census
#'
#' @description
#' Only 2010 data is currently available.
#'
#' @template year
#' @param code_weighting The 7-digit code of a Municipality. If the two-digit code
#' or a two-letter uppercase abbreviation of a state is passed, (e.g. 33 or "RJ")
#' the function will load all weighting areas of that state. If `code_weighting="all"`,
#' all weighting areas of the country are loaded.
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
#' # Read specific weighting area at a given year
#' w <- read_weighting_area(code_weighting=5201108005004, year=2010)
#'
#' # Read all weighting areas of a state at a given year
#' w <- read_weighting_area(code_weighting=53, year=2010) # or
#' w <- read_weighting_area(code_weighting="DF", year=2010)
#' plot(w)
#'
#' # Read all weighting areas of a municipality at a given year
#' w <- read_weighting_area(code_weighting=5201108, year=2010)
#' plot(w)
#'
#' # Read all weighting areas of the country at a given year
#' w <- read_weighting_area(code_weighting="all", year=2010)
#'
read_weighting_area <- function(year,
                                code_weighting,
                                simplified = TRUE,
                                as_sf = TRUE,
                                showProgress = TRUE,
                                cache = TRUE,
                                verbose = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography = "weightingareas",
    year = year,
    simplified = simplified
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
  temp_arrw <- filter_arrw(temp_arrw, code = code_weighting)

  # convert to sf
  output <- convert_arrow2sf(temp_arrw, as_sf)

  return(output)

}


