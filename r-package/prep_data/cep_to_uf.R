# Geocoding Blood banks in Brazil
# author: Rafael H M Pereira (rafael.pereira@ipea.gov.br)
# last update: 05 Aug 2019

library(magrittr)
library(data.table)
library(dplyr)

# read original data
  bb <- data.table::fread()

# rename CEP column
  names(bb)[3] <- "CEP"

  
# reference
  # https://weber.eti.br/entry/utilidade-faixas-de-cep-por-estado.html
  # https://mundoeducacao.bol.uol.com.br/curiosidades/o-que-significam-os-numeros-cep.htm
  
unique_CEPS[, Estado := ifelse( substr(CEP, 1,1)== 0,   'SP',   # São Paulo
                        ifelse( substr(CEP, 1,1)== 1,   'SP',   # São Paulo
                        ifelse( substr(CEP, 1,1)== 3,   'MG',   # Minas Gerais
                        ifelse( substr(CEP, 1,1)== 9,   'RS',   # Rio Grande do Sul
                        ifelse( substr(CEP, 1,2)==29,   'Es',   # Espirito Santo
                        ifelse( substr(CEP, 1,2)==49,   'SE',   # Sergipe
                        ifelse( substr(CEP, 1,2)==64,   'PI',   # Piauí
                        ifelse( substr(CEP, 1,2)==65,   'MA',   # Maranhão
                        ifelse( substr(CEP, 1,3)==689,  'AP',   # Amapá
                        ifelse( substr(CEP, 1,3)==699,  'AC',   # Acre
                        ifelse( substr(CEP, 1,3)==693,  'RR',   # Roraima
                        ifelse( substr(CEP, 1,2)==77,   'TO',   # Tocantins
                        ifelse( substr(CEP, 1,2)==79,   'MS',   # Mato Grosso do Sul
                        ifelse( substr(CEP, 1,2)==78,   'MT',   # Mato Grosso
                        ifelse( substr(CEP, 1,2)==57,   'AL',   # Alagoas
                        ifelse( substr(CEP, 1,2)==58,   'PB',   # Paraíba
                        ifelse( substr(CEP, 1,2)==59,   'RN',   # Rio Grande do Norte
                        ifelse( between( as.numeric(substr(CEP, 1,2)), left=20, right=28),   'RJ', # Rio de Janeiro
                        ifelse( between( as.numeric(substr(CEP, 1,2)), left=40, right=48),   'BA', # Bahia
                        ifelse( between( as.numeric(substr(CEP, 1,2)), left=80, right=87),   'PR', # Paraba
                        ifelse( between( as.numeric(substr(CEP, 1,2)), left=88, right=89),   'SC', # Santa Catarina
                        ifelse( between( as.numeric(substr(CEP, 1,2)), left=50, right=56),   'PE', # Pernambuco
                        ifelse( between( as.numeric(substr(CEP, 1,2)), left=60, right=63),   'CE', # ceará
                        ifelse( between( as.numeric(substr(CEP, 1,2)), left=66, right=68),   'PA', # Pará
                        ifelse( between( as.numeric(substr(CEP, 1,3)), left=690, right=692), 'AM', # Amazonas
                        ifelse( between( as.numeric(substr(CEP, 1,3)), left=694, right=698), 'AM', # Amazonas
                        ifelse( between( as.numeric(substr(CEP, 1,3)), left=700, right=727), 'DF', # Distrito Federal
                        ifelse( between( as.numeric(substr(CEP, 1,3)), left=730, right=736), 'DF', # Distrito Federal
                        ifelse( between( as.numeric(substr(CEP, 1,3)), left=768, right=769), 'RO', # Rondônia
                        ifelse( between( as.numeric(substr(CEP, 1,3)), left=728, right=729), 'GO', # Goiás
                        ifelse( between( as.numeric(substr(CEP, 1,3)), left=737, right=767), 'GO', 'ERROR')))))))))))))))))))))))))))))))]

head(unique_CEPS)
table(unique_CEPS$Estado)

# save data as input to Galileo
  data.table::fwrite(unique_CEPS, 'C:/Users/r1701707/Downloads/zip-10anos/input_galileo_unique_ceps.csv', sep = ";")
  # unique_CEPS[89518:89519]
  

  
  