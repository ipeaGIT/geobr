#' Download shape files of weighting areas of the Brazilian Population Census
#'
#' @param CODE One can either pass the 7-digit code of a Municipality or the 2-digit code of a State. The function will load the shape files of all weighting areas in the specified geography
#' @param year the year of the data download (defaults to 2010)
#'
#' @return
#' @export
#' library(geobr)
#' @examples \dontrun{
#'
#' library(geobr)
#'
#'dados <- read_areaponderacao(year=2010)
#'dados <- read_areaponderacao(3500000,2010)
#'dados <- read_areaponderacao(123,2010)
#'dados <- read_areaponderacao("df",2010)
#'dados <- read_areaponderacao(1302603,2010)
#'dados <- read_areaponderacao(35)
#'dados <- read_areaponderacao(14,2010)
#'dados <- read_areaponderacao()
#'
#'# map it
#'library(mapview)
#'mapview(dados)
#' }
#'
#'
#'
#'
read_areaponderacao <- function(CODE = NULL,year = NULL){
  ## Pacotes
  library(stringr)
  library(sf)
  library(dplyr)
  library(magrittr)

  # definindo diretorio de download dos arquivos
  dir.proj <- paste0("L:\\\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\area_ponderacao")

  library(assertthat)
  # verificando se a pessoa entrou com uma string
  if( is.string(CODE)) {
    stop(paste0("Invalid value to UF or MUN"))
  }

  if(is.null(year)){
    year <- 2010
    cat("Using data from year 2010")
  } else {
    # test if year input exists
    if(!(year %in% str_extract(list.files(dir.proj), pattern = "[0-9]+"))){
      stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ", paste(str_extract(list.files(dir.proj), pattern = "[0-9]+")) , collapse = " "))
    }
  }

  # CODE NULL
  if( is.null(CODE)) {
    #ler brasil
    f <- list.files(paste(dir.proj,year,sep="/"),pattern = "^\\d")
    files <- list.files(paste(dir.proj,year,f,sep="/"),full.names = T)
    files <- lapply(X=files, FUN= readRDS)
    files <- lapply(X=files, FUN= as.data.frame)
    shape <- do.call('rbind', files)
    shape <- st_sf(shape)
    return(shape)
  }

  if(nchar(CODE) == 2) {
    if(!(CODE %in% as.numeric(list.files(paste(dir.proj,year,sep="/"),pattern = "^\\d"))) ){
      stop(paste0("Invalid value to UF. Must be one of the following: 11, 12, 13, 14, 15, 16, 17, 21, 22, 23, 24, 25, 26, 27, 28, 29, 31, 32, 33, 35, 41, 42, 43, 50, 51, 52, 53"))
    }

    if (length(list.files(paste(dir.proj,year,CODE,sep="/")))==0){stop(paste0("UF has no weighting area."))}

    files <- list.files(paste(dir.proj,year,CODE,sep="/"),full.names = T)
    files <- lapply(X=files, FUN= readRDS)
    files <- lapply(X=files, FUN= as.data.frame)
    shape <- do.call('rbind', files)
    shape <- st_sf(shape)
    return(shape)

    }

  if(nchar(CODE) == 7) {
    if( !(CODE %in% substr(list.files(paste(dir.proj, year,substr(CODE,1,2),sep="\\")), start =  1, stop = 7))){
      stop(paste0("Invalid value to MUN."))
    }
    return(readRDS(paste(paste(dir.proj,year,substr(CODE,1,2),CODE,sep="\\"),"_areaponderacao_",year,".rds",sep="")))
  }

  stop(paste0("Invalid value to CODE."))
}

