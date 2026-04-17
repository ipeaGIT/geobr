#' Download spatial data of census tracts of the Brazilian Population Census
#'
#' @description
#' Download spatial data of census tracts of the Brazilian Population Census
#'
#' @template year
#' @param code_tract The 7-digit code of a Municipality. If the two-digit code
#'         or a two-letter uppercase abbreviation of a state is passed, (e.g. 33
#'         or "RJ") the function will load all census tracts of that state. If
#'         `code_tract="all"`, the function downloads all census tracts of the
#'         country.
#' @param zone For census tracts before 2010, 'urban' and 'rural' census tracts
#'             are separate data sets.
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
#'
#' # Read all census tracts of a state at a given year
#' c <- read_census_tract(code_tract = "DF", year = 2022) # or
#' c <- read_census_tract(code_tract = 53, year = 2022)
#'
#' # Read all census tracts of a municipality at a given year
#' c <- read_census_tract(year = 2022, code_tract = 5201108)
#'
#' # Read all census tracts of the country at a given year
#' c <- read_census_tract(year = 2022, code_tract = "all")
#'
#' # Read rural census tracts for years before 2007
#' c <- read_census_tract(code_tract = 5201108, year = 2000, zone = "rural")
#'
read_census_tract <- function(year,
                              code_tract,
                              zone = "urban",
                              simplified = TRUE,
                              as_sf = TRUE,
                              showProgress = TRUE,
                              cache = TRUE,
                              verbose = TRUE){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(
    geography = "censustracts",
    year = year,
    simplified = simplified
    )

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # Check zone input urban and rural inputs if year <=2007
  if (temp_meta$year[1] <= 2007) {

    temp_meta <- temp_meta |>
      dplyr::filter(geo %like% zone)

    if (nrow(temp_meta) == 0) {
      cli::cli_abort("Invalid Value to argument 'zone'. It must be either 'urban' or 'rural'")
    }

  }


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
  temp_arrw <- filter_arrw(temp_arrw, code = code_tract)

  # convert to sf
  output <- convert_arrow2sf(temp_arrw, as_sf)

  return(output)


  }
