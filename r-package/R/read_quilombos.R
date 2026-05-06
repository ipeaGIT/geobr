#' Download spatial data of quilombola lands in Brazil
#'
#' @description
#' Read data of quilombola areas officialy recognized by the Instituto Nacional
#' de Colonização e Reforma Agrária - INCRA. The `date` refers to the date when
#' the data was downloaded, and captures the quilombola lands recognized on that
#' date. More info at \url{https://dados.gov.br/dados/conjuntos-dados/comunidades-quilombolas-certificadas}.
#'
#' @template date
#' @template code_state
#' @template simplified
#' @template as_sf
#' @template showProgress
#' @template cache
#' @template verbose
#'
#' @return An `"sf" "data.frame"` OR an `ArrowObject`
#'
#' @section Data dictionary:
#' - `code_quilombo` - Código da Comunidade Quilombola (para controle interno)
#' - `name_quilombo` - Nome da Comunidade Quilombola
#' - `code_sr` - Código da Superintendência Regional
#' - `n_process` - Número do processo de titulação de terras, junto ao Instituto Nacional de Colonização e Reforma Agrária - INCRA
#' - `name_muni` - Nome do Município em que está localizada
#' - `abbrev_state` - Sigla da Unidade Federativa em que está localizada
#' - `code_state` - Código da Unidade Federativa em que está localizada
#' - `date_recog` - Data de publicação da portaria de reconhecimento pelo presidente do INCRA
#' - `date_decree_pr` - Decreto da presidência da República para fins de desapropriação, por interesse social
#' - `date_decree` - Data decreto de regularização do território
#' - `date_titulacao`  - Data da titulação das terras
#' - `code_sipra` - Código no Sistema de Informações de Projetos de Reforma Agrária - SIPRA
#' - `n_family` - Número de famílias
#' - `perimeter` - Perímetro calculado depois da medição/demarcação (georreferenciamento) para fins de certificação
#' - `area_ha` - Área em hectares
#' - `geo_scale` - Escala utilizada para mapeamento
#' - `stage` - Fase do processo
#' - `gov_level` - Nível da esfera administrativa responsável
#' - `responsible_unit` - Órgão responsável
#'
#' @export
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read all quilombola areas in an specific date
#' q <- read_quilombola_land(date = 202605)
#'
#' # Read the quilombola areas in an given state
#' ba <- read_quilombola_land(date = 202605, code_state = "BA")
#'
read_quilombola_land <- function(date,
                                 code_state = "all",
                                 simplified = TRUE,
                                 as_sf = TRUE,
                                 showProgress = TRUE,
                                 cache = TRUE,
                                 verbose = TRUE){

  # Get metadata
  temp_meta <- select_metadata(
    geography = "quilombolalands",
    year = date,
    simplified = simplified,
    verbose = verbose
  )

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
  temp_arrw <- filter_arrw(temp_arrw, code = code_state)

  # convert to sf
  output <- convert_arrow2sf(temp_arrw, as_sf)

  return(output)

}
