library(gdata)
library(readxl)
library(data.table)
library(xlsx)
library(stringi)
library(dplyr)
library(baytrends)
library(zoo)
library(geobr)
library(RCurl)
library(stringr)
library(sf)
library(janitor)
library(dplyr)
library(readr)
#library(parallel)
library(xlsx)
library(magrittr)
library(devtools)
library(lwgeom)

# #### 0. Download original data sets from IBGE ftp -----------------
#
ftp <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/municipios_por_regioes_metropolitanas/"
#
#
# ########  1. Unzip original data sets downloaded from IBGE -----------------
#
# # Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//metropolitan_area"
dir.create(root_dir)
setwd(root_dir)
#
#
#construir a lista de caminhos
ftp_01_05 <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/municipios_por_regioes_metropolitanas/Situacao_2000a2009/2001a2005/"
filenames = getURL(ftp_01_05, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames = unlist(filenames)
filenames <- filenames[!grepl('LEIA_ME', filenames)]
filenames2 <- filenames[!grepl(".02.xls", filenames)]
filenames3 <- filenames[grepl("RM 18.11.02.xls", filenames)]
filenames_01_05 <- c(filenames2,filenames3)



ftp_10_18 <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/municipios_por_regioes_metropolitanas/Situacao_2010a2019/"
filenames <- getURL(ftp_10_18, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames <- unlist(filenames)
filenames <- filenames[!grepl('.xlsx', filenames)]
filenames <- filenames[grepl(".xls", filenames)]
filenames_10_18 <- filenames[grepl("_06_|_07_", filenames)]
## não tem dados para 2011 e 2012

##------------------

# fazer o download dos arquivos


####---------- 2001:2005
#
dir_01_05 <- "L://# DIRUR #//ASMEQ/geobr/data-raw/metropolitan_area/2001_2005/"
dir.create(paste(dir_01_05,"",sep = ""))
#
#
#
# baixar arquivos no diretório
for (files in filenames_01_05) {
  download.file(paste(ftp_01_05,files, sep = ""),paste(dir_01_05,files,sep = ""), mode = "wb")
}
#
# ####  2010:2018
#
dir_10_18 <- "L://# DIRUR #//ASMEQ/geobr/data-raw/metropolitan_area/2010_2018/"
dir.create(paste(dir_10_18,"/",sep = ""))
#
#
# baixar arquivos no diretório
for (files_ in filenames_10_18) {
  download.file(paste(ftp_10_18,files_, sep = ""),paste(dir_10_18,files_,sep = ""), mode = "wb")
}

--------------------


  setwd(dir_01_05)
#
#
#
#listar arquivos baixados
dados_01_05 <- list.files(pattern = "*.xls", full.names = T)
#
setwd(dir_10_18)
#
dados_10_18 <- list.files(pattern = "*.xls", full.names = T)
setwd(dir_01_05)

####--------------- for para tratar dados de 2001 até 2005
#
for (i in 1:4){
  dado1 <- readxl::read_excel(path = dados_01_05[i])
  year_RM <- paste0(20,substr(dados_01_05[i],12,13))
  if (year_RM %like% "2001|2005"){
    names1 <- stri_encode(names(dado1),"utf-8")
    setnames(dado1,names(dado1),names1)
    dado2 <- lapply(dado1, stri_encode, from = "utf-8") %>% as.data.frame()
  } else {
    names1 <- stri_encode(names(dado1),"WINDOWS-1252")
    setnames(dado1,names(dado1),names1)
    dado2 <- lapply(dado1, stri_encode, from = "WINDOWS-1252") %>% as.data.frame()
  }

  #preenchendo o campos em branco com a primeira informação acima

  colname_nome <- grep("R",colnames(dado2), value= T)
  #names(dado2)[names(dado2) == filename_test] <- "NOME_DA_RM"
  setnames(dado2,colname_nome,"NOME_DA_RM")
  dado2$NOME_DA_RM <- na.locf(dado2$NOME_DA_RM)

  #dado2$DATA_DA_LEI <- gsub(" ","",dado2$DATA_DA_LEI)
  #usar a função de cima (NOME_DA_RM) para resolver
  colname_data <- grep("DATA",colnames(dado2), value= T)
  #names(dado2)[names(dado2) == filename_test] <- "NOME_DA_RM"
  setnames(dado2,colname_data,"DATA_DA_LEI")
  dado2$DATA_DA_LEI <- gsub(" ","",dado2$DATA_DA_LEI)

  #esse grep, na base de 2002 vai ter 2 colunas com "código", arrumar esse bug
  colname_codigo_ <- grep("CÓDIGO",colnames(dado2),value = T)

  if (year_RM %like% "2001|2002|2003"){
    colname_codigo <- grep("DO",colname_codigo_,value = T)
    setnames(dado2,colname_codigo,"code_muni")
  } else {
    setnames(dado2,colname_codigo_,"code_muni")
  }
  #transformando code_muni em ema variável numérica
  dado2$code_muni <- as.numeric(as.character(dado2$code_muni))


  if(year_RM %like% "2001|2002|2003"){
    municipios <- geobr::read_municipality(code_muni  = 'all', year=2001)
  } else if (year_RM %like% "2005") {
    municipios <- geobr::read_municipality(code_muni  = 'all', year=year_RM)
  }
  dado3 <- dplyr::left_join(dado2,municipios)
  temp_sf <- st_as_sf(dado3, crs=4674)
  readr::write_rds(temp_sf, path=paste0(year_RM,".rds"), compress = "gz")  #testar pra ver se funciona
  unlink(dados_01_05[i])
}

# encoding 2002 e 2003: WINDOWS-1252
# dado1 <- readxl::read_excel(path = dados_01_05[4])
# colnames(dado1)
#
setwd(dir_10_18)
#
#
# dados_10_18 <- list.files(pattern = "*.xls", full.names = T)
#
for (i in 1:7){
  dados1 <- readxl::read_excel(path = dados_10_18[i])
  dados2 <- dados1 %>%
    mutate_if(is.factor, function(x){ x %>% as.character() %>%
        stringi::stri_encode("WINDOWS-1252") } )

  year_RM2 <- substr(dados_10_18[i],37,40)

  if  (year_RM2 %like% "2015"){
    L <- nrow(dados2)
    a <- (L-3):L
    b <- dados2[-a,]
  }

  if (year_RM2 %like% "2010|2013|2014|2015"){
    dados2 <- dplyr::rename(dados1, code_muni = `Código Município`)
  } else {
    dados2 <- dplyr::rename(dados1, code_muni = `COD_MUN`)
  }

  dados3 <- dados2 %>% setnames(colnames(dados2),tolower(colnames(dados2)))
  dados3$code_muni <- as.numeric(as.character(dados3$code_muni))
  municipios <- geobr::read_municipality(code_muni  = 'all', year=year_RM2)
  dados4 <- dplyr::left_join(dados3,municipios)
  if(year_RM2 %like% "2010|2013|2014"){
    dados5 <- dplyr::rename(dados4,
                            mr = `região metropolitana, ride ou aglomeração urbana`,
                            subdivision = `subdivisões`,
                            legislation = `legislação`,
                            date_of_law = `data lei`,
                            type = tipo
    )
  } else if (year_RM2 %like% "2015") {
    dados5 <- dplyr::rename(dados4,
                            mr = `região metropolitana, ride ou aglomeração urbana`,
                            subdivision = `subdivisões`,
                            legislation = `legislação`,
                            publication_date = `data de publicação da lei`,
                            signature_date = `data de assinatura da lei`,
                            type = tipo
    )
  } else {
    dados5 <- dplyr::rename(dados4,
                            mr = `nome_rm`,
                            subdivision = `subdivisao`,
                            legislation = `leg`,
                            date_of_law = `data`,
                            type = tipo)
  }

  if(year_RM2 %like% "2010|2013|2014"){
    dados6 <- dplyr::select(dados5,
                            'code_muni',
                            'name_muni',
                            'code_state',
                            'abbrev_state',
                            'mr',
                            'type',
                            'date_of_law',
                            'geometry'
    )
  } else {
    dados6 <- dplyr::select(dados5,
                            'code_muni',
                            'name_muni',
                            'code_state',
                            'abbrev_state',
                            'mr',
                            'type',
                            'subdivision',
                            'legislation',
                            'geometry'
    )
  }

  temp_sf <- st_as_sf(dados6, crs=4674)
  readr::write_rds(temp_sf, path=paste0(year_RM2,".rds"), compress = "gz")
  unlink(dados_10_18[i])
}



