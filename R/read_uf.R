## Pacotes
library(stringr)
library(sf)
library(dplyr)
library(magrittr)


# Diretorio raiz
root_dir <- "L:\\\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\uf"

#### Função de Leitura para os shapes da UF ####

read_uf <- function(year=NULL, cod_uf=NULL, name_uf=NULL){
  
  # Test year input
  if(is.null(year)){ #testa se os parametros são nulos;
    year <- str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+") %>% max()
    cat("Using data from latest year available:", year)
    } else {
      # testa se o year existe;
      if(!(year %in% str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+"))){
        stop(paste0("Error: Invalid Value to argument year. It must be be one of the following: ", paste(str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+"), collapse = " ")))
      }
    }
  
  # Test UF input
  if(is.null(cod_uf)){ 
    stop("Error: Invalid value to argument cod_uf.") 
    }
    else
      {
      if( !(cod_uf %in% substr(list.files(paste0(root_dir, "\\UF_", year)), start =  1, stop = 2))){
        stop("Error: Invalid value to argument cod_uf.") 
      }
          }
      
      shape <- readRDS(paste0(root_dir, "\\UF_", year, "\\", substr(x = cod_uf, 1, 2), "UF.rds")) 
      return(shape)

}


