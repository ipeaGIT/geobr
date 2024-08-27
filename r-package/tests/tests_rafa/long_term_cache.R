ok # get etag of url
# create name of local_etag
# check if etag exsists locally / is identical
  # if yes, read local file
  # if now, save local tag and download file






# long-term cache

library(sf)
library(httr)
library(httr2)
library(httpcache)
am <- 'https://github.com/ipeaGIT/censobr/releases/download/v0.3.0/1970_population_v0.3.0.parquet'
as <- 'https://github.com/ipeaGIT/geobr/releases/download/v1.7.0/amazonia_legal_simplified.gpkg'


url_d <- dput(file_url)


url <- c("https://www.ipea.gov.br/geobr/data_gpkg/state/2010/11state_2010_simplified.gpkg",
         "https://www.ipea.gov.br/geobr/data_gpkg/state/2010/12state_2010_simplified.gpkg",
         "https://www.ipea.gov.br/geobr/data_gpkg/state/2010/13state_2010_simplified.gpkg"
         )


# otimo exemplo
# https://github.com/Robinlovelace/spanishoddata/blob/main/R/download_data.R
downloaded_files <- curl::multi_download(
  urls = url,
  destfiles = basename(url),
  progress = TRUE,
  resume = TRUE
)
return(downloaded_files$destfile)



# download file
download_files <- function(url){
  #input url
  #output path to local file

  # function for single url
  download_single_file <- function(url){

    dest_file <- basename(url)

    # Create a request object for the URL
    req <- httr2::request(url)

    # Add SSL configuration to the request (disabling SSL verification)
    req <- httr2::req_options(req, ssl_verifypeer = FALSE)

    # Perform the request and save the content to a file
    resp <- httr2::req_perform(req = req_progress(req, type = "down"),
                               path = dest_file)
    return(dest_file)
  }

  # results for input list
  out_file <- lapply(X = url, FUN = download_single_file)
  out_file <- unlist(out_file)
  return(out_file)

  }


get_etag_code <- function(url){
  #input url
  #output etag code

  # function for single url
  get_single_etag <- function(url){

    # Step 1: Create a request object for the URL
    try(req <- httr2::request(url), silent = TRUE)

    # Step 2: Set the method to HEAD to only retrieve headers
    req <- httr2::req_method(req, "HEAD")

    # Step 3: Perform the request and capture the response
    try(resp <- httr2::req_perform(req), silent = TRUE)
    # if(is.null(req$body)){ message("No internet connection.") }

    # !!!!! check internet connection

    # Step 4: Extract the ETag from the response headers
    etag <- httr2::resp_header(resp, "etag")
    return(etag)
    }

  # results for input list
  out_etag <- lapply(X = url, FUN = get_single_etag)
  out_etag <- unlist(out_etag)
  return(out_etag)
}


# check if
check_if_downloaded <- function(url){

  etag_code <- get_etag_code(url)


}

create_local_etag <- function(url, file_extension = '.gpkg'){

  file_basename <- basename(url)
  etag_code <- get_etag_code(url)

  # create etag file name
  etag_filename <- paste0('etag_', file_basename)
  etag_filename <- gsub(file_extension, '.rds', etag_filename)

  # check etag one by one
  # check if etag already exists
  if (file.exists(etag_filename)) {

    # if etags are identical read return path to local file
    etag_local <- readRDS(etag_filename)
    if (identical(etag_local, )){
      return(file_basename)
    }

  }

  # if etag does not exist, save it
  saveRDS(etag_code, etag_filename)

}









# get all etags for metadata table
aaa <- lapply(X = c(am, as), FUN = function(x){HEAD(url = x)$headers$etag})
unlist(aaa)


f <- 'C:/Users/user/Downloads/amazonia_legal (2).gpkg'

file.info(f)$ctime

fff <- HEAD(url = f)



#' metadata table should have url and etag

#' DOWNLOAD fun
#' 1)if etag is not saved locally,
#' download fun should save etag locally and download data
#' if etag and data exists locally, then compare against metadata
#





# pacotes:
https://enpiar.com/r/httpcache/articles/httpcache.html
https://github.com/dfsp-spirit/pkgfilecache

library(tools)

dest_dir = gsub("////", "/", normalizePath(R_user_dir("ipeadata-db","cache"), mustWork = FALSE))
cache_dir = paste0(dest_dir,"/control")
if (isFALSE(dir.exists(cache_dir))) {
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
}

urls_ibge = c(
  "https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2022/Brasil/BR/BR_Pais_2022.zip",
  "https://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/alteracoes_toponimicas_municipais/Alteracoes_Toponimicas_Municipais_2022.xls",
  "https://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/divisao_territorial/2022/DTB_2022.zip"
)

arqs_ibge = paste0(dest_dir,"/",basename(urls_ibge))

