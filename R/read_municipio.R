## Pacotes
library(stringr)
library(sf)
library(dplyr)
library(magrittr)


# Diretorio raiz
root_dir <- "L:/# DIRUR #/ASMEQ/pacoteR_shapefilesBR/data/municipio"

# Leitura das siglas dos estados
  # ("L:/# DIRUR #/ASMEQ/pacoteR_shapefilesBR/data/sg.txt")


#' Download shape files of municipalities
#'
#' @param year the year of the data download (defaults to 2010)
#' @param cod_mun 7-digit code of the municipality. If a the two-digit code of a state is used,
#' the function will load all municipalities of that state. If not informed, all municipalities will be loaded.
#' @export
#' @family general area functions
#' @examples \dontrun{
#'
#' library(geobr)
#'
#' # Read specific municipality at a given year
#'   mun <- read_municipio(cod_mun=1200179, year=2017)
#'
#'# Read all municipalities of a state at a given year
#'   mun <- read_municipio(cod_mun=12, year=2010)
#'
#'}



read_municipio <- function(year=NULL, cod_mun=NULL){

  # Test year input
  if(is.null(year) & !is.null(cod_mun)){
    year <- 2010
    cat("Using data from year 2010")
  } else if(!is.null(year)){
    # test if year input exists
      if(!(year %in% stringr::str_extract(list.files(root_dir, pattern = ".*\\MU_"), pattern = "[0-9]+"))){
        stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ", paste(str_extract(list.files(root_dir, pattern = ".*\\_"), pattern = "[0-9]+"), collapse = " ")))
      }
  }

  # Test if cod_mun input is null
  if(is.null(cod_mun)){
    stop("Error: Value to argument 'cod_mun' can not be NULL")

  } else if(toupper(cod_mun) %in% sg){
      source("L:/# DIRUR #/ASMEQ/pacoteR_shapefilesBR/data/read_tab_sg.R")
      cod_uf <- read_tab(cod_mun)
      shape <- readRDS(paste0(root_dir, "/MU_", year, "/", substr(x = cod_uf, 1, 2), "MU.rds"))
      return(shape)

  } else if( !(substr(x = cod_mun, 1, 2) %in% substr(list.files(paste0(root_dir, "/MU_", year)), 1, 2))){
      stop("Error: Invalid Value to argument cod_mun.")

  } else{
      shape <- readRDS(paste0(root_dir, "/MU_", year, "/", substr(x = cod_mun, 1, 2), "MU.rds"))
      if(nchar(cod_mun)==2){
        return(shape)
      } else if(cod_mun %in% shape$cod_mun){    # Get Municipio
          x <- cod_mun
          shape %<>% filter(cod_mun==x)
          return(shape)
      } else{
          stop("Error: Invalid Value to argument cod_mun.")
      }
  }
}
