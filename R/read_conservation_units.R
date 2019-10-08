

read_conservation_units <- function(date=NULL){
  
  # Get metadata with data addresses
  metadata <- geobr::download_metadata()
  
  
  # Select geo
  temp_meta <- subset(metadata, geo=="conservation_units")
  
  
  # 1.1 Verify year input
  if(is.null(date)){ stop(paste0("Error: Invalid Value to argument 'date'. It must be one of the following: ",
                                 paste(unique(temp_meta$year),collapse = " ")))
    
  } else if (date %in% temp_meta$year){ temp_meta <- temp_meta[temp_meta[,2] == date, ]
  
  } else { stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                       paste(unique(temp_meta$year),collapse = " ")))
  }
  
  
  # # Select metadata year
  # x <- year
  # temp_meta <- subset(temp_meta, year==x)
  
  # list paths of files to download
  filesD <- as.character(temp_meta$download_path)
  
  # download files
  temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
  httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))
  
  # read sf
  temp_sf <- readr::read_rds(temps)
  return(temp_sf)
}


b <- read_conservation_units(date=201909)
