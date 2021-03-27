#' Download spatial data of Brazilian roads
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674).
#'
#' @param year Year of the data. Defaults to `2020` month `01`.

federal_highway <-
  function(year = 2021,month = 1, simplified = TRUE, showProgress = TRUE) {
    
    # Get metadata with data url addresses
    temp_meta <- select_metadata(geography="highway", year=year,month = month,  simplified=simplified)
    
    # BLOCK 2.2 From 2000 onwards  ----------------------------
      
    files <- c("201301", "201503", "201606", "201609",
               "201612", "201703", "201706", "201710",
               "201801", "201803", "201807", "201810",
               "201811", "201903", "201907", "201910",
               "202001", "202004", "202007", "202010",
               "202101")
    
    # 2.2 Verify code_muni Input
    period <- ifelse(nchar(month)==1,paste0(year,"0",month),paste0(year,month))

    if(period %in% files){ 
      message("Loading data for the whole country. This might take a few minutes.\n")
        
        # list paths of files to download
        file_url <- as.character(temp_meta$download_path)
        
        # download files
        temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
        return(temp_sf)
      } else{
          stop("Error: Invalid Value to argument year or month.")
      }
  }

