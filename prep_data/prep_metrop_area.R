library(data.table)
library(readxl)
library(xlsx)
library(stringi)
library(geobr)
library(RCurl)
library(dplyr)
library(readr)
library(sf)
library(lwgeom)
library(magrittr)
library(zoo)
library(future)


library(gdata)
library(baytrends) # ???????
library(stringr)
library(janitor)
library(devtools)



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





###### 0. Create Root folder to save the data -----------------


# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//metropolitan_area"
dir.create(root_dir)
setwd(root_dir)

# 2001_2005
dir_2001_2005 <- "./2001_2005/"
dir.create(paste(dir_2001_2005,"",sep = ""))

# 2010_2018
dir_2010_2018 <- "./2010_2018/"
dir.create(paste(dir_2010_2018,"/",sep = ""))






##### 1. Download original data sets from IBGE ftp -----------------

### construir a lista de caminhos para arquivos no ftp do IBGE
ftp_01_05 <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/municipios_por_regioes_metropolitanas/Situacao_2000a2009/2001a2005/"
filenames = RCurl::getURL(ftp_01_05, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames = unlist(filenames)
filenames <- filenames[!grepl('LEIA_ME', filenames)]
filenames2 <- filenames[!grepl(".02.xls", filenames)]
filenames3 <- filenames[grepl("RM 18.11.02.xls", filenames)]
filenames_01_05 <- c(filenames2,filenames3)


ftp_10_18 <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/municipios_por_regioes_metropolitanas/Situacao_2010a2019/"
filenames <- RCurl::getURL(ftp_10_18, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames <- unlist(filenames)
filenames <- filenames[!grepl('.xlsx', filenames)]
filenames <- filenames[grepl(".xls", filenames)]
filenames_10_18 <- filenames[grepl("_06_|_07_", filenames)]
## não tem dados para 2011 e 2012


### fazer o download dos arquivos

# 2001:2005
for (files in filenames_01_05) {
  download.file( url = paste(ftp_01_05, files, sep = ""),
                 destfile = paste(dir_2001_2005, files, sep = ""),
                 mode = "wb")
  }


# 2010:2018
for (files_ in filenames_10_18) {
  download.file( url = paste(ftp_10_18,files_, sep = ""),
                 destfile = paste(dir_2010_2018, files_, sep = ""),
                 mode = "wb")
}









#### 2. Clean data set and save it in compact .rds format-----------------


#### 2.1 Cleaning date 2001-2005 -----------------

setwd(dir_2001_2005)


#listar arquivos baixados
dados_01_05 <- list.files(pattern = "*.xls", full.names = T)


for (i in 1:4){

  message(paste('working on', dados_01_05[i]))

  # Leitura do arquivo em excel
  dado1 <- readxl::read_excel(path = dados_01_05[i])

  # identifica ano de referencia do arquibo
  year_RM <- paste0(20,substr(dados_01_05[i],12,13))

 # Corrige encoding dos dados
  if (year_RM %like% "2001|2005"){
    names1 <- stri_encode(names(dado1),"utf-8")
    setnames(dado1,names(dado1),names1)
    dado2 <- lapply(dado1, stri_encode, from = "utf-8") %>% as.data.frame()
  } else {
    names1 <- stringi::stri_encode(names(dado1),"WINDOWS-1252")
    setnames(dado1, names(dado1), names1)
    dado2 <- lapply(dado1, stringi::stri_encode, from = "WINDOWS-1252") %>% as.data.frame()
  }


## Coluna name_metro

  # identifica coluna com nome da Regiao Metropolitana
  colname_nome <- grep("R",colnames(dado2), value= T)

  # atualiza nome da coluna e preenche valores NA
  setnames(dado2, colname_nome, "name_metro")

  # preenchendo o campos em branco com a primeira informação acima
  dado2$name_metro <- zoo::na.locf(dado2$name_metro)

## Coluna legislation e legislation_date
  setnames(dado2, "LEGISLAÇÃO", "legislation")

  # identifica coluna problema com data de criacao da lei de Regiao Metropolitana, e renomeia coluna
  colname_data <- grep("DATA",colnames(dado2), value= T)
  setnames(dado2, colname_data, "legislation_date")
  dado2$legislation_date <- gsub(" ","",dado2$legislation_date)

  # preenchendo o campos em branco com a primeira informação acima
  dado2$legislation_date <- zoo::na.locf(dado2$legislation_date)
  dado2$legislation <- zoo::na.locf(dado2$legislation)


## Nome de outras colunas

  if (year_RM %like% "2001|2002|2003"){

    # Coluna code_metro
    setnames(dado2, "CÓDIGO", "code_metro")

    # Coluna code_muni
    colname_codigo <- grep("CÓDIGO_DO_MUN", names(dado2), value = T)
    setnames(dado2, colname_codigo, "code_muni")

    # Coluna name_muni
    colname_nome <- grep("NOME", names(dado2), value = T)
    setnames(dado2, colname_nome, "name_muni")
    dado2$name_muni = NULL

  } else {

    # Identifica nome da coluna
    colname_codigo_ <- grep("CÓDIGO",colnames(dado2),value = T)[1]
    # rename col
    setnames(dado2, colname_codigo_,"code_muni")

    # Coluna name_muni
    setnames(dado2, "MUNICÍPIO", "name_muni")
    dado2$name_muni = NULL

  }


  # transformando code_muni em variável numérica
  dado2$code_muni <- as.numeric(as.character(dado2$code_muni))



# read muni shapes
  if(year_RM %like% "2001|2002|2003"){
    municipios <- geobr::read_municipality(code_muni  = 'all', year=2001)
  } else if (year_RM %like% "2005") {
    municipios <- geobr::read_municipality(code_muni  = 'all', year=year_RM)
  }


# Adiciona dado espacial (coluna geometry)
  dado3 <- dplyr::left_join(dado2, municipios, by = "code_muni") %>% setDT()

# reordena colunas
  setcolorder(dado3, c('name_metro', 'code_muni', 'name_muni', 'legislation', 'legislation_date', 'code_state', 'abbrev_state', 'geometry'))

# set back to spatial sf
  temp_sf <- st_as_sf(dado3, crs=4674)

### Save data
  readr::write_rds(temp_sf, path=paste0('metro_',year_RM,".rds"), compress = "gz")
  unlink(dados_01_05[i])
}

# encoding 2002 e 2003: WINDOWS-1252
# dado1 <- readxl::read_excel(path = dados_01_05[4])
# colnames(dado1)
#




#### 2.2 Cleaning date 2010-2018 -----------------
setwd(paste0(".", dir_2010_2018))

# list all files
dados_10_18 <- list.files(pattern = "*.xls", full.names = T)


# create cleanning function
fun_clean_2010_2018 <- function(i){

  # Read data
  dados1 <- readxl::read_excel(path = i)

  # Fix Encoding
  dados2 <- dados1 %>%
    mutate_if(is.factor, function(x){ x %>% as.character() %>%
        stringi::stri_encode("WINDOWS-1252") } )

  # identifica ano de referencia
  year_RM2 <- substr( i, 37,40)

  # Progress message
  message(paste('working on', year_RM2))

  # O que esse trecho faz ????????????????????????????????????????
  if  (year_RM2 %like% "2015"){
    L <- nrow(dados2)
    a <- (L-3):L
    b <- dados2[-a,]
  }

  # Rename code_muni
  if (year_RM2 %like% "2010|2013|2014|2015"){
    dados2 <- dplyr::rename(dados1, code_muni = `Código Município`)
  } else {
    dados2 <- dplyr::rename(dados1, code_muni = `COD_MUN`)
  }

  # Converte Code muni para numerico
  dados2$code_muni <- as.numeric(as.character(dados2$code_muni))

  # Todos colnames para minusculo
  dados3 <- dados2 %>% setnames(colnames(dados2),tolower(colnames(dados2)))

  # leitura dos dados espaciais
  municipios <- geobr::read_municipality(code_muni  = 'all', year=year_RM2)

  # merge de dados para adicionar coluna espacial 'geometry'
  dados4 <- dplyr::left_join(dados3, municipios)

  # Renomeia colunas (padrao varia em cada ano)
  if(year_RM2 %like% "2010|2013|2014"){
    dados5 <- dplyr::rename(dados4,
                            name_metro = `região metropolitana, ride ou aglomeração urbana`,
                            subdivision = `subdivisões`,
                            legislation = `legislação`,
                            legislation_date = `data lei`,
                            type = tipo
    )
  } else if (year_RM2 %like% "2015") {
    dados5 <- dplyr::rename(dados4,
                            name_metro = `região metropolitana, ride ou aglomeração urbana`,
                            subdivision = `subdivisões`,
                            legislation = `legislação`,
                            legislation_date = `data de publicação da lei`,
                            signature_date = `data de assinatura da lei`,
                            type = tipo
    )
  } else {
    dados5 <- dplyr::rename(dados4,
                            name_metro = `nome_rm`,
                            subdivision = `subdivisao`,
                            legislation = `leg`,
                            legislation_date = `data`,
                            type = tipo)
  }

  if(year_RM2 %like% "2010|2013|2014"){
    dados6 <- dplyr::select(dados5,
                            'code_muni',
                            'name_muni',
                            'code_state',
                            'abbrev_state',
                            'name_metro',
                            'type',
                            'legislation_date',
                            'geometry'
    )
  } else {
    dados6 <- dplyr::select(dados5,
                            'code_muni',
                            'name_muni',
                            'code_state',
                            'abbrev_state',
                            'name_metro',
                            'type',
                            'subdivision',
                            'legislation',
                            'geometry'
    )
  }

  # set back to spatial sf
  temp_sf <- st_as_sf(dados6, crs=4674)

  ### save data
  readr::write_rds(temp_sf, path=paste0('metro_',year_RM2,".rds"), compress = "gz")
  # unlink(dados_10_18[i])
}


# Apply function and create data
lapply(X=dados_10_18, FUN=fun_clean_2010_2018)


# Parallel processing using future.apply
future::plan(future::multiprocess)
future.apply::future_lapply(X = dados_10_18, FUN=fun_clean_2010_2018, future.packages=c('sf', 'dplyr', 'data.table'))

