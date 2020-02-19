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
select_data_type <- function(temp_meta, tp){

  if(tp=="original"){
    temp_meta <- temp_meta[  !(grepl(pattern="simplified", temp_meta$download_path)), ]
  } else {
    temp_meta <- temp_meta[  grepl(pattern="simplified", temp_meta$download_path), ]
  }
  return(temp_meta)
}



#' Download geopackage to tempdir
#'
#'
#' @param filesD A string with the url address of a geobr dataset
#' @export
#' @family support functions
#'
download_gpkg <- function(filesD){ # showProgress = TRUE # TRUE displays progress bar
  temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
  httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))
  return(temps)
  }

# nocov end
