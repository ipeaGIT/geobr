## Pacotes
library(stringr)
library(sf)
library(dplyr)
library(magrittr)


# Diretorio raiz
root_dir <- "L:\\\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\municipio"

#### Função de Leitura para os shapes do municipio ####

read_municipio <- function(year=NULL, cod_mun=NULL){

  # Test year input
  if(is.null(year)){
    year <- str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+") %>% max()
    cat("Using data from latest year available:", year)
  } else {
    # test if year input exists
    if(!(year %in% str_extract(list.files(root_dir, pattern = ".*\\MU_"), pattern = "[0-9]+"))){
      stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ", paste(str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+"), collapse = " ")))
    }
  }
  
  
# testa se o estado existe;
  
  if(substr(x = cod_mun, 1, 2) %in% substr(list.files(paste0(root_dir, "\\MU_", year)), 1, 2)){ 
    
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


