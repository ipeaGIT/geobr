#' Download spatial data of Brazilian states
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @template year
#' @param code_state The two-digit code of a state or a two-letter uppercase
#'                   abbreviation (e.g. 33 or "RJ"). If `code_state="all"` (the
#'                   default), the function downloads all states.
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
#' # Read specific state at a given year
#'   uf <- read_state(code_state=12, year=2017)
#'
#' # Read specific state at a given year
#'   uf <- read_state(code_state="SC", year=2000)
#'
#' # Read all states at a given year
#'   ufs <- read_state(code_state="all", year=2024)
#'
read_state <- function(year = NULL,
                       code_state = "all",
                       simplified  = TRUE,
                       as_sf = TRUE,
                       showProgress = TRUE,
                       cache = TRUE,
                       verbose = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography="states",
    year = year,
    simplified = simplified,
    verbose = verbose
  )

  # check if metadata download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # download files
  temp_arrw <- download_parquet(
    filename_to_download = temp_meta$file_name,
    showProgress,
    cache
    )

  # check if download failed
  if (is.null(temp_arrw)) { return(invisible(NULL)) }

  # FILTER
  temp_arrw <- filter_arrw(temp_arrw, code = code_state)

  # convert to sf
  if(isTRUE(as_sf)){
    temp_arrw <- sf::st_as_sf(temp_arrw)
  }

  return(temp_arrw)

  }
