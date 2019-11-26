read_rgint <- function(code_rgint, year = NULL){

  
  # Get metadata with data addresses
  metadata <- geobr::download_metadata()
  
  # verify input type
  #if(is.null(type)){type <- "reg_mun"}
  #if(all(type != c("rgint","rgi","reg_mun"))) stop("type must be 'rgint' or 'rgi' or 'reg_mun'")
  
  # Select geo
  temp_meta <- subset(metadata, geo=="intermediate_regions")
  
  # 1.1 Verify year input
  if (is.null(year)){ year <- 2017 
  message(paste0("Using data from year ", year))}
  
  if(!(year %in% temp_meta$year)){ stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                                               paste(unique(temp_meta$year),collapse = " ")))
  } else {
    # # Select metadata year
    x <- year
    temp_meta <- subset(temp_meta, year==x)
    
    # list paths of files to download
    filesD <- as.character(temp_meta$download_path)
    
    # download files
    temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))
    
    # read sf
    temp_sf <- readr::read_rds(temps)

  }

    if(code_rgint=="all"){ message("Loading data for the whole country. This might take a few minutes.\n")
     temp_sf <- temp_sf 
    } else if(code_rgint %in% temp_sf$abbrev_state){
      y <- code_rgint
      temp_sf <- subset(temp_sf, abbrev_state == y)
    } else if(code_rgint %in% temp_sf$code_state){
      y <- code_rgint
      temp_sf <- subset(temp_sf, code_state == y)
    } else {stop(paste0("Error: Invalid Value to argument 'code_rgint'. UF must be valid",collapse = " "))}
  
  return(temp_sf) 
}
