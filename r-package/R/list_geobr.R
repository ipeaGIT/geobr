#' List all data sets available in the geobr package
#'
#' @description
#' Returns a data frame with all datasets available in the geobr package
#'
#' @param wide Whether the the output data frame should come in wide (`TRUE`) or
#'        long format (`FALSE`).
#'
#' @return A `data.frame`
#'
#' @export
#' @family support functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' df <- list_geobr()
#'
list_geobr <- function(wide = TRUE){

  checkmate::assert_logical(wide)

  # download metadata
  metadata <- download_metadata2()

  # select cols
  tempdf <- metadata |>
    dplyr::select(alias = geo, year) |>
    unique()

  # reformat to wide
  if (isTRUE(wide)) {
    tempdf <- tempdf |>
      dplyr::group_by(alias) |>
      dplyr::summarise( year = paste0(year, collapse = ', '))
  }

  datasets <- structure(list(
  Function = c(
    "read_country",
    "read_region",
    "read_state",
    "read_meso_region",
    "read_micro_region",
    "read_intermediate_region",
    "read_immediate_region",
    "read_municipality",
    "read_municipal_seat",
    "read_weighting_area",
    "read_census_tract",
    "read_statistical_grid",
    "read_metro_area",
    "read_urban_area",
    "read_amazon",
    "read_biomes",
    "read_conservation_units",
    "read_disaster_risk_area",
    "read_indigenous_land",
    "read_semiarid",
    "read_health_facilities",
    "read_health_region",
    "read_neighborhood",
    "read_schools",
    "read_comparable_areas",
    "read_urban_concentrations",
    "read_pop_arrangements",
    "read_favelas"
    ),
 geography = c(
   "Country",
   "Region",
   "States",
   "Meso region",
   "Micro region",
   "Intermediate region",
   "Immediate region",
   "Municipality",
   "Municipality seats (sedes municipais)",
   "Census weighting area (\u00e1rea de pondera\u00e7\u00e3o)",
   "Census tract (setor censit\u00e1rio)",
   "Statistical Grid (gridded population)",
   "Metropolitan areas",
   "Urban footprints",
   "Brazil's Legal Amazon",
   "Biomes",
   "Environmental Conservation Units",
   "Disaster risk areas",
   "Indigenous lands",
   "Semi Arid region",
   "Health facilities",
   "Health regions and macro regions",
   "Neighborhood limits",
   "Schools",
   "Historically comparable municipalities, aka \u00e1reas m\u00ednimas compar\u00e1veis (AMCs)",
   "Urban concentration areas (concentra\u00e7\u00f5es urbanas)",
   "Population arrangements (arranjos populacionais)",
   "Favelas and urban communities"
 ),
 source = c(
   "IBGE",
   "IBGE",
   "IBGE",
   "IBGE",
   "IBGE",
   "IBGE",
   "IBGE",
   "IBGE",
   "IBGE",
   "IBGE",
   "IBGE",
   "IBGE",
   "IBGE",
   "IBGE",
   "MMA",
   "IBGE",
   "MMA",
   "CEMADEN and IBGE",
   "FUNAI","IBGE",
   "CNES, DataSUS",
   "DataSUS",
   "IBGE",
   "INEP",
   "IBGE",
   "IBGE",
   "IBGE",
   "IBGE"
   ),

 alias = c(
   "country",
   "regions",
   "states",
   "mesoregions",
   "microregions",
   "intermediateregions",
   "immediateregions",
   "municipalities",
   "municipalseats",
   "weightingareas",
   "censustracts",
   "statsgrid",
   "metroareas",
   "urbanareas",
   "amazonialegal",
   "biomes",
   "conservationunits",
   "disasterriskareas",
   "indigenouslands",
   "read_semiarid",
   "healthfacilities",
   "healthregions",
   "neighborhoods",
   "read_schools",
   "read_comparable_areas",
   "urbanconcentrations",
   "poparrangements",
   "favelas"
 )
 ),
 row.names = c(NA, 28L),
 class = "data.frame"
 )




  df <- dplyr::left_join(datasets, tempdf, by  = 'alias') |>
    dplyr::arrange(alias) |>
    dplyr::select(-alias)

  return(df)
}
