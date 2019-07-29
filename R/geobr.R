#' \code{geobr} package
#'
#' Easy access to shapefiles of the Brazilian Institute of Geography and Statistics (IBGE) and other official spatial data sets of Brazil
#'
#' See the README on
#' \href{https://cran.r-project.org/package=geobr/README.html}{CRAN}
#' or \href{https://github.com/ipeaGIT/geobr#readme}{GitHub}
#'
#' @docType package
#' @name geobr
#' @importFrom dplyr %>%
#' @importFrom("utils", "data", "tail")
NULL

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))
