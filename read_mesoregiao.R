## Pacotes
library(stringr)
library(sf)
library(dplyr)
library(magrittr)


# Diretorio raiz
root_dir <- "L:\\\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\municipio"


#### Função de Leitura para os shapes da mesoregião ####

read_mesoregiao <- function(ano=NULL, cod_meso=NULL){
  
  if(is.null(ano) || is.null(cod_meso)){ #testa se os parametros são nulos;
    stop("Error: Invalid value to argument ano or argument cod_meso.") 
  }
  if(ano %in% str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+")){ #testa se o ano existe;
    if(substr(x = cod_meso, 1, 2) %in% substr(list.files(paste0(root_dir, "\\ME_", ano)), 1, 2)){ #testa se o estado existe;
      
      shape <- readRDS(paste0(root_dir, "\\ME_", ano, "\\", substr(x = cod_meso, 1, 2), "ME.rds")) 
      
      if(cod_meso %in% shape$cod_meso){ #testa se o municipio existe;
        shape %<>% filter(cod_meso==cod_meso)
        return(shape)
      } else{
        stop("Error: Invalid Value to argument cod_meso.")
      }
    } else{
      stop("Error: Invalid Value to argument cod_meso.")
    }
  } else{
    stop(paste0("Error: Invalid Value to argument ano. It must be be one of the following: ", paste(str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+"), collapse = " ")))
  }
}


