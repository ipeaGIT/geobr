## Pacotes
library(stringr)
library(sf)
library(dplyr)
library(magrittr)
library(readr)


# Diretorio raiz
root_dir <- "L:/# DIRUR #/ASMEQ/pacoteR_shapefilesBR/data/meso_regiao"


#### Função de Leitura para os shapes da mesoregiao ----

read_mesorregiao <- function(year=NULL, cod_meso=NULL){
  
  # Test year input
  if(is.null(year)){
    year <- str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+") %>% max()
    cat("Using data from latest year available:", year, "\n")
  } else {
    # test if year input exists
    if(!(year %in% str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+"))){
      stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ", paste(str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+"), collapse = " ")))
    }
  }
  
  # Test meso input
  if(is.null(cod_meso)){ # if NULL, read the entire country
    cat("Using data from entire country \n")
    files <- list.files(paste0(root_dir, "\\ME_", year), full.names=T)
    files <- lapply(X=files, FUN= readRDS)
    shape <- do.call('rbind', files)
    return(shape)
  } 
  
  if( !(substr(x = cod_meso, 1, 2) %in% substr(list.files(paste0(root_dir, "\\ME_", year)), start =  1, stop = 2))){
    stop("Error: Invalid value to argument cod_meso.") 
    
  } else{
    shape <- readRDS(paste0(root_dir, "\\ME_", year, "\\", substr(x = cod_meso, 1, 2), "ME.rds")) 
    if(cod_meso %in% shape$cod_meso){ #testa se a mesoregiao existe;
      cod_meso_auxiliar <- cod_meso
      shape %<>% filter(cod_meso==cod_meso_auxiliar)
      return(shape)
      
    } else{stop("Error: Invalid Value to argument cod_meso.")}
  }
  
}