#' Determine the state of a given CEP postal code
#'
#' Zips codes in Brazil are known as CEP, the abbreviation for postal code address.
#' CEPs in Brazil are 8 digits long, with the format 'xxxxx-xxx'.
#'
#' @param cep A numeric string with 8 digits in the format xxxxxxxx, or a
#'            character with the format 'xxxxx-xxx'.
#' @return A character string with a state abbreviation
#' @export
#' @examples \donttest{
#' library(geobr)
#'
#' uf <- cep_to_state(cep = '69900-000')
#' # or
#' uf <- cep_to_state(cep = 69900000)
#'}
#'
cep_to_state <- function(cep){

  # reference
  # https://help.commerceplus.com.br/hc/pt-br/articles/115008224967-Faixas-de-CEP-por-Estado
  # https://mundoeducacao.bol.uol.com.br/curiosidades/o-que-significam-os-numeros-cep.htm

  cep <- gsub("-", "", cep)

  firstdigits1 <- as.numeric(substr(cep, 1,1))
  firstdigits2 <- as.numeric(substr(cep, 1,2))
  firstdigits3 <- as.numeric(substr(cep, 1,3))

  fifelse( firstdigits1 == 0,   'SP',   # Sao Paulo
  fifelse( firstdigits1 == 1,   'SP',   # Sao Paulo
  fifelse( firstdigits1 == 3,   'MG',   # Minas Gerais
  fifelse( firstdigits1 == 9,   'RS',   # Rio Grande do Sul
  fifelse( firstdigits2 ==29,   'Es',   # Espirito Santo
  fifelse( firstdigits2 ==49,   'SE',   # Sergipe
  fifelse( firstdigits2 ==64,   'PI',   # Piaui
  fifelse( firstdigits2 ==65,   'MA',   # Maranhao
  fifelse( firstdigits3 ==689,  'AP',   # Amapa
  fifelse( firstdigits3 ==699,  'AC',   # Acre
  fifelse( firstdigits3 ==693,  'RR',   # Roraima
  fifelse( firstdigits2 ==77,   'TO',   # Tocantins
  fifelse( firstdigits2 ==79,   'MS',   # Mato Grosso do Sul
  fifelse( firstdigits2 ==78,   'MT',   # Mato Grosso
  fifelse( firstdigits2 ==57,   'AL',   # Alagoas
  fifelse( firstdigits2 ==58,   'PB',   # Paraiba
  fifelse( firstdigits2 ==59,   'RN',   # Rio Grande do Norte
  fifelse( between( firstdigits2, lower=20, upper=28),   'RJ', # Rio de Janeiro
  fifelse( between( firstdigits2, lower=40, upper=48),   'BA', # Bahia
  fifelse( between( firstdigits2, lower=80, upper=87),   'PR', # Parana
  fifelse( between( firstdigits2, lower=88, upper=89),   'SC', # Santa Catarina
  fifelse( between( firstdigits2, lower=50, upper=56),   'PE', # Pernambuco
  fifelse( between( firstdigits2, lower=60, upper=63),   'CE', # ceara
  fifelse( between( firstdigits2, lower=66, upper=68),   'PA', # Para
  fifelse( between( firstdigits3, lower=690, upper=692), 'AM', # Amazonas
  fifelse( between( firstdigits3, lower=694, upper=698), 'AM', # Amazonas
  fifelse( between( firstdigits3, lower=700, upper=727), 'DF', # Distrito Federal
  fifelse( between( firstdigits3, lower=730, upper=736), 'DF', # Distrito Federal
  fifelse( between( firstdigits3, lower=768, upper=769), 'RO', # Rondônia
  fifelse( between( firstdigits3, lower=728, upper=729), 'GO', # Goiás
  fifelse( between( firstdigits3, lower=737, upper=767), 'GO', 'ERROR')))))))))))))))))))))))))))))))
}
