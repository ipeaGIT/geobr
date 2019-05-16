## Pacotes
library(stringr)
library(sf)
library(dplyr)
library(magrittr)


# Diretorio raiz
root_dir <- "L:\\\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\micro_regiao"


#### Função de Leitura para os shapes da microrregião ####

read_microrregiao <- function(ano=NULL, cod_micro=NULL){
  
  if(is.null(ano) || is.null(cod_micro)){ #testa se os parametros são nulos;
    stop("Error: Invalid value to argument ano or argument cod_micro.") 
  }
  if(ano %in% str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+")){ #testa se o ano existe;
    if(substr(x = cod_micro, 1, 2) %in% substr(list.files(paste0(root_dir, "\\MI_", ano)), 1, 2)){ #testa se o estado existe;
      
      shape <- readRDS(paste0(root_dir, "\\MI_", ano, "\\", substr(x = cod_micro, 1, 2), "MI.rds")) 
      
      if(cod_micro %in% shape$cod_micro){ #testa se a microrregião existe;
        shape %<>% filter(cod_micro==cod_micro)
        return(shape)
      } else{
        stop("Error: Invalid Value to argument cod_micro.")
      }
    } else{
      stop("Error: Invalid Value to argument cod_micro.")
    }
  } else{
    stop(paste0("Error: Invalid Value to argument ano. It must be one of the following: ", paste(str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+"), collapse = " ")))
  }
}


