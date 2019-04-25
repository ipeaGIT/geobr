# Listar as opções da função ----------------------------------------------

list_shapes <- function(IDENT = NULL){
  dir.download <- paste0("L:\\\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\area_ponderacao")
  if (is.null(IDENT)){
    lista <- !is.null(IDENT)
    return(lista)
  }
  for (UF in IDENT) {
if (UF=="UF"){
  lista<-list.files(paste(paste(dir.download,sep="/"),sep=""))
  lista<- lista[nchar(lista)==2]
  return(lista)
} else if (nchar(UF)==2 & is.numeric(UF)){
  lista<-list.files(paste(paste(dir.download,UF,sep="/"),sep=""))
  lista<-substr(lista,1,7)
  return(lista)
} else if (nchar(UF)==7 & is.numeric(UF)){
  estados<-unique(substr(UF,1,2))
  lista<- vector()
  for (estado in estados) { 
    lista_est<-list.files(paste(paste(dir.download,estado,sep="/"),sep=""))
    lista_est<-substr(lista_est,1,7)
    lista <- c(lista,lista_est)
  }
  lista <- UF %in% lista
  #arrumar
  #if (identical(rep(TRUE, length(lista)), lista)){"Possuimos os municipios"} else {"Não possuimos todos os municipios"}
  return(lista)
}
}
}

#exemplos
list_shapes("UF")
list_shapes(11)
list_shapes(1100205)
list_shapes()

# FunÃ§Ã£o de leitura -------------------------------------------------------


read_areaponderacao <- function(CODE = NULL){
  
   # CODE NULL
  if( is.null(CODE)) {
    stop(paste0("Invalid value to UF or MUN")) 
  }
  library(assertthat)
  # verificando se a pessoa entrou com uma string
  if( is.string(CODE)) {
    stop(paste0("Invalid value to UF or MUN")) 
  }
  
  # definindo diretorio de download dos arquivos 
   dir.proj <- paste0("L:\\\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\area_ponderacao")
   
  if(nchar(CODE) == 2) {
    if(!(CODE %in% as.numeric(list_shapes("UF"))) ){
      stop(paste0("Invalid value to UF. Must be one of the following: 11, 12, 13, 14, 15, 16, 17, 21, 22, 23, 24, 25, 26, 27, 28, 29, 31, 32, 33, 35, 41, 42, 43, 50, 51, 52, 53")) 
    }
    
    if (length(list_shapes(CODE))==0){stop(paste0("UF has no weighting area."))}
    library(sf)
    a = paste(paste(dir.proj,CODE,list_shapes(CODE),sep="\\"),"_areaponderacao_2010.rds",sep="")
    c = NULL
    for(b in 1:length(a)){
      d <- as.data.frame(readRDS(a[b]))
      colnames(d)[colnames(d) %in% c("CD_APONDE","CD_APonde")] <- "cd_aponde"
      d <- d[,c("cd_aponde","geometry")]
      d$cod_mum <- list_shapes(CODE)[b]
      d$cod_uf <- CODE
      c <- rbind.data.frame(c,d)
    }
    c <- st_sf(c)
    return(c)
    
    } 
  
  if(nchar(CODE) == 7) {
    if(!(list_shapes(CODE)) ){
      stop(paste0("Invalid value to MUN.")) 
    }
    return(readRDS(paste(paste(dir.proj,substr(CODE,1,2),CODE,sep="\\"),"_areaponderacao_2010.rds",sep="")))
  }
  
  stop(paste0("Invalid value to CODE.")) 
}


# Exemplos
dados <- read_areaponderacao(34)
dados <- read_areaponderacao(3500000)
dados <- read_areaponderacao(123)
dados <- read_areaponderacao("df")
dados <- read_areaponderacao(1302603)
dados <- read_areaponderacao(35)
dados <- read_areaponderacao(14)

#testando todos #OK
dados <- read_areaponderacao(54)

# mapa
library(mapview)
mapview(dados)

