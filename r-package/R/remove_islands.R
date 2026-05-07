#' Remove islands from Brazil
#'
#' @description
#' Removes Brazilian islands that are approximately more than 20 km from the
#' mainland coast. This is useful when analyses or data visualization should
#' focus on the continental territory of Brazil and exclude distant oceanic
#' islands.
#'
#' @param x An 'sf' object with CRS EPSG:4674. Usually an object returned from
#'        other geobr functions, such as `read_country()`, `read_states()`,
#'        `read_municipality()`, or similar functions.
#'
#' @return An `sf` data frame with the same attributes as `x`, but with distant
#'   islands removed from the geometry.
#'
#' @export
#'
#' @examples
#' library(geobr)
#' library(sf)
#'
#' br <- read_country(year=2022)
#'
#' br_no_islands <- remove_islands(br)
#'
#' plot(br)
remove_islands <- function(x){

  # Check input class
  checkmate::assert_class(x, classes = "sf")

  # Check input CRS
  x_crs <- sf::st_crs(x)

  if (!identical(x_crs$epsg, 4674L)) {
    cli::cli_abort(
      "{.arg x} must have CRS EPSG:4674 / SIRGAS 2000."
    )
  }

  # Path to simplified offshore buffer of Brazil, approximately 20 km from shore
  br_offcoast_path <- system.file(
    "extdata/br_offcoast.parquet",
    package = "geobr",
    mustWork = TRUE
  )

  br_offcoast <- br_offcoast_path |>
    arrow::open_dataset() |>
    sf::st_as_sf()

  # Fix eventual invalid geometries from input
  x <- duckspatial::ddbs_make_valid(x)

  # remove islands
  no_islands <- duckspatial::ddbs_difference(
    x = x,
    y = br_offcoast
    ) |>
    duckspatial::ddbs_collect()

  return(no_islands)
}
