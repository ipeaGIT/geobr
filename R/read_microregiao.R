## Pacotes
library(stringr)
library(sf)
library(dplyr)
library(magrittr)
library(readr)


# Diretorio raiz
root_dir <- "L:/# DIRUR #/ASMEQ/pacoteR_shapefilesBR/data/micro_regiao"


#### Função de Leitura para os shapes da microregiao ----

#' Title
#'
#' @param year the year of the data download (defaults to 2010)
#' @param cod_micro x-digit code of the micro region If a two-digit code of a state is passed,
#' the function will load all micro regions of that state. If cod_micro="all", all micro regions will be loaded.
#'
#' @return
#' @export
#'
#' @examples
read_microregiao <- function(year=NULL, cod_micro=NULL){

  # Test year input
  if(is.null(year)){
    year <- 2010
    cat("Using data from year 2010")
  } else {
    # test if year input exists
    if(!(year %in% str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+"))){
      stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ", paste(str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+"), collapse = " ")))
    }
  }

  # Test micro input
    if(is.null(cod_micro)){ stop("Error: Invalid value to argument cod_micro.") }
     
    
  # if "all", read the entire country
    else if(cod_micro=="all"){
    
    cat("Loading data for the whole country \n")
    files <- list.files(paste0(root_dir, "\\MI_", year), full.names=T)
    files <- lapply(X=files, FUN= readRDS)
    shape <- do.call('rbind', files)
    return(shape)
  }

  if( !(substr(x = cod_micro, 1, 2) %in% substr(list.files(paste0(root_dir, "\\MI_", year)), start =  1, stop = 2))){
    stop("Error: Invalid value to argument cod_micro.")

  } else{
    shape <- readRDS(paste0(root_dir, "\\MI_", year, "\\", substr(x = cod_micro, 1, 2), "MI.rds"))
    if(cod_micro %in% shape$cod_micro){ #testa se a microregiao existe;
      cod_micro_auxiliar <- cod_micro
      shape %<>% filter(cod_micro==cod_micro_auxiliar)
      return(shape)

    } else{stop("Error: Invalid Value to argument cod_micro.")}
  }

}
