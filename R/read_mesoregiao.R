## Pacotes
library(stringr)
library(sf)
library(dplyr)
library(magrittr)
library(readr)


# Diretorio raiz
root_dir <- "L:/# DIRUR #/ASMEQ/pacoteR_shapefilesBR/data/meso_regiao"


#### Função de Leitura para os shapes da mesoregiao ----

#' Download shape files of meso region.
#'
#' @param year the year of the data download (defaults to 2010)
#' @param cod_meso
#'
#' @param cod_meso x-digit code of the meso region. If a two-digit code of a state is passed,
#' the function will load all meso regions of that state. If cod_meso="all", all meso regions of the country are loaded.
#'
#' @export
#' @family general area functions
#' @examples \dontrun{
#'
#' library(geobr)
#'
#' # Read all meso regions of a state at a given year
#'   meso <- read_mesorregiao(cod_meso=12, year=2017)
#'
#'# Read all meso regions of the country at a given year
#'   meso <- read_mesorregiao(cod_meso="all", year=2010)
#' }
#'

read_mesorregiao <- function(year=NULL, cod_meso=NULL){

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

  # Test meso input
    if(is.null(cod_meso)){ stop("Value to argument 'cod_meso' cannot be NULL") }

    # if "all", read the entire country
    else if(cod_meso=="all"){

    cat("Loading data for the whole country \n")
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
