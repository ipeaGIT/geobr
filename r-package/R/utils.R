############# Support functions for geobr
# nocov start



#' Select data type: 'original' or 'simplified' (default)
#'
#'
#'
#' @param temp_meta A dataframe with the file_url addresses of geobr datasets
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





#' Test year input
#'
#'
#'
#' @param temp_meta A dataframe with the file_url addresses of geobr datasets
#' @param y Year of the dataset (passed by red_ function)
#' @export
#' @family support functions
#'
test_year_input <- function(temp_meta, y=year){

  # NULL
  if (is.null(y)){  stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                                   paste(unique(temp_meta$year),collapse = " "))) }

  # invalid input
  else if (y %in% temp_meta$year){ message(paste0("Using year ", y))
                                  temp_meta <- temp_meta[temp_meta[,2] == y,]
                                  return(temp_meta) }

  # invalid input
  else { stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                         paste(unique(temp_meta$year), collapse = " ")))
    }


}





#' Download geopackage to tempdir
#'
#'
#' @param file_url A string with the file_url address of a geobr dataset
#' @param progress_bar Logical. Defaults to (TRUE) display progress bar
#' @export
#' @family support functions
#'
download_gpkg <- function(file_url, progress_bar = showProgress){

## one single file

  if(length(file_url)==1 & progress_bar == TRUE){

    # download file
    temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(file_url,"/"),tail,n=1L)))
    httr::GET(url=file_url, httr::progress(), httr::write_disk(temps, overwrite = T))

    # load gpkg
    temp_sf <- load_gpkg(file_url, temps)
    return(temp_sf)


    }

  else if(length(file_url)==1 & progress_bar == FALSE){

    # download file
    temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(file_url,"/"),tail,n=1L)))
    httr::GET(url=file_url, httr::write_disk(temps, overwrite = T))

    # load gpkg
    temp_sf <- load_gpkg(file_url, temps)
    return(temp_sf)
  }



## multiple files

  else if(length(file_url) > 1 & progress_bar == TRUE) {

    # input for progress bar
    total <- length(file_url)
    pb <- utils::txtProgressBar(min = 0, max = total, style = 3)

    # download files
    lapply(X=file_url, function(x){
      i <- match(c(x),file_url)
      httr::GET(url=x, #httr::progress(),
                httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T))
      utils::setTxtProgressBar(pb, i)})

    # closing progress bar
    close(pb)

    # load gpkg
    temp_sf <- load_gpkg(file_url)
    return(temp_sf)


    }

  else if(length(file_url) > 1 & progress_bar == FALSE) {

    # download files
    lapply(X=file_url, function(x){
      i <- match(c(x),file_url)
      httr::GET(url=x, #httr::progress(),
                httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T))})


    # load gpkg
    temp_sf <- load_gpkg(file_url)
    return(temp_sf)

    }
}







#' Load geopackage from tempdir to global environment
#'
#'
#' @param file_url A string with the file_url address of a geobr dataset
#' @param temps The address of a gpkg file stored in tempdir. Defaults to NULL
#' @export
#' @family support functions
#'
load_gpkg <- function(file_url, temps=NULL){

  ### one single file

  if(length(file_url)==1){

    # read sf
    temp_sf <- sf::st_read(temps, quiet=T)
    return(temp_sf)
  }

  else if(length(file_url) > 1){

    # read files and pile them up
    files <- unlist(lapply(strsplit(file_url,"/"), tail, n = 1L))
    files <- paste0(tempdir(),"/",files)
    files <- lapply(X=files, FUN= sf::st_read, quiet=T)
    temp_sf <- do.call('rbind', files)
    return(temp_sf)
  }

  # load gpkg to memory
  temp_sf <- load_gpkg(file_url, temps)
  return(temp_sf)
}

# nocov end
