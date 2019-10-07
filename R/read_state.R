#' Download shape files of Brazilian states as sf objects. Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @param year Year of the data (defaults to 2010)
#' @param code_state The two-digit code of a state or a two-letter uppercase abbreviation (e.g. 33 or "RJ"). If code_state="all", all states will be loaded.
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read specific state at a given year
#'   uf <- read_state(code_state=12, year=2017)
#'
#' # Read specific state at a given year
#'   uf <- read_state(code_state="SC", year=2000)
#'
#' # Read all states at a given year
#'   ufs <- read_state(code_state="all", year=2010)
#'
#'}

read_state <- function(code_state, year=NULL){

  # Get metadata with data addresses
  metadata <- geobr::download_metadata()


  # Select geo
  temp_meta <- subset(metadata, geo=="uf")

  # Verify year input
  if (is.null(year)){ message("Using data from year 2010\n")
    year <- 2010
    temp_meta <- subset(temp_meta, year==2010)

  } else if (year %in% temp_meta$year){ temp_meta <- temp_meta[temp_meta[,2] == year, ]

  } else { stop(paste0("Error: Invalid Value to argument 'year'. It must be one of the following: ",
                       paste(unique(temp_meta$year),collapse = " ")))
  }




# BLOCK 2.1 From 1872 to 1991  ----------------------------
  x <- year

if( x < 1992){

#   if( !(substr(x = code_state, 1, 2) %in% temp_meta$code) &
#       !(substr(x = code_state, 1, 2) %in% temp_meta$code_abrev) &
#       !(substr(x = code_state, 1, 3) %in% "all")) {
#       stop("Error: Invalid Value to argument code_state.")
#       }

  message("Loading data for the whole country\n")

  # list paths of files to download
  filesD <- as.character(temp_meta$download_path)

  # download files
  temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
  httr::GET(url=filesD, httr::progress(), httr::write_disk(temps, overwrite = T))

  # read sf
  temp_sf <- readr::read_rds(temps)

  return(temp_sf)
} else {


# BLOCK 2.2 From 2000 onwards  ----------------------------

  # Verify code_state input

  # Test if code_state input is null
  if(is.null(code_state)){ stop("Value to argument 'code_state' cannot be NULL") }

  # if code_state=="all", read the entire country
    if(code_state=="all"){ message("Loading data for the whole country\n")

      # list paths of files to download
      filesD <- as.character(temp_meta$download_path)

      # input for progress bar
      total <- length(filesD)
      pb <- utils::txtProgressBar(min = 0, max = total, style = 3)

      # download files
      lapply(X=filesD, function(x){
        i <- match(c(x),filesD);
        httr::GET(url=x, #httr::progress(),
                  httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T));
        utils::setTxtProgressBar(pb, i)
      }
      )
      # closing progress bar
      close(pb)

      # read files and pile them up
      files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
      files <- paste0(tempdir(),"/",files)
      files <- lapply(X=files, FUN= readr::read_rds)
      shape <- do.call('rbind', files)
      return(shape)
    }

  if( !(substr(x = code_state, 1, 2) %in% temp_meta$code) & !(substr(x = code_state, 1, 2) %in% temp_meta$code_abrev)){
      stop("Error: Invalid Value to argument code_state.")

  } else{

    # list paths of files to download
    if (is.numeric(code_state)){ filesD <- as.character(subset(temp_meta, code==substr(code_state, 1, 2))$download_path) }
    if (is.character(code_state)){ filesD <- as.character(subset(temp_meta, code_abrev==substr(code_state, 1, 2))$download_path) }


    # download files
    temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD, httr::write_disk(temps, overwrite = T))

    # read sf
    shape <- readr::read_rds(temps)

    if(nchar(code_state)==2){
      return(shape)

    } else if(code_state %in% shape$code_state){
      x <- code_state
      shape <- subset(shape, code_state==x)
      return(shape)

    } else{
      stop("Error: Invalid Value to argument code_state.")
    }
  }
}}
