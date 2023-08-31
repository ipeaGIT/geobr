#' Download geolocated data of schools
#'
#' @description
#' Data comes from the School Census collected by INEP, the National Institute
#' for Educational Studies and Research Anisio Teixeira. The date of the last
#' data update is registered in the database in the column 'date_update'. These
#' data uses Geodetic reference system "SIRGAS2000" and CRS(4674). The coordinates
#' of each school if collected by INEP. Periodically the coordinates are revised
#' with the objective of improving the quality of the data. More information
#' available at \url{https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/inep-data/catalogo-de-escolas/}
#'
#' @param year Numeric. Year of the data in YYYY format. Defaults to `2020`.
#' @template showProgress
#'
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read all schools in the country
#' s <- read_schools( year = 2020)
#'
read_schools <- function(year=2020, showProgress=TRUE ){

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="schools", year=year, simplified=F)

  # list paths of files to download
    file_url <- as.character(temp_meta$download_path)

  # download files
    temp_sf <- download_gpkg(file_url, progress_bar = showProgress)

    # check if download failed
    if (is.null(temp_sf)) { return(invisible(NULL)) }

    return(temp_sf)

    }
