#> DATASET: metropolitan areas 2000 - 2020
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
# InformaÃ§Ãµes adicionais: Regioes metropolitanas definidas por legislacao estadual
#
# Informacao do Sistema de Referencia: SIRGAS 2000

### Libraries (use any library as necessary)

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
library(stringr)
library(devtools)


####### Load Support functions to use in the preprocessing of the data -----------------
source("./prep_data/prep_functions.R")





###### 0. Create Root folder to save the data -----------------


# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//metropolitan_area"
dir.create(root_dir)
setwd(root_dir)


dest_dir <- './shapes_in_sf_all_years_cleaned/'
dir.create(dest_dir)

# create folder original files 
original_dir <- './shapes_in_sf_all_years_original/'
dir.create( paste(original_dir,"",sep = "") )


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


ftp_10_19 <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/municipios_por_regioes_metropolitanas/Situacao_2010a2019/"
filenames <- RCurl::getURL(ftp_10_19, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames <- unlist(filenames)
filenames <- filenames[!grepl("2016_06_30.xlsx|.ods", filenames)]
filenames_10_19 <- filenames[grepl("_06_|_07_", filenames)]
## não tem dados para 2011 e 2012

ftp_20_29 <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/municipios_por_regioes_metropolitanas/Situacao_2020a2029/"
filenames <- RCurl::getURL(ftp_20_29, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames <- unlist(filenames)
filenames_20_29 <- filenames[grepl('.xlsx', filenames)]



### fazer o download dos arquivos
setwd(original_dir)

# 2001:2005
for (files in filenames_01_05) {
  download.file( url = paste(ftp_01_05, files, sep = ""),
                 destfile = files,
                 mode = "wb")
  }


# 2010:2019
for (files_ in filenames_10_19) {
  download.file( url = paste(ftp_10_19,files_, sep = ""),
                 destfile = files_,
                 mode = "wb")
}

# 2020:2029
for (files_ in filenames_20_29) {
  download.file( url = paste(ftp_20_29,files_, sep = ""),
                 destfile = files_,
                 mode = "wb")
}



#### 2. Clean data set and save it in compact .rds format-----------------


#### 2.1 Cleaning date 2001-2005 -----------------

# listar arquivos baixados
dados_01_05 <- list.files(pattern = "*.xls", all.files = T)
dados_01_05 <- dados_01_05[ dados_01_05  %like% 'RM ']



for (i in 1:4){

  message(paste('working on', dados_01_05[i]))

  # Leitura do arquivo em excel
  dado1 <- readxl::read_excel(path = dados_01_05[i])

  # identifica ano de referencia do arquibo
  year_RM <- paste0(20,substr(dados_01_05[i],10,11))

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
  
  #apagar a última linha do arquivo
  if  (year_RM %like% "2005"){
    a <- nrow(dado2)
    dado2 <- dado2[-a,]
  }
  
## Coluna name_metro

  # identifica coluna com nome da Regiao Metropolitana
  colname_nome <- grep("R",colnames(dado2), value= T)

  # atualiza nome da coluna e preenche valores NA
  setnames(dado2, colname_nome, "name_metro")

  # preenchendo o campos em branco com a primeira informaÃ§Ã£o acima
  dado2$name_metro <- zoo::na.locf(dado2$name_metro)

## Coluna legislation e legislation_date
  setnames(dado2, "LEGISLAÇÃO", "legislation")

  # identifica coluna problema com data de criacao da lei de Regiao Metropolitana, e renomeia coluna
  colname_data <- grep("DATA",colnames(dado2), value= T)
  setnames(dado2, colname_data, "legislation_date")
  dado2$legislation_date <- gsub(" ","",dado2$legislation_date)

  # preenchendo o campos em branco com a primeira informaÃ§Ã£o acima
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


  # transformando code_muni em variÃ¡vel numÃ©rica
  dado2$code_muni <- as.numeric(as.character(dado2$code_muni))

# if 2001, add "RM" to 'name_metro' to harmonize column with other years
  if(year_RM==2001){ setDT(dado2)[ !(name_metro %like% 'Distrito Federal|Aglomeração Urbana|RIDE|Colar Metropolitano|Área de Expansão|Núcleo Metropolitano'), name_metro := paste0('RM ', name_metro)] }



# read muni shapes
  if(year_RM %like% "2001|2002|2003"){
    municipios <- geobr::read_municipality(code_muni  = 'all', year=2001)
  } else if (year_RM %like% "2005") {
    municipios <- geobr::read_municipality(code_muni  = 'all', year=year_RM)
  }


# Adiciona dado espacial (coluna geometry)
  dado3 <- dplyr::left_join(dado2, municipios, by = "code_muni") %>% setDT()

# reordena colunas
  setcolorder(dado3, c('name_metro', 
                       'code_muni', 
                       'name_muni', 
                       'legislation', 
                       'legislation_date', 
                       'code_state', 
                       'abbrev_state', 
                       'geom'))

# set back to spatial sf
  temp_sf <- st_as_sf(dado3, crs=4674)

# remove missing values
  temp_sf <- subset(temp_sf, !is.na(name_metro))
  temp_sf <- subset(temp_sf, !is.na(abbrev_state))



# Conver factor columns to character AND Use UTF-8 encoding in all character
  temp_sf <- temp_sf %>%
    mutate_if(is.factor, function(x){ x %>% as.character()  } )

  # simplify
  temp_sf_simplified <- st_transform(temp_sf, crs=3857) %>%
    sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)

# create dir to save data
  dir.create(paste0(root_dir, "/shapes_in_sf_all_years_cleaned/",year_RM))

### Save data
  sf::st_write(temp_sf, dsn = paste0(root_dir,substr(dest_dir, 2, 33),year_RM,"/",'metro_',year_RM,".gpkg"))
  sf::st_write(temp_sf_simplified, dsn = paste0(root_dir,substr(dest_dir, 2, 33),year_RM,"/",'metro_',year_RM,"_simplified.gpkg"))
}

# encoding 2002 e 2003: WINDOWS-1252
#


#### 2.2 Cleaning date 2010-2020 -----------------

# listar arquivos baixados
dados_10_20 <- list.files(pattern = "*.xls", all.files = T)
dados_10_20 <- dados_10_20[ dados_10_20  %like% 'RMs']


# create cleanning function
fun_clean_2010_2020 <- function(i){

  # Read data
  dado1 <- readxl::read_excel(path = i)

  # Fix Encoding
  dado2 <- dado1 %>%
    mutate_if(is.factor, function(x){ x %>% as.character() %>%
        stringi::stri_encode("WINDOWS-1252") } )

  # identifica ano de referencia
  year_RM2 <- substr( i, 35, 38)

  # Progress message
  message(paste('working on', year_RM2))

  #apagar as 4 últimas linhas do arquivo
  if  (year_RM2 %like% "2015"){
    L <- nrow(dado2)
    a <- (L-3):L
    b <- dado2[-a,]
  }
  
  #apagar as 2 últimas linhas do arquivo
  if  (year_RM2 %like% "2010|2013"){
    L <- nrow(dado2)
    a <- (L-1):L
    b <- dado2[-a,]
  }
  
  # Rename code_muni
  if (year_RM2 %like% "2010|2013|2014|2015"){
    dado2 <- dplyr::rename(dado1, code_muni = `Código Município`)
  } else {
    dado2 <- dplyr::rename(dado1, code_muni = `COD_MUN`)
  }

  # Converte Code muni para numerico
  dado2$code_muni <- as.numeric(as.character(dado2$code_muni))

  # Padroniza data
  if (year_RM2 %like% "2019|2020"){
    dado2$DATA <- format(dado2$DATA, "%d.%m.%Y")
  }
  
  # Todos colnames para minusculo
  dado3 <- dado2 %>% setnames(colnames(dado2),tolower(colnames(dado2)))

  # leitura dos dados espaciais
  municipios <- geobr::read_municipality(code_muni  = 'all', year=year_RM2)

  # merge de dados para adicionar coluna espacial 'geometry'
  dado4 <- dplyr::left_join(dado3, municipios) %>% setDT()

  # Renomeia colunas (padrao varia em cada ano)
  if(year_RM2 %like% "2010|2013|2014"){
    dado5 <- dplyr::rename(dado4,
                            name_metro = `região metropolitana, ride ou aglomeração urbana`,
                            subdivision = `subdivisões`,
                            legislation = `legislação`,
                            legislation_date = `data lei`,
                            type = tipo
    )
  } else if (year_RM2 %like% "2015") {
    dado5 <- dplyr::rename(dado4,
                            name_metro = `região metropolitana, ride ou aglomeração urbana`,
                            subdivision = `subdivisões`,
                            legislation = `legislação`,
                            legislation_date = `data de publicação da lei`,
                            signature_date = `data de assinatura da lei`,
                            type = tipo
    )
  } else if (year_RM2 %like% "2019|2020") {
    dado5 <- dplyr::rename(dado4,
                           name_metro = `nome`,
                           subdivision = `cat_assoc`,
                           legislation = `leg`,
                           legislation_date = `data`,
                           type = tipo
    )
  } else {
    dado5 <- dplyr::rename(dado4,
                            name_metro = `nome_rm`,
                            subdivision = `subdivisao`,
                            legislation = `leg`,
                            legislation_date = `data`,
                            type = tipo)
  }
  
  if(year_RM2 %like% "2010|2013|2014"){
    dado6 <- dplyr::select(dado5,
                           'name_metro',
                           'code_muni',
                           'name_muni',
                           'code_state',
                           'abbrev_state',
                           'type',
                           'legislation_date',
                           'geom'
    )
  } else if (year_RM2 %like% "2019|2020"){
    dado6 <- dplyr::select(dado5,
                           'name_metro',
                           'code_muni',
                           'name_muni',
                           'legislation',
                           'legislation_date',
                           'code_state',
                           'abbrev_state',
                           'type',
                           'subdivision',
                           'geom'
    )
  } else {
    dado6 <- dplyr::select(dado5,
                           'name_metro',
                           'code_muni',
                           'name_muni',
                           'legislation',
                           'code_state',
                           'abbrev_state',
                           'type',
                           'subdivision',
                           'geom'
    )
  }

  # set back to spatial sf
  temp_sf <- st_as_sf(dado6, crs=4674)

  # remove missing values
  temp_sf <- subset(temp_sf, !is.na(name_metro))
  temp_sf <- subset(temp_sf, !is.na(abbrev_state))

  # Conver factor columns to character AND Use UTF-8 encoding in all character
  temp_sf <- temp_sf %>%
    mutate_if(is.factor, function(x){ x %>% as.character() %>%
        stringi::stri_encode("UTF-8") } )

  temp_sf <- temp_sf %>%
    mutate_if(is.character, function(x){ x %>% stringi::stri_encode("UTF-8") } )


  ###### convert to MULTIPOLYGON -----------------
  temp_sf <- to_multipolygon(temp_sf)


  # simplify
  temp_sf_simplified <- st_transform(temp_sf, crs=3857) %>%
    sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)

  # create dir to save data
  dir.create(paste0(root_dir, "/shapes_in_sf_all_years_cleaned/",year_RM2))
  
  ### Save data
  sf::st_write(temp_sf, dsn =paste0(root_dir,substr(dest_dir, 2, 33), year_RM2, "/", 'metro_', year_RM2,".gpkg"))
  sf::st_write(temp_sf_simplified, dsn =paste0(root_dir,substr(dest_dir, 2, 33), year_RM2, "/", 'metro_', year_RM2,"_simplified.gpkg"))
}


# apply function in parallel to save original data sets
future::plan(strategy = 'multisession')
furrr::future_map(.x=dados_10_20, .f=fun_clean_2010_2020, .progress = T)




###### Data from metro areas in 1970 ----------------------------------------

root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//metropolitan_area"
setwd(root_dir)

dest_dir <- './shapes_in_sf_all_years_cleaned/'
dir.create( paste0(dest_dir, 1970,"/") )

##############
# read.excel <- function(header=TRUE,...) { read.table("clipboard",sep="\t",header=header,...) }
# df=read.excel()
#
# head(df)
# df$SubdivisÃµes <- NULL
# df$Nome.MunicÃ­pio  <- NULL
#
# names(df) <- c('name_metro', 'code_muni', "legislation", "legislation_date")
#
# # add geometry
# sf70 <- read_municipality(code_muni = 'all', year=1970)
#
# rio <- subset(sf70, name_muni=='Guanabara')
# rio$code_muni <- 3304557
# rio$name_muni <- "Rio de Janeiro"
# sf70 <- rbind(sf70, rio)
#
# aaaa <- left_join(df,  sf70, by="code_muni")
#
#
# aaaa$code_state <- substring(aaaa$code_muni, 1,2)
#
# aaaa <- aaaa %>% mutate(abbrev_state =  ifelse(code_state== 11, "RO",
#                                                      ifelse(code_state== 12, "AC",
#                                                             ifelse(code_state== 13, "AM",
#                                                                    ifelse(code_state== 14, "RR",
#                                                                           ifelse(code_state== 15, "PA",
#                                                                                  ifelse(code_state== 16, "AP",
#                                                                                         ifelse(code_state== 17, "TO",
#                                                                                                ifelse(code_state== 21, "MA",
#                                                                                                       ifelse(code_state== 22, "PI",
#                                                                                                              ifelse(code_state== 23, "CE",
#                                                                                                                     ifelse(code_state== 24, "RN",
#                                                                                                                            ifelse(code_state== 25, "PB",
#                                                                                                                                   ifelse(code_state== 26, "PE",
#                                                                                                                                          ifelse(code_state== 27, "AL",
#                                                                                                                                                 ifelse(code_state== 28, "SE",
#                                                                                                                                                        ifelse(code_state== 29, "BA",
#                                                                                                                                                               ifelse(code_state== 31, "MG",
#                                                                                                                                                                      ifelse(code_state== 32, "ES",
#                                                                                                                                                                             ifelse(code_state== 33, "RJ",
#                                                                                                                                                                                    ifelse(code_state== 35, "SP",
#                                                                                                                                                                                           ifelse(code_state== 41, "PR",
#                                                                                                                                                                                                  ifelse(code_state== 42, "SC",
#                                                                                                                                                                                                         ifelse(code_state== 43, "RS",
#                                                                                                                                                                                                                ifelse(code_state== 50, "MS",
#                                                                                                                                                                                                                       ifelse(code_state== 51, "MT",
#                                                                                                                                                                                                                              ifelse(code_state== 52, "GO",
#                                                                                                                                                                                                                                     ifelse(code_state== 53, "DF",NA))))))))))))))))))))))))))))
#
# aaaa <- select(aaaa, name_metro, code_muni, name_muni, legislation, legislation_date, code_state, abbrev_state)
#
#
# dput(aaaa)
#########

data1970 <- structure(list(name_metro = structure(c(1L, 1L, 4L, 4L, 4L, 4L,
              4L, 6L, 6L, 6L, 6L, 6L, 6L, 6L, 6L, 6L, 8L, 8L, 8L, 8L, 8L, 8L,
              8L, 8L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L,
              7L, 7L, 7L, 7L, 7L, 7L, 7L, 7L, 7L, 7L, 9L, 9L, 9L, 9L, 9L, 9L,
              9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L,
              9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 3L,
              3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 5L, 5L, 5L,
              5L, 5L, 5L, 5L, 5L, 5L, 5L, 5L, 5L, 5L, 5L), .Label = c("RM BelÃ©m",
              "RM Belo Horizonte", "RM Curitiba", "RM Fortaleza", "RM Porto Alegre",
              "RM Recife", "RM Rio de Janeiro", "RM Salvador", "RM SÃ£o Paulo"
              ), class = "factor"), code_muni = c(1500800, 1501402, 2301000,
              2303709, 2304400, 2307700, 2309706, 2602902, 2606804, 2607604,
              2607901, 2609402, 2609600, 2610707, 2611606, 2613701, 2905701,
              2906501, 2916104, 2919207, 2927408, 2929206, 2930709, 2933208,
              3106200, 3106705, 3110004, 3118601, 3129806, 3137601, 3144805,
              3149309, 3153905, 3154606, 3154804, 3156700, 3157807, 3171204,
              3301702, 3301900, 3302502, 3303203, 3303302, 3303500, 3303609,
              3304557, 3304904, 3305109, 3503901, 3505708, 3506607, 3509007,
              3509205, 3510609, 3513009, 3513801, 3515004, 3515103, 3515707,
              3516309, 3516408, 3518305, 3518800, 3522208, 3522505, 3523107,
              3525003, 3526209, 3528502, 3529401, 3530607, 3534401, 3539103,
              3539806, 3543303, 3544103, 3545001, 3546801, 3547304, 3547809,
              3548708, 3548807, 3550308, 3552502, 3552809, 4100400, 4101804,
              4102307, 4103107, 4104006, 4104204, 4105805, 4106209, 4106902,
              4114302, 4119509, 4120804, 4122206, 4125506, 4300604, 4303103,
              4303905, 4304606, 4307609, 4307708, 4309209, 4309308, 4313409,
              4314902, 4318705, 4319901, 4320008, 4323002), name_muni = c("Ananindeua",
              "BelÃ©m", "Aquiraz", "Caucaia", "Fortaleza", "Maranguape", "Pacatuba",
              "Cabo de Santo Agostinho", "Igarassu", "Ilha de ItamaracÃ¡", "JaboatÃ£o dos Guararapes",
              "Moreno", "Olinda", "Paulista", "Recife", "SÃ£o LourenÃ§o da Mata",
              "CamaÃ§ari", "Candeias", "Itaparica", "Lauro de Freitas", "Salvador",
              "SÃ£o Francisco do Conde", "SimÃµes Filho", "Vera Cruz", "Belo Horizonte",
              "Betim", "CaetÃ©", "Contagem", "IbiritÃ©", "Lagoa Santa", "Nova Lima",
              "Pedro Leopoldo", "Raposos", "RibeirÃ£o das Neves", "Rio Acima",
              "SabarÃ¡", "Santa Luzia", "Vespasiano", "Duque de Caxias", "ItaboraÃ­",
              "MagÃ©", "NilÃ³polis", "NiterÃ³i", "Nova IguaÃ§u", "Paracambi", "Rio de Janeiro",
              "SÃ£o GonÃ§alo", "SÃ£o JoÃ£o de Meriti", "ArujÃ¡", "Barueri", "Biritiba-Mirim",
              "Caieiras", "Cajamar", "CarapicuÃ­ba", "Cotia", "Diadema", "Embu",
              "EmbuGuaÃ§u", "Ferraz de Vasconcelos", "Francisco Morato", "Franco da Rocha",
              "Guararema", "Guarulhos", "Itapecerica da Serra", "Itapevi",
              "Itaquaquecetuba", "Jandira", "Juquitiba", "MairiporÃ£", "MauÃ¡",
              "Mogi das Cruzes", "Osasco", "Pirapora do Bom Jesus", "PoÃ¡",
              "RibeirÃ£o Pires", "Rio Grande da Serra", "SalesÃ³polis", "Santa Isabel",
              "Santana de ParnaÃ­ba", "Santo AndrÃ©", "SÃ£o Bernardo do Campo",
              "SÃ£o Caetano do Sul", "SÃ£o Paulo", "Suzano", "TaboÃ£o da Serra",
              "Almirante TamandarÃ©", "AraucÃ¡ria", "Balsa Nova", "BocaiÃºva do Sul",
              "Campina Grande do Sul", "Campo Largo", "Colombo", "Contenda",
              "Curitiba", "Mandirituba", "Piraquara", "Quatro Barras", "Rio Branco do Sul",
              "SÃ£o JosÃ© dos Pinhais", "Alvorada", "Cachoeirinha", "Campo Bom",
              "Canoas", "EstÃ¢ncia Velha", "Esteio", "GravataÃ­", "GuaÃ­ba", "Novo Hamburgo",
              "Porto Alegre", "SÃ£o Leopoldo", "Sapiranga", "Sapucaia do Sul",
              "ViamÃ£o"), legislation = structure(c(2L, 2L, 2L, 2L, 2L, 2L,
              2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L,
              2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 1L, 2L, 2L, 2L, 2L, 2L, 2L, 2L,
              3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 2L, 2L, 2L, 2L, 2L, 2L,
              2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L,
              2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L,
              2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L,
              2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L), .Label = c("Lei Complementar 014",
              "Lei Complementar 014 (Federal)", "Lei Complementar 020 (Federal)"
              ), class = "factor"), legislation_date = structure(c(2L, 2L,
              2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L,
              2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L,
              2L, 2L, 2L, 2L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 2L, 2L,
              2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L,
              2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L,
              2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L,
              2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L), .Label = c("01.07.1974",
              "08.06.1973"), class = "factor"), code_state = c("15", "15",
              "23", "23", "23", "23", "23", "26", "26", "26", "26", "26", "26",
              "26", "26", "26", "29", "29", "29", "29", "29", "29", "29", "29",
              "31", "31", "31", "31", "31", "31", "31", "31", "31", "31", "31",
              "31", "31", "31", "33", "33", "33", "33", "33", "33", "33", "33",
              "33", "33", "35", "35", "35", "35", "35", "35", "35", "35", "35",
              "35", "35", "35", "35", "35", "35", "35", "35", "35", "35", "35",
              "35", "35", "35", "35", "35", "35", "35", "35", "35", "35", "35",
              "35", "35", "35", "35", "35", "35", "41", "41", "41", "41", "41",
              "41", "41", "41", "41", "41", "41", "41", "41", "41", "43", "43",
              "43", "43", "43", "43", "43", "43", "43", "43", "43", "43", "43",
              "43"), abbrev_state = c("PA", "PA", "CE", "CE", "CE", "CE", "CE",
              "PE", "PE", "PE", "PE", "PE", "PE", "PE", "PE", "PE", "BA", "BA",
              "BA", "BA", "BA", "BA", "BA", "BA", "MG", "MG", "MG", "MG", "MG",
              "MG", "MG", "MG", "MG", "MG", "MG", "MG", "MG", "MG", "RJ", "RJ",
              "RJ", "RJ", "RJ", "RJ", "RJ", "RJ", "RJ", "RJ", "SP", "SP", "SP",
              "SP", "SP", "SP", "SP", "SP", "SP", "SP", "SP", "SP", "SP", "SP",
              "SP", "SP", "SP", "SP", "SP", "SP", "SP", "SP", "SP", "SP", "SP",
              "SP", "SP", "SP", "SP", "SP", "SP", "SP", "SP", "SP", "SP", "SP",
              "SP", "PR", "PR", "PR", "PR", "PR", "PR", "PR", "PR", "PR", "PR",
              "PR", "PR", "PR", "PR", "RS", "RS", "RS", "RS", "RS", "RS", "RS",
              "RS", "RS", "RS", "RS", "RS", "RS", "RS")), class = "data.frame", row.names = c(NA,
              -113L))

# add geometry
sf70 <- read_municipality(code_muni = 'all', year=1970)

# correct Guanabara = Rio de Janeiro
rio <- subset(sf70, name_muni=='Guanabara')
rio$code_muni <- 3304557
rio$name_muni <- "Rio de Janeiro"
sf70 <- rbind(sf70, rio)

# add geometry
data1970_sf <- left_join(data1970,  sf70, by=c("code_muni","name_muni")) %>% st_sf()
# head(data1970_sf)


data1970_sf$name_metro %>%  as.character() %>% unique()


# Conver factor columns to character AND Use UTF-8 encoding in all character
data1970_sf <- data1970_sf %>%
  mutate_if(is.factor, function(x){ x %>% as.character()  } )

# simplify
data1970_sf_simplified <- st_transform(data1970_sf, crs=3857) %>%
  sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)

# mapview::mapview(data1970_sf)


### save data
sf::st_write(data1970_sf,        dsn = paste0(dest_dir, 1970, "/", 'metro_', 1970,".gpkg"))
sf::st_write(data1970_sf_simplified, dsn = paste0(dest_dir, 1970, "/intermediate_regions_2017_simplified.gpkg"))
