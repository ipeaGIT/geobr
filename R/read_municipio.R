## Pacotes
library(stringr)
library(sf)
library(dplyr)
library(magrittr)


# Diretorio raiz
root_dir <- "L:\\\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\municipio"

#### Função de Leitura para os shapes do municipio ####

read_municipio <- function(year=NULL, cod_mun=NULL){

  if(is.null(year) || is.null(cod_mun)){ #testa se os parametros são nulos;
    stop("Error: Invalid value to argument year or argument cod_mun.") 
  }
  if(year %in% str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+")){ #testa se o year existe;
    if(substr(x = cod_mun, 1, 2) %in% substr(list.files(paste0(root_dir, "\\MU_", year)), 1, 2)){ #testa se o estado existe;
    
   shape <- readRDS(paste0(root_dir, "\\MU_", year, "\\", substr(x = cod_mun, 1, 2), "MU.rds")) 
    
     if(cod_mun %in% shape$cod_mun){ #testa se o municipio existe;
        shape %<>% filter(cod_mun==cod_mun)
       return(shape)
     } else{
       stop("Error: Invalid Value to argument cod_mun.")
     }
      } else{
        stop("Error: Invalid Value to argument cod_mun.")
      }
    } else{
      stop(paste0("Error: Invalid Value to argument year. It must be be one of the following: ", paste(str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+"), collapse = " ")))
   }
}


