#' Download shape file of Brazil Regions as sf objects. Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @param year Year of the data (defaults to 2010)
#' @export
#' @family general area functions
#' @examples \donttest{
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
  temp_sf <- geobr::read_state(code_state = "all", year = y)

  # subset columns
  temp_sf <- temp_sf[,c("code_region","geometry")]

  # merge by Region
  system.time(  temp_sf <- aggregate(temp_sf, list(temp_sf$code_region), head, n=1) )

  #clean columns and add region names
  temp_sf$Group.1 <- NULL
  temp_sf$name_region <- ifelse(temp_sf$code_region==1, 'Norte',
                                ifelse(temp_sf$code_region==2, 'Nordeste',
                                       ifelse(temp_sf$code_region==3, 'Sudeste',
                                              ifelse(temp_sf$code_region==4, 'Sul',
                                                     ifelse(temp_sf$code_region==5, 'Centro Oeste', NA)))))

  # reorder columns and return sf
  temp_sf <- temp_sf[, c('code_region', 'name_region', 'geometry')]
  return(temp_sf)
}
