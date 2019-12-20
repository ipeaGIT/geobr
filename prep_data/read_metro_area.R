#> DATASET: metropolitan areas 2000 - 2018
#> Source: IBGE - "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/municipios_por_regioes_metropolitanas/"
#: scale ________
#> Metadata:
# Titulo: Regioes Metropolitanas
# Frequencia de atualizacao: Anual
#
# Forma de apresentação: Shape
# Linguagem: Pt-BR
# Character set: Utf-8
#
# Resumo: Poligonos de municipios de regioes metropolitanas do Brasil
# Informações adicionais: Regioes metropolitanas definidas por legislacao estadual
#
# Informacao do Sistema de Referencia: SIRGAS 2000
#
#'
#' @param year A year number in YYYY format
#' @export
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read all official metropolitan areas for a given year
#   d <- read_metro_area(2005)
# }
#
#
#
#
# d <- read_metro_area(2005)

read_metro_area <- function(year){

  # Get metadata with data addresses
  metadata <- download_metadata()

  # Select geo
  temp_meta <- subset(metadata, geo=="metropolitan_area")

  # Verify year input
  if (year %in% temp_meta$year){ message(paste0("Using year ",year))
    temp_meta <- temp_meta[temp_meta[,2] == year,]
  } else { stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                       paste(unique(temp_meta$year),collapse = " ")))
  }

  # list paths of files to download
  filesD <- as.character(temp_meta$download_path)

  # download files
  temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
  httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))

  # read sf
  temp_sf <- readr::read_rds(temps)
  return(temp_sf)
}



# a05 <- read_metro_area(year = 2018)
# plot(a05)
#
