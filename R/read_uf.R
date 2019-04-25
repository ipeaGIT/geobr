## Pacotes
library(stringr)
library(sf)
library(dplyr)
library(magrittr)


# Diretorio raiz
root_dir <- "L:\\\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\uf"

#### Função de Leitura para os shapes da UF ####

read_uf <- function(ano=NULL, cod_uf=NULL){
  
  if(is.null(ano) || is.null(cod_uf)){ #testa se os parametros são nulos;
    stop("Error: Invalid value to argument ano or argument cod_uf.") 
  }
  if(ano %in% str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+")){ #testa se o ano existe;
    if(cod_uf %in% substr(list.files(paste0(root_dir, "\\UF_", ano)), start =  1, stop = 2)){ #testa se o estado existe;
      
      shape <- readRDS(paste0(root_dir, "\\UF_", ano, "\\", substr(x = cod_uf, 1, 2), "UF.rds")) 
      return(shape)
      
    } else{
      stop("Error: Invalid Value to argument cod_uf.")
    }
  } else{
    stop(paste0("Error: Invalid Value to argument ano. It must be be one of the following: ", paste(str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+"), collapse = " ")))
  }
}


