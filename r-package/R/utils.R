############# Support functions for geobr
# nocov start



#' Select data type: 'original' or 'simplified' (default)
#'
#'
#'
#' @param temp_meta A dataframe with the url addresses of geobr datasets
#' @param tp A string indicating whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Default)
#' @export
#' @family support functions
#'
select_data_type <- function(temp_meta, tp=NULL){

  if(is.null(tp)){ return(temp_meta)
    }
  else if(tp=="original"){
    temp_meta <- temp_meta[  !(grepl(pattern="simplified", temp_meta$download_path)), ]
  }
  else if(tp=="simplified"){
    temp_meta <- temp_meta[  grepl(pattern="simplified", temp_meta$download_path), ]
  }

  return(temp_meta)
}



#' Download geopackage to tempdir
#'
#'
#' @param filesD A string with the url address of a geobr dataset
#' @param progress_bar Logical. Defaults to (TRUE) display progress bar
#' @export
#' @family support functions
#'
download_gpkg <- function(filesD, progress_bar = showProgress){

### one single file

  if(length(filesD)==1 & progress_bar == TRUE){

    # download file
    temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))
    return(temps)
    }

  else if(length(filesD)==1 & progress_bar == FALSE){

    # download file
    temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD, httr::write_disk(temps, overwrite = T))
    return(temps)
    }



### multiple files

  else if(length(filesD) > 1 & progress_bar == TRUE) {

    # input for progress bar
    total <- length(filesD)
    pb <- utils::txtProgressBar(min = 0, max = total, style = 3)

    # download files
    lapply(X=filesD, function(x){
      i <- match(c(x),filesD)
      httr::GET(url=x, #httr::progress(),
                httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T))
      utils::setTxtProgressBar(pb, i)})

    # closing progress bar
    close(pb)}

  else if(length(filesD) > 1 & progress_bar == FALSE) {

    # download files
    lapply(X=filesD, function(x){
      i <- match(c(x),filesD)
      httr::GET(url=x, #httr::progress(),
                httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T))})
    }
}







#' Load geopackage from tempdir to global environment
#'
#'
#' @param filesD A string with the url address of a geobr dataset
#' @param temps The address of a gpkg file stored in tempdir. Defaults to NULL
#' @export
#' @family support functions
#'
load_gpkg <- function(filesD, temps=NULL){

  ### one single file

  if(length(filesD)==1){

    # read sf
    temp_sf <- sf::st_read(temps, quiet=T)
    return(temp_sf)
  }

  else if(length(filesD) > 1){

    # read files and pile them up
    files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
    files <- paste0(tempdir(),"/",files)
    files <- lapply(X=files, FUN= sf::st_read, quiet=T)
    temp_sf <- do.call('rbind', files)
    return(temp_sf)
    }
}

# nocov end
