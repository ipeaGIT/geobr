library(RCurl)
library(tidyverse)
library(stringr)
library(sf)

#copiando e colando os arquivos zipados para a pasta de trabalho
#Fazer manualmente

#pegando os nomes dos arquivos
filenames <- list.files(pattern = ".*\\.zip$")
filenamesred <- list.files(path = "./municipios_areas_redefinidas")

#descompactando
for (filename in filenames) {
  unzip(filename)
 #excluindo os arquivos .zip
   file.remove(filename)
}
for (filename in filenamesred) {
  unzip(paste("./municipios_areas_redefinidas",filename,sep="/"),exdir = "./municipios_areas_redefinidas")
}

#transformando os dados e salvando como rds
for (filename in list.files(pattern = "^\\d|mun")) {
a=list.files(path = paste("./",filename,sep=""),pattern = ".*\\.shp$")

for (file in a) {
saveRDS(st_read(paste(".",filename,file,sep = "/")),
        file = paste(paste(".",filename,gsub('.{0,4}$', '', file),sep="/"),".rds",sep=""))
}

#excluindo arquivos diferentes de .rds
b=list.files(path = paste("./",filename,sep=""))[!list.files(path = paste("./",filename,sep="")) %in%
                                                  list.files(path = paste("./",filename,sep=""),pattern = ".*\\.rds$")]
for (excluir in b) {
  file.remove(paste(".",filename,excluir,sep="/"))
}
}

#Alterando o nome das pastas dos estados para facilitar a funcao
auxiliar <- list.files()
for(nome in auxiliar){
  if(is.na(as.numeric(str_extract(nome,"\\d")))==F){
    file.rename(paste(".",nome,sep="/"),paste(".",str_sub(nome,1,2),sep="/"))
  }
 }

#colocar no diretório a Tabela de códigos 2010 e transformar em csv
#trocando o nome dos municípios pelos códigos 
#arrumando tabela do ibge
tabcod <- read.csv2("./Tabela de códigos 2010.csv",header = T,skip = 2)

#rodando uma funcao pra tirar os acentos 
rm_accent <- function(str,pattern="all") {
    # Rotinas e funções úteis V 1.0
    # rm.accent - REMOVE ACENTOS DE PALAVRAS
    # Função que tira todos os acentos e pontuações de um vetor de strings.
    # Parâmetros:
    # str - vetor de strings que terão seus acentos retirados.
    # patterns - vetor de strings com um ou mais elementos indicando quais acentos deverão ser retirados.
    #            Para indicar quais acentos deverão ser retirados, um vetor com os símbolos deverão ser passados.
    #            Exemplo: pattern = c("´", "^") retirará os acentos agudos e circunflexos apenas.
    #            Outras palavras aceitas: "all" (retira todos os acentos, que são "´", "`", "^", "~", "¨", "ç")
    if(!is.character(str))
      str <- as.character(str)
    
    pattern <- unique(pattern)
    
    if(any(pattern=="Ç"))
      pattern[pattern=="Ç"] <- "ç"
    
    symbols <- c(
      acute = "áéíóúÁÉÍÓÚýÝ",
      grave = "àèìòùÀÈÌÒÙ",
      circunflex = "âêîôûÂÊÎÔÛ",
      tilde = "ãõÃÕñÑ",
      umlaut = "äëïöüÄËÏÖÜÿ",
      cedil = "çÇ"
    )
    
    nudeSymbols <- c(
      acute = "aeiouAEIOUyY",
      grave = "aeiouAEIOU",
      circunflex = "aeiouAEIOU",
      tilde = "aoAOnN",
      umlaut = "aeiouAEIOUy",
      cedil = "cC"
    )
    
    accentTypes <- c("´","`","^","~","¨","ç")
    
    if(any(c("all","al","a","todos","t","to","tod","todo")%in%pattern)) # opcao retirar todos
      return(chartr(paste(symbols, collapse=""), paste(nudeSymbols, collapse=""), str))
    
    for(i in which(accentTypes%in%pattern))
      str <- chartr(symbols[i],nudeSymbols[i], str)
    
    return(str)
}
tabcod$Nome_Município <- tabcod$Nome_Município %>% as.character(.) %>% str_to_lower(.) %>% rm_accent(.) %>% str_replace(.,"[:punct:]"," ")

#arrumando nome dos arquivos
a=data.frame(matrix(ncol=2,nrow=0))
colnames(a)<-c("UF","Mun")
for (filename in list.files(pattern = "^\\d|mun")) {
  for (f in list.files(path = paste("./",filename,sep=""),pattern = ".*\\.rds$")){
 a <-  rbind(a,data.frame(UF=filename,caminho=f))
  }
}

#limpando os municipios
a$Mun <- a$caminho %>% str_replace_all(.,"_area.*","") %>% str_to_lower(.) %>%
  str_replace(.,"[:punct:]"," ")%>% str_replace(.,"_"," ") %>% str_replace(.,"_"," ") %>% str_replace(.,"_"," ") 

#trocando algunas nomes que vieram errados
a$Mun[11] <- "sao luis"
a$Mun[7] <- "santarem"

a$UF <- as.character(a$UF)
tabcod$UF <- as.character(tabcod$UF)
a$Mun <- as.character(a$Mun)
tabcod$Nome_Município <- as.character(tabcod$Nome_Município)

#juntando os codigos com os municipios e os caminhos
juntos1 <- left_join(a[1:138,],tabcod[,c(1,7,8)],by=c("UF"="UF","Mun"="Nome_Município"))
juntos2 <- left_join(a[139:152,],tabcod[,c(1,7,8)],by=c("Mun"="Nome_Município"))

#excluindo a santa maria duplicada
juntos2 <- juntos2[-c(13),-c(4)] 

#renomeando UF
colnames(juntos2)[1] <- c("UF")

#junçao final
b <- rbind(juntos1,juntos2)

#renomeando os nomes das pastas
for (n in 1:152) {
  if (!is.na(b$Município[n])){
file.rename(paste(".",b$UF[n],b$caminho[n],sep="/"),paste(paste(".",b$UF[n],b$Município[n],sep="/"),"_areaponderacao_2010.rds",sep=""))
  }
  }


#### Parte 2 #####
# excluindo as antigas
r <- list.files("municipios_areas_redefinidas")
for (i in r) {
file.remove(paste(substr(i,1,2),i,sep="/"))
}

# renomeando as areas redefinidas
for (i in r) {
  file.rename(from=paste("municipios_areas_redefinidas",i,sep="/"),to=paste("municipios_areas_redefinidas",gsub('.rds', '_redefinida.rds', i),sep="/"))
}
# atualizando as areas redefenidas ##
install.packages("filesstrings")
library(filesstrings)

s <- list.files("municipios_areas_redefinidas")
for (i in s) {
  file.move(paste("municipios_areas_redefinidas",i,sep="/"), substr(i,1,2))
}
#excluindo a pasta "municipios_areas_redefinidas"
unlink("municipios_areas_redefinidas",recursive = TRUE)

## igualando as base, trocando o nome das variaveis e add algumas
t=list.files(pattern = "^\\d")

for (i in t) {
u=list.files(i)

for (j in u) {
d <- as.data.frame(readRDS(paste(i,j,sep = "/")))
colnames(d)[colnames(d) %in% c("CD_APONDE","CD_APonde","cd_aponde")] <- "cod_areapond"
colnames(d)[colnames(d) %in% c("geometry")] <- "geom"
d <- d[,c("cod_areapond","geom")]
d$cod_mum <-substr(j,1,7)
d$cod_uf <- i
d <- st_sf(d)
saveRDS(d,file = paste(".",i,j,sep = "/"))
}
}


