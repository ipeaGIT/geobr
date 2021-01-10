# function to determine the state of a given zip code

library(data.table)
  
# reference
  # https://weber.eti.br/entry/utilidade-faixas-de-cep-por-estado.html
  # https://mundoeducacao.bol.uol.com.br/curiosidades/o-que-significam-os-numeros-cep.htm
  
cep_to_state <- function(cep){
  
  cep <- gsub("-", "", cep)
  if(nchar(cep) !=8){stop("CEP input must have 8 digits")}
  
  firstdigits1 <- as.numeric(substr(cep, 1,1))
  firstdigits2 <- as.numeric(substr(cep, 1,2))
  firstdigits3 <- as.numeric(substr(cep, 1,3))
  
  fifelse( firstdigits1 == 0,   'SP',   # São Paulo
  fifelse( firstdigits1 == 1,   'SP',   # São Paulo
  fifelse( firstdigits1 == 3,   'MG',   # Minas Gerais
  fifelse( firstdigits1 == 9,   'RS',   # Rio Grande do Sul
  fifelse( firstdigits2 ==29,   'Es',   # Espirito Santo
  fifelse( firstdigits2 ==49,   'SE',   # Sergipe
  fifelse( firstdigits2 ==64,   'PI',   # Piauí
  fifelse( firstdigits2 ==65,   'MA',   # Maranhão
  fifelse( firstdigits3 ==689,  'AP',   # Amapá
  fifelse( firstdigits3 ==699,  'AC',   # Acre
  fifelse( firstdigits3 ==693,  'RR',   # Roraima
  fifelse( firstdigits2 ==77,   'TO',   # Tocantins
  fifelse( firstdigits2 ==79,   'MS',   # Mato Grosso do Sul
  fifelse( firstdigits2 ==78,   'MT',   # Mato Grosso
  fifelse( firstdigits2 ==57,   'AL',   # Alagoas
  fifelse( firstdigits2 ==58,   'PB',   # Paraíba
  fifelse( firstdigits2 ==59,   'RN',   # Rio Grande do Norte
  fifelse( between( firstdigits2, left=20, right=28),   'RJ', # Rio de Janeiro
  fifelse( between( firstdigits2, left=40, right=48),   'BA', # Bahia
  fifelse( between( firstdigits2, left=80, right=87),   'PR', # Paraba
  fifelse( between( firstdigits2, left=88, right=89),   'SC', # Santa Catarina
  fifelse( between( firstdigits2, left=50, right=56),   'PE', # Pernambuco
  fifelse( between( firstdigits2, left=60, right=63),   'CE', # ceará
  fifelse( between( firstdigits2, left=66, right=68),   'PA', # Pará
  fifelse( between( firstdigits3, left=690, right=692), 'AM', # Amazonas
  fifelse( between( firstdigits3, left=694, right=698), 'AM', # Amazonas
  fifelse( between( firstdigits3, left=700, right=727), 'DF', # Distrito Federal
  fifelse( between( firstdigits3, left=730, right=736), 'DF', # Distrito Federal
  fifelse( between( firstdigits3, left=768, right=769), 'RO', # Rondônia
  fifelse( between( firstdigits3, left=728, right=729), 'GO', # Goiás
  fifelse( between( firstdigits3, left=737, right=767), 'GO', 'ERROR')))))))))))))))))))))))))))))))
  }
  
  
