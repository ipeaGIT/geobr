library(RCurl)
library(tidyverse)
library(stringr)
library(sf)

#dados do link
url = "ftp://geoftp.ibge.gov.br/recortes_para_fins_estatisticos/grade_estatistica/censo_2010/"
filenames = getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames = unlist(filenames)

#fazendo download dos dados zipados
for (filename in filenames) {
  download.file(paste(url, filename, sep = ""), paste("//Storage6/usuarios/# DIRUR #/ASMEQ/grade_censo2010/dadoszip", "/", filename,
                                                      sep = ""))
}

# descompactando os dados
for (filename in filenames[-c(1,2)]) {
  unzip(paste("//Storage6/usuarios/# DIRUR #/ASMEQ/grade_censo2010/dadoszip/",filename,sep=""),exdir = "//Storage6/usuarios/# DIRUR #/ASMEQ/grade_censo2010/dadosunzip")
  
}

#casa queira salvar como shapefile
# for (filename in filenames[3:6]) {
#   st_write(st_read(paste(str_sub(filename, 1, 10),"shp",sep=".")) , str_sub(filename,1,10),driver = "ESRI Shapefile")
# }
# end_time <- Sys.time()

#Transformando os dados e exportando para rds
for (filename in filenames[-c(1,2)]) {
  saveRDS(st_read(paste("//Storage6/usuarios/# DIRUR #/ASMEQ/grade_censo2010/dadosunzip/",str_sub(filename, 1, 10),".shp",sep="")),file = paste("//Storage6/usuarios/# DIRUR #/ASMEQ/grade_censo2010/dadosrds/",str_sub(filename, 1, 10),".rds",sep = ""))
}

#olhar tempo e tamanho(rds ganhou nos dois)

#merge de todas as bases e salvar tudo como brasil.rds
brasil <- readRDS("//Storage6/usuarios/# DIRUR #/ASMEQ/grade_censo2010/dadosrds/grade_id04.rds")
for (filename in filenames[-c(1,2,3)]) {
  brasil <- rbind(brasil,readRDS(paste("//Storage6/usuarios/# DIRUR #/ASMEQ/grade_censo2010/dadosrds/",str_sub(filename,1,10),".rds",sep="")))
}
saveRDS(brasil,file = "//Storage6/usuarios/# DIRUR #/ASMEQ/grade_censo2010/dadosrds/brasil.rds")




# renaming all data sets 

orig_names <- list.files("//storage3/geobr/data/statistical_grid/2010")

04grid
