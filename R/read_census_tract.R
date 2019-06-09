#' Download shape files of census sectors of the Brazilian Population Census
#'
#' @param CODE One can either pass the 7-digit code of a Municipality or the 2-digit code of a State.If CODE="all", all census sectors of the country are loaded.
#' @param year the year of the data download (defaults to 2010)
#' @param zone "urban" or "rural" for separation in the year 2000
#' @export
#' @family general area functions
#' @examples \dontrun{
#' # Exemplos
#'dados <- read_census_tract(year=2010)
# dados <- read_census_tract(3500000,2010)
#'dados <- read_census_tract(123,2010)
#'dados <- read_census_tract("df",2010)
#'dados <- read_census_tract(1302603,2010)
#'dados <- read_census_tract(35)
#'dados <- read_census_tract(14,2010)
#'dados <- read_census_tract()
#'
#'# mapa
#'library(mapview)
#'mapview(dados)
#' }
#'
#'
#'
#'
read_census_tract <- function(CODE = NULL,year = NULL, zone = "urban"){
  ## Pacotes
  library(stringr)
  library(sf)
  library(dplyr)
  library(magrittr)

  # definindo diretorio de download dos arquivos
  dir.proj <- paste0("\\\\storage6\\usuarios\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\setor_censitario")

  if (year==2000 & zone == "urban") {
    dir.proj <- paste0("\\\\storage6\\usuarios\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\setor_censitario\\Urbano")
  } else if (year==2000 & zone == "rural") {
    dir.proj <- paste0("\\\\storage6\\usuarios\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\setor_censitario\\Rural")
  }


  library(assertthat)
  # verificando se a pessoa entrou com uma string
  if( (is.string(CODE) & CODE != "ALL")|is.null(CODE)) {
    stop(paste0("Invalid value to UF or MUN"))
  }


  if(is.null(year)){
    year <- str_extract(list.files(dir.proj), pattern = "[0-9]+") %>% max()
    cat("Using data from latest year available:", year,"\n")
  } else {
    # test if year input exists
    if(!(year %in% str_extract(list.files(dir.proj), pattern = "[0-9]+"))){
      stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ", paste(str_extract(list.files(dir.proj), pattern = "[0-9]+")) , collapse = " "))
    }
  }

  if(CODE=="all"){
    cat("Loading data for the whole country \n")
    f <- list.files(paste0(dir.proj,"\\SC_",year),pattern = "^\\d")
    files <- list.files(paste0(dir.proj,"\\SC_",year,"/",f),pattern = ".rds$|.RDS$",full.names = TRUE)
    files <- lapply(X=files, FUN= readr::read_rds)
    files <- lapply(X=files, FUN= as.data.frame)
    shape <- do.call('rbind', files)
    shape <- st_sf(shape)
    return(shape)
  }

  if(nchar(CODE) == 2) {
    if(!(CODE %in% as.numeric(list.files(paste0(dir.proj,"\\SC_",year),pattern = "^\\d"))) ){
      stop(paste0("Invalid value to UF. Must be one of the following: 11, 12, 13, 14, 15, 16, 17, 21, 22, 23, 24, 25, 26, 27, 28, 29, 31, 32, 33, 35, 41, 42, 43, 50, 51, 52, 53"))
    }

    if (length(list.files(paste0(dir.proj,"\\SC_",year,"/",CODE)))==0){stop(paste0("UF has no census sectors."))}

    files <- list.files(paste0(dir.proj,"\\SC_",year,"/",CODE),pattern = ".rds$|.RDS$",full.names = TRUE)
    files <- lapply(X=files, FUN= readr::read_rds)
    files <- lapply(X=files, FUN= as.data.frame)
    shape <- do.call('rbind', files)
    shape <- st_sf(shape)
    return(shape)

  }

  if(nchar(CODE) == 7) {
    if( !(CODE %in% substr(list.files(paste(dir.proj, paste0("SC_",year),substr(CODE,1,2),"municipios",sep="\\")), start =  3, stop = 9))){
      stop(paste0("Invalid value to MUN."))
    }
    if (length(list.files(paste(paste(dir.proj, paste0("SC_",year),substr(CODE,1,2),"municipios\\",sep="\\"),"SC",CODE,".rds",sep="")))==1) {
      return(readr::read_rds(paste(paste(dir.proj, paste0("SC_",year),substr(CODE,1,2),"municipios\\",sep="\\"),"SC",CODE,".rds",sep="")))
      } else {
    return(readr::read_rds(paste(paste(dir.proj, paste0("SC_",year),substr(CODE,1,2),"municipios\\",sep="\\"),"SC",CODE,".RDS",sep="")))
        }
  }

  stop(paste0("Invalid value to CODE."))
}
