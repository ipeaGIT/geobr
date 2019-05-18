## Pacotes
library(stringr)
library(sf)
library(dplyr)
library(magrittr)
library(readr)


# Diretorio raiz
root_dir <- "L:/# DIRUR #/ASMEQ/pacoteR_shapefilesBR/data/uf"

# Leitura das siglas dos estados
# source("L:/# DIRUR #/ASMEQ/pacoteR_shapefilesBR/data/sg.txt")

#### Função de Leitura para os shapes da UF ----

#' Download shape files of state
#'
#' @param year the year of the data download (defaults to 2010)
#' @param cod_uf 2-digit state code. If not informed, all states will be loaded.
#' @export
#' @family general area functions
#' @examples \dontrun{
#'
#' library(geobr)
#'
#' # Read specific municipality at a given year
#'   mun <- read_municipio(cod_uf=12, year=2017)
#'
#'# Read al lstate at a given year
#'   mun <- read_municipio(cod_mun=12, year=2010)
#'
#'}
read_uf <- function(year=NULL, cod_uf=NULL){

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

  # Test UF input
  if(is.null(cod_uf)){ # if NULL, read the entire country
    cat("Using data from entire country \n")
    files <- list.files(paste0(root_dir, "\\UF_", year), full.names=T)
    files <- lapply(X=files, FUN= readRDS)
    shape <- do.call('rbind', files)
    return(shape)
  } else if(is.numeric(cod_uf)==TRUE){

      if( !(cod_uf %in% substr(list.files(paste0(root_dir, "\\UF_", year)), start =  1, stop = 2))){
        stop("Error: Invalid value to argument cod_uf.")
      } else{
        shape <- readRDS(paste0(root_dir, "/UF_", year, "/", substr(x = cod_uf, 1, 2), "UF.rds"))
        return(shape)
      }

  } else if(toupper(cod_uf) %in% sg){
    source("L:/# DIRUR #/ASMEQ/pacoteR_shapefilesBR/data/read_tab_sg.R")
    cod_uf <- read_tab(cod_uf)
    shape <- readRDS(paste0(root_dir, "/UF_", year, "/", substr(x = cod_uf, 1, 2), "UF.rds"))
    return(shape)
  }  else{
    stop("Error: Invalid value to argument cod_uf.")
    }

}


