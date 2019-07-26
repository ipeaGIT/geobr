#' Download shape files of census sectors of the Brazilian Population Census
#'
#' @param code_tract One can either pass the 7-digit code of a Municipality or the 2-digit code of a State.If code_tract="all", all census sectors of the country are loaded.
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
read_census_tract <- function(code_tract, year = NULL, zone = "urban"){

  # Get metadata with data addresses
  tempf <- file.path(tempdir(), "metadata.rds")
  # check if metadata has already been downloaded
  if (file.exists(tempf)) {
    metadata <- readr::read_rds(tempf)

  } else { # download it and save to metadata
    httr::GET(url="http://www.ipea.gov.br/geobr/metadata/metadata.rds", httr::write_disk(tempf, overwrite = T))
    metadata <- readr::read_rds(tempf)
  }

  # Select geo
  temp_meta <- subset(metadata, geo=="setor_censitario")




  # Verify year input
  if (is.null(year)){ cat("Using data from year 2010\n")
    temp_meta <- subset(temp_meta, year==2010)
    year<-2010

  } else if (year %in% temp_meta$year){ temp_meta <- temp_meta[temp_meta[,2] == year, ]

  if (year<=2007 & zone == "urban") {cat("Using data of Urban census tracts\n")
                                      temp_meta <- temp_meta[temp_meta[,3] %like% "U", ]}

  if (year<=2007 & zone == "rural") {cat("Using data of Rural census tracts\n")
                                          temp_meta <- temp_meta[temp_meta[,3] %like% "R", ]}

  } else { stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                       paste(unique(temp_meta$year),collapse = " ")))
  }


  # Verify code_tract input

  # Test if code_tract input is null
  if(is.null(code_tract)){ stop("Value to argument 'code_tract' cannot be NULL") }


    # if code_tract=="all", read the entire country
    if(code_tract=="all"){ cat("Loading data for the whole country. This might take a few minutes.\n")

      # list paths of files to download
      filesD <- as.character(temp_meta$download_path)


      # download files
      counter <- 0
      lapply(X=filesD, function(X){ counter <<- counter + 1
      print(paste("Downloading ", counter, " of ",length(filesD)," files"))
      httr::GET(url=X, httr::progress(),
                httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(X,"/"),tail,n=1L))), overwrite = T))})


      # read files and pile them up
      files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
      files <- paste0(tempdir(),"/",files)
      files <- lapply(X=files, FUN= readr::read_rds)
      sf <- do.call('rbind', files)
      return(sf)
    }

    else if( (!(substr(x = code_tract, 1, 2) %in% temp_meta$code) & !(toupper(substr(x = code_tract, 1, 2)) %in% temp_meta$code_abrev)
              )&(!(paste0("U",substr(x = code_tract, 1, 2)) %in% substr(temp_meta$code, 1, 3)) & !(toupper(substr(x = code_tract, 1, 2)) %in% temp_meta$code_abrev)
                 )&(!(paste0("R",substr(x = code_tract, 1, 2)) %in% substr(temp_meta$code, 1, 3)) & !(toupper(substr(x = code_tract, 1, 2)) %in% temp_meta$code_abrev))
            ){

      stop("Error: Invalid Value to argument code_tract.")

    } else{

      # list paths of files to download
      if (year<=2007 & zone == "urban") {

        if (is.numeric(code_tract)){ filesD <- as.character(subset(temp_meta, code==paste0("U",substr(code_tract, 1, 2)))$download_path) }
        if (is.character(code_tract)){ filesD <- as.character(subset(temp_meta, code_abrev==toupper(substr(code_tract, 1, 2)))$download_path) }

      } else if (year<=2007 & zone == "rural") {

        if (is.numeric(code_tract)){ filesD <- as.character(subset(temp_meta, code==paste0("R",substr(code_tract, 1, 2)))$download_path) }
        if (is.character(code_tract)){ filesD <- as.character(subset(temp_meta, code_abrev==toupper(substr(code_tract, 1, 2)))$download_path) }

      } else {

      if (is.numeric(code_tract)){ filesD <- as.character(subset(temp_meta, code==substr(code_tract, 1, 2))$download_path) }
      if (is.character(code_tract)){ filesD <- as.character(subset(temp_meta, code_abrev==toupper(substr(code_tract, 1, 2)))$download_path) }

        }
      # download files
      temps <- paste0(tempdir(),"/",unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
      httr::GET(url=filesD,  httr::progress(), httr::write_disk(temps, overwrite = T))

      # read sf
      sf <- readr::read_rds(temps)

      if(nchar(code_tract)==2){
        return(sf)

      } else if(code_tract %in% sf$code_muni){    # Get Municipio
        x <- code_tract
        sf <- subset(sf, code_muni==x)
        return(sf)
      } else{
        stop("Error: Invalid Value to argument code_tract.")
      }
    }
  }
