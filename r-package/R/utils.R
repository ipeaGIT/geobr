############# Support functions for geobr
# nocov start


# Select data type: 'original' or 'simplified' (default)
#
#
select_data_type <- function(temp_meta, tp){

  if(tp=="original"){
    temp_meta <- temp_meta[  !(grepl(pattern="simplified", temp_meta$download_path)), ]
  } else {
    temp_meta <- temp_meta[  grepl(pattern="simplified", temp_meta$download_path), ]
  }
  return(temp_meta)
}





# Download geopackage to tempdir
#
#
download_gpkg <- function(filesD){
  temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
  httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))
  return(temps)
  }

# nocov end
