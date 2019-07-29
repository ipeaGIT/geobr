#' Download shape file of Brazil Regions as sf objects. Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @param year Year of the data (defaults to 2010)
#' @export
#' @family general area functions
#' @examples \dontrun{
#'
#' library(geobr)
#'
#' # Read specific year
#'   reg <- read_region(year=2018)
#'
#'}

read_region <- function(year=NULL){

  # read all states
  y <- year
  temp_sf <- read_state(code_state = "all", year = y)

  # merge by Region
  temp_sf <- dplyr::select(temp_sf, 'code_region', 'geometry')
  temp_sf <- dplyr::summarize( group_by(temp_sf, code_region))


  # add region names
  temp_sf <- dplyr::mutate(temp_sf, name_region = ifelse(code_region==1, 'Norte',
                                                            ifelse(code_region==2, 'Nordeste',
                                                                   ifelse(code_region==3, 'Sudeste',
                                                                          ifelse(code_region==4, 'Sul',
                                                                                 ifelse(code_region==5, 'Centro Oeste', NA))))))
  # reorder columns and return sf
  temp_sf <- dplyr::select(temp_sf, 'code_region', 'name_region', 'geometry')
  sf::st_crs(temp_sf)
  return(temp_sf)
}


