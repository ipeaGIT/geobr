#' Download shape files of Brazilian municipalities as sf objects.
#'
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#'
#' @param year Year of the data (defaults to 2010)
#' @param code_muni The 7-digit code of a municipality. If the two-digit code or a two-letter uppercase abbreviation of
#'  a state is passed, (e.g. 33 or "RJ") the function will load all municipalities of that state. If code_muni="all", all municipalities of the country will be loaded.
#' @param tp Whether the function returns the 'original' dataset with high resolution or a dataset with 'simplified' borders (Default)
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read specific municipality at a given year
#'   mun <- read_municipality(code_muni=1200179, year=2017)
#'
#'# Read all municipalities of a state at a given year
#'   mun <- read_municipality(code_muni=33, year=2010)
#'   mun <- read_municipality(code_muni="RJ", year=2010)
#'
#'# Read all municipalities of the country at a given year
#'   mun <- read_municipality(code_muni="all", year=2018)
#'
#'}

read_municipality <- function(code_muni, year=NULL, tp="simplified"){

# 1.1 Verify year input
  if (is.null(year)){ year <- 2010}

# Get metadata with data addresses
  metadata <- download_metadata()

# Select metadata geo
  temp_meta <- subset(metadata, geo=="municipality")

  # Select type
  if(tp=="original"){
    temp_meta <- temp_meta[  !(grepl(pattern="simplified", temp_meta$download_path)), ]
  } else {
    temp_meta <- temp_meta[  grepl(pattern="simplified", temp_meta$download_path), ]
  }



# 2.1 Verify year input

  # Test if code_muni input is null
  if(!(year %in% temp_meta$year)){ stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                                                paste(unique(temp_meta$year),collapse = " ")))
    }

# Select metadata year
  x <- year
  temp_meta <- subset(temp_meta, year==x)
  message(paste0("Using data from year ", x))


# BLOCK 2.1 From 1872 to 1991  ----------------------------

  if( x < 1992){

    # list paths of files to download
    filesD <- as.character(temp_meta$download_path)

    # download files
    temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))

    # read sf
    temp_sf <- sf::st_read(temps, quiet=T)

    return(temp_sf)
    } else {


# BLOCK 2.2 From 2000 onwards  ----------------------------

# 2.2 Verify code_muni Input

  # Test if code_muni input is null
    if(is.null(code_muni)){ stop("Value to argument 'code_muni' cannot be NULL") }

  # if code_muni=="all", read the entire country
    if(code_muni=="all"){ message("Loading data for the whole country. This might take a few minutes.\n")

      # list paths of files to download
      filesD <- as.character(temp_meta$download_path)

      # input for progress bar
      total <- length(filesD)
      pb <- utils::txtProgressBar(min = 0, max = total, style = 3)

      # download files
      lapply(X=filesD, function(x){
        i <- match(c(x),filesD)
        httr::GET(url=x, #httr::progress(),
                  httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T))
        utils::setTxtProgressBar(pb, i)
      }
      )
      # closing progress bar
      close(pb)

      # read files and pile them up
      files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
      files <- paste0(tempdir(),"/",files)
      files <- lapply(X=files, FUN= sf::st_read, quiet=T)
      sf <- do.call('rbind', files)
      return(sf)
    }

  else if( !(substr(x = code_muni, 1, 2) %in% temp_meta$code) & !(substr(x = code_muni, 1, 2) %in% temp_meta$code_abrev)){

      stop("Error: Invalid Value to argument code_muni.")

  } else{

    # list paths of files to download
    if (is.numeric(code_muni)){ filesD <- as.character(subset(temp_meta, code==substr(code_muni, 1, 2))$download_path) }
    if (is.character(code_muni)){ filesD <- as.character(subset(temp_meta, code_abrev==substr(code_muni, 1, 2))$download_path) }

    # download files
    temps <- paste0(tempdir(),"/",unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD,  httr::progress(), httr::write_disk(temps, overwrite = T))

    # read sf
    sf <- sf::st_read(temps, quiet=T)

      if(nchar(code_muni)==2){
        return(sf)

      } else if(code_muni %in% sf$code_muni){    # Get Municipio
          x <- code_muni
          sf <- subset(sf, code_muni==x)
          return(sf)
      } else{
          stop("Error: Invalid Value to argument code_muni.")
      }
  }
}}
