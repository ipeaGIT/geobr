library(sf)
library(dplyr)
library(tidyverse)
library(tidyr)
library(data.table)
library(mapview)
library(readr)
library(maptools)
# https://stackoverflow.com/questions/61614314/how-to-read-a-map-file-extension-in-r

#> Metadata:
# Titulo: Health regions
# Titulo alternativo: Regioes de Saude do SUS
# Data: Atualizado em 07/07/2020
#
# Forma de apresentação: Shape
# Linguagem: Pt-BR
# Character set: 2005 - WINDOWS-1252
#                2015 - UTF-8
#
# Resumo: Criado a partir do Decreto n. 7508 de junho de 2011, em substituicao aos
# Colegiados de Gestao Regional (oriundos do Pacto pela Saude), o CIR a um colegiado
# no qual participam as Secretarias Municipais de Saude, de uma dada regiao, e a Secretaria
# de Estado de saude com o objetivo de promover a gestao colaborativa no setor saude do estado.
# Essa instancia veio aprimorar o processo de regionalizacao no SUS. Os problemas de saude sao
# identificados e analisados conjuntamente. A partir dessa avaliacao procede-se a identificacao
# e pactuar?o das acoes prioritarias, com objetivo de melhorar a situacao de saude e garantir a
# atencao integral na regiao.  A CIR a um ambiente de debate e negociacao que promove a gestao
# colaborativa na saude. Caracteriza-se como um espaco de governanca regional.  Cabe as CIR a
# pactuar?o,  organizaaco e o funcionamento em nivel regional das acoes e servicos de saude
# integrados na rede de atencao a saude - RAS.
#
# Estado: Em desenvolvimento
# Palavras chaves descritivas: CIR; RAS; SUS
# Informacao do Sistema de Referdncia: DATASUS


##### dowload, read e saverds ####

dir.shapes <- "L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus"

dir.download <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus\\Shapes")

dir.1991 <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus\\1991")

dir.1994 <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus\\1994")

dir.1997 <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus\\1997")

dir.2001 <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus\\2001")

dir.2005 <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus\\2005")

dir.2013 <- paste0("L:\\\\# DIRUR #\\ASMEQ\\geobr\\data-raw\\regioes_sus\\2013")





# list address of original files

map_files <- list.files('C:/Users/rafa/Downloads/todos_mapas_2013', pattern = '_regsaud.MAP', full.names = T)

# regioes de cada estado
map_files <- map_files[ substr(map_files, 44,44) == "_" ]

####### read original data in .MAP format ------------------


## read function to get names in correct encoding
# source: https://repositorio.ufrn.br/jspui/bitstream/123456789/17008/1/DanielMC_DISSERT.pdf
read.map = function(filename){
  zz=file(filename,"rb")
  #
  # header of .map
  #
  versao = readBin(zz,"integer",1,size=2)  # 100 = versao 1.00
  #Bounding Box
  Leste = readBin(zz,"numeric",1,size=4)
  Norte = readBin(zz,"numeric",1,size=4)
  Oeste = readBin(zz,"numeric",1,size=4)
  Sul   = readBin(zz,"numeric",1,size=4)

  geocodigo = ""
  nome = ""
  xleg = 0
  yleg = 0
  sede = FALSE
  poli = list()
  i = 0

  #
  # repeat of each object in file
  #
  repeat{
    tipoobj = readBin(zz,"integer",1,size=1) # 0=Poligono, 1=PoligonoComSede, 2=Linha, 3=Ponto

    if (length(tipoobj) == 0) break
    i = i + 1

    Len = readBin(zz,"integer",1,size=1)  # length byte da string Pascal
    geocodigo[i] = readChar(zz,10)
    Len = readBin(zz,"integer",1,size=1)  # length byte da string Pascal
    nome[i] = substr(readChar(zz,25),1,Len)
    xleg[i] = readBin(zz,"numeric",1,size=4)
    yleg[i] = readBin(zz,"numeric",1,size=4)
    numpontos = readBin(zz,"integer",1,size=2)

    sede = sede || (tipoobj = 1)

    x=0
    y=0
    for (j in 1:numpontos){
      x[j] = readBin(zz,"numeric",1,size=4)
      y[j] = readBin(zz,"numeric",1,size=4)
    }

    # separate polygons
    xInic = x[1]
    yInic = y[1]
    for (j in 2:numpontos){
      if (x[j] == xInic & y[j] == yInic) {x[j]=NA; y[j] = NA}
    }

    poli[[i]] = c(x,y)
    dim(poli[[i]]) = c(numpontos,2)
  }

  class(poli) = "polylist"
  attr(poli,"region.id") = geocodigo
  attr(poli,"region.name") = nome
  attr(poli,"centroid") = list(x=xleg,y=yleg)
  attr(poli,"sede") = sede
  attr(poli,"maplim") = list(x=c(Oeste,Leste),y=c(Sul,Norte))

  close(zz)
  return(poli)
}



i <- map_files[17]

prep_map <- function(i){

# names of regions
mp <- read.map( i )
name_health_region <- attr(mp,"region.name")
code_health_region <- attr(mp,"region.id")


# convert to sf
o <- maptools:::readMAP2polylist( i )
oo <- maptools:::.makePolylistValid(o)
ooo <- maptools:::.polylist2SpP(oo, tol=.Machine$double.eps^(1/4))
rn <- row.names(ooo)
names <- attr(o,"region.name")
df <- data.frame(code_health_region=rn, row.names=rn, name_health_region=names, stringsAsFactors=FALSE)
res <- SpatialPolygonsDataFrame(ooo, data=df)

# fix “orphaned hole” in a polygon
slot(res, "polygons") <- lapply(slot(res, "polygons"), checkPolygonsHoles)

# convert to sf
res_sf <- st_as_sf(res)
res_sf


# fix row names
rownames(res_sf) <- 1:nrow(res_sf)

# update attributes
res_sf$code_health_region <- as.numeric(code_health_region)
res_sf$name_health_region <- name_health_region


}














