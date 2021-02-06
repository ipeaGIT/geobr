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
#' uf <- cep_to_state(cep = '69900-000')
#'
#' # Or:
#' uf <- cep_to_state(cep = 69900000)
#'}
#'
cep_to_state <- function(cep){

  # reference
  # https://help.commerceplus.com.br/hc/pt-br/articles/115008224967-Faixas-de-CEP-por-Estado
  # https://mundoeducacao.bol.uol.com.br/curiosidades/o-que-significam-os-numeros-cep.htm

  cep <- gsub("-", "", cep)

  suppressWarnings({ firstdigits1 <- as.numeric(substr(cep, 1,1)) })
  suppressWarnings({ firstdigits2 <- as.numeric(substr(cep, 1,2)) })
  suppressWarnings({ firstdigits3 <- as.numeric(substr(cep, 1,3)) })

  if(is.na(firstdigits3)){stop("'cep' input must have numerical digits.")}

  ifelse( firstdigits1 == 0,   'SP',   # Sao Paulo
  ifelse( firstdigits1 == 1,   'SP',   # Sao Paulo
  ifelse( firstdigits1 == 3,   'MG',   # Minas Gerais
  ifelse( firstdigits1 == 9,   'RS',   # Rio Grande do Sul
  ifelse( firstdigits2 ==29,   'Es',   # Espirito Santo
  ifelse( firstdigits2 ==49,   'SE',   # Sergipe
  ifelse( firstdigits2 ==64,   'PI',   # Piaui
  ifelse( firstdigits2 ==65,   'MA',   # Maranhao
  ifelse( firstdigits3 ==689,  'AP',   # Amapa
  ifelse( firstdigits3 ==699,  'AC',   # Acre
  ifelse( firstdigits3 ==693,  'RR',   # Roraima
  ifelse( firstdigits2 ==77,   'TO',   # Tocantins
  ifelse( firstdigits2 ==79,   'MS',   # Mato Grosso do Sul
  ifelse( firstdigits2 ==78,   'MT',   # Mato Grosso
  ifelse( firstdigits2 ==57,   'AL',   # Alagoas
  ifelse( firstdigits2 ==58,   'PB',   # Paraiba
  ifelse( firstdigits2 ==59,   'RN',   # Rio Grande do Norte
  ifelse( firstdigits2 >20  & firstdigits2 <28,  'RJ', # Rio de Janeiro
  ifelse( firstdigits2 >40  & firstdigits2 <48,  'BA', # Bahia
  ifelse( firstdigits2 >80  & firstdigits2 <87,  'PR', # Parana
  ifelse( firstdigits2 >88  & firstdigits2 <89,  'SC', # Santa Catarina
  ifelse( firstdigits2 >50  & firstdigits2 <56,  'PE', # Pernambuco
  ifelse( firstdigits2 >60  & firstdigits2 <63,  'CE', # ceara
  ifelse( firstdigits2 >66  & firstdigits2 <68,  'PA', # Para
  ifelse( firstdigits3 >690 & firstdigits3 <692, 'AM', # Amazonas
  ifelse( firstdigits3 >694 & firstdigits3 <698, 'AM', # Amazonas
  ifelse( firstdigits3 >700 & firstdigits3 <727, 'DF', # Distrito Federal
  ifelse( firstdigits3 >730 & firstdigits3 <736, 'DF', # Distrito Federal
  ifelse( firstdigits3 >768 & firstdigits3 <769, 'RO', # Rondonia
  ifelse( firstdigits3 >728 & firstdigits3 <729, 'GO', # Goias
  ifelse( firstdigits3 >737 & firstdigits3 <767, 'GO', 'ERROR')))))))))))))))))))))))))))))))
}
