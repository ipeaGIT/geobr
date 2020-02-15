#' Download shape files of IBGE's statistical grid (200 x 200 meters) as sf objects. Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @param year Year of the data (defaults to 2010). The only year available thus far is 2010.
#' @param code_grid The 7-digit code of a grid quadrant If the two-letter abbreviation of a state is used,
#' the function will load all grid quadrants that intersect with that state. If code_grid="all", the grid of the whole country will be loaded.
#' @export
#' @family general area functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' # Read specific municipality at a given year
#'   grid <- read_statistical_grid(code_grid = 45, year=2010)
#'
#'# Read all municipalities of a state at a given year
#'   state_grid <- read_statistical_grid(code_grid = "RJ")
#'
#'}

read_statistical_grid <- function(code_grid, year=NULL){ # nocov start

# Verify year input
  if (is.null(year)){ message("Using data from year 2010 /n")
    # temp_meta <- subset(temp_meta, year==2010)

  } else if (year != 2010){

    stop(paste0("Error: Invalid Value to argument 'year'. The only year available is 2010."))
  }


# load correspondence table
  data("grid_state_correspondence_table", envir=environment())


  # Get metadata with data addresses
  metadata <- download_metadata()



# Select geo
  temp_meta <- subset(metadata, geo=="statistical_grid")



# Verify code_grid input ----------------------------------

  # Test if code_grid input is null
    if(is.null(code_grid)){ stop("Value to argument 'code_grid' cannot be NULL") }

  # if code_grid=="all", read the entire country
    if(code_grid=="all"){ message("Loading data for the whole country. This might take a few minutes. /n")

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
      shape <- do.call('rbind', files)
      return(shape)
    }


# if code_grid is a state abbreviation  ----------------------------------

  # Error if the input does not match any state abbreviation
  if(is.character(code_grid) & !(code_grid %in% grid_state_correspondence_table$code_state)) {
    stop(paste0("Error: Invalid Value to argument 'code_grid'. It must be one of the following: ",
                paste(unique(grid_state_correspondence_table$code_state),collapse = " ")))

    # MAKE this work
    # >>> https://stackoverflow.com/questions/54993463/include-image-in-r-packages
    # grid_quads <- raster::stack("./man/figures/ipea_logo.jpg")
    # plotRGB(grid_quads)

    }

  # Valid state abbreviation
    else if(is.character(code_grid) & code_grid %in% grid_state_correspondence_table$code_state) {

      # find grid quadrants that intersect with the passed state abbreviation
      grid_state_correspondence_table_tmp <- grid_state_correspondence_table[grid_state_correspondence_table[,2] == code_grid, ]
      grid_ids <- substr(grid_state_correspondence_table_tmp$code_grid, 4, 5)

      # list paths of files to download
      filesD <- as.character(subset(temp_meta, code %in% grid_ids)$download_path)

      # download files
      lapply(X=filesD, function(x) httr::GET(url=x, httr::progress(),
                                             httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T)) )

      # read files and pile them up
      files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
      files <- paste0(tempdir(),"/",files)
      files <- lapply(X=files, FUN= sf::st_read, quiet=T)
      shape <- do.call('rbind', files)
      return(shape)
      }


# if code_grid is numeric grid quadrant  ----------------------------------
    if( !( code_grid %in% temp_meta$code)){ stop("Error: Invalid Value to argument code_grid.")

    } else{

    # list paths of file to download
    filesD <- as.character(subset(temp_meta, code== code_grid)$download_path)

    # download files
    temps <- paste0(tempdir(),"/",unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD, httr::write_disk(temps, overwrite = T))

    # read sf
    shape <- sf::st_read(temps, quiet=T)
    return(shape)
  }
} # nocov end


