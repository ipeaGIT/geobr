#' \code{geobr} package
#'
#' Easy access to shapefiles of the Brazilian Institute of Geography and Statistics (IBGE) and other official spatial data sets of Brazil
#'
#' See the README on
#\href{https://cran.r-project.org/package=geobr/README.html}{CRAN}
#' \href{https://github.com/ipeaGIT/geobr#readme}{GitHub}
#'
#' @docType package
#' @name geobr
#' @importFrom utils "tail"
#' @importFrom data.table "%like%"
#' @importFrom curl "has_internet"




# nocov start
NULL

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1")  utils::globalVariables(c('brazil_2010',
                                                        'grid_state_correspondence_table',
                                                        'data',
                                                        'geo',
                                                        'con',
                                                        'code',
                                                        'code_weighting_area',
                                                        'code_muni',
                                                        'code_state',
                                                        'code_abrev',
                                                        'abbrev_state',
                                                        'code_region',
                                                        'name_region',
                                                        'name_muni_format',
                                                        'tp',
                                                        'filesD',
                                                        'temp_meta',
                                                        'group_by',
                                                        'showProgress',
                                                        'year'
                                                        ))

.onLoad <- function(lib, pkg) {
  requireNamespace("sf")
} # nocov end
