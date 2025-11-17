#' Download spatial data of IBGE's statistical grid
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @template year
#' @param code_grid If two-letter abbreviation or two-digit code of a state is
#'                  passed, the function will load all grid quadrants that
#'                  intersect with that state. If `code_grid="all"`, the grid of
#'                  the whole country will be loaded. Users may also pass a
#'                  grid quadrant id to load an specific quadrant. Quadrant ids
#'                  can be consulted at `geobr::grid_state_correspondence_table`.
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
#' # Read a particular grid at a given year
#' grid <- read_statistical_grid(code_grid = 45, year=2010)
#'
#' # Read the grid covering a given state at a given year
#' state_grid <- read_statistical_grid(code_grid = "RJ")
#'
read_statistical_grid <- function(year = NULL,
                                  code_grid,
                                  as_sf = TRUE,
                                  showProgress = TRUE,
                                  cache = TRUE,
                                  verbose = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography="statsgrid",
    year = year,
    simplified = FALSE,
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
  temp_arrw <- filter_arrw(temp_arrw, code = code_grid)

  # convert to sf
  if(isTRUE(as_sf)){
    temp_arrw <- sf::st_as_sf(temp_arrw)
  }

  return(temp_arrw)

}
