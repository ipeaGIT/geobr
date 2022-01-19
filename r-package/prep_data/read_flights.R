#' Download flights data from ANAC

#' @examples \dontrun{ if (interactive()) {
#' # Read flights data
#' a201506 <- read_flights(year=2015, month=6)
#'}}
read_flights <- function(year=2000, month=3, type='basica'){

  ## check inputs
  # type
  if( ! type %in% c('basica', 'combinada') ){ stop(paste0("Argument 'type' must be either 'basica' or 'combinada'")) }

  # year and months perhaps use yyyymm ?


  # prepare address of online data
  if( nchar(month) ==1 ) { month <- paste0('0', month)}
  url_root <- 'https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/envio-de-informacoes/microdados/'
  file_name <- paste0(type, year, '-', month, '.zip')
  file_url <- paste0(url_root, file_name)

  # download to a local file
  temp_local_file <- tempfile( file_name )
  # utils::download.file(url = file_url, destfile = temp_local_file)

  try(
  httr::GET(url=file_url,
                 httr::progress(),
                 httr::write_disk(temp_local_file, overwrite = T),
                 config = httr::config(ssl_verifypeer = FALSE)
  )
  , silent = F)


  # read zipped file stored locally
  temp_local_file_zip <- paste0('unzip -p ', temp_local_file)
  df <- data.table::fread( cmd =  temp_local_file_zip)
  return(df)

}



