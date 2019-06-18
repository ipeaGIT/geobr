#' Download shape files of IBGE's statistical grid (200 x 200 meters)
#' 
#' @param year Year of the data (defaults to 2010). The only year available thus far is 2010.
#' @param cod_grid The 7-digit code of a grid quadrant If the two-letter abbreviation of a state is used,
#' the function will load all grid gradrants that intersect with that state. If cod_grid="all", the grid of the whole country will be loaded.
#' @export
#' @family general area functions
#' @examples \dontrun{
#'
#' library(geobr)
#'
#' # Read specific municipality at a given year
#'   grid <- read_statistical_grid(cod_grid = 45, year=2010)
#'
#'# Read all municipalities of a state at a given year
#'   state_grid <- read_statistical_grid(cod_grid = "RJ")
#'
#'}

read_statistical_grid <- function(cod_grid, year=NULL){

# Verify year input
  if (is.null(year)){ cat("Using data from year 2010 /n")
    # temp_meta <- subset(temp_meta, year==2010)
    
  } else if (year != 2010){ 
    
    stop(paste0("Error: Invalid Value to argument 'year'. The only year available is 2010."))
  }
  
  
# load correspondence table
  data("gid_state_correspondence_table", envir=environment())
  
  
# Get metadata with data addresses
  tempf <- file.path(tempdir(), "metadata.rds")

  # check if metadata has already been downloaded
  if (file.exists(tempf)) {
     metadata <- readr::read_rds(tempf)

  } else {
    
  # download it and save to metadata
    httr::GET(url="http://www.ipea.gov.br/geobr/metadata/metadata.rds", httr::write_disk(tempf, overwrite = T))
    metadata <- readr::read_rds(tempf)
  }


  
# Select geo
  temp_meta <- subset(metadata, geo=="statistical_grid")




# Verify cod_grid input

  # Test if cod_grid input is null
    if(is.null(cod_grid)){ stop("Value to argument 'cod_grid' cannot be NULL") }

  # if cod_grid=="all", read the entire country
    else if(cod_grid=="all"){ cat("Loading data for the whole country. This might take a few minutes. /n")

      # list paths of files to download
      filesD <- as.character(temp_meta$download_path)

      # download files
      lapply(X=filesD, function(x) httr::GET(url=x, 
                                             httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T)) )
      
      # read files and pile them up
      files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
      files <- paste0(tempdir(),"/",files)
      files <- lapply(X=files, FUN= readr::read_rds)
      shape <- do.call('rbind', files)
      return(shape)
    }

  
# if cod_grid is a state abbreviation

  # Error if the input does not match any state abbreviation
  if(is.character(cod_grid) & !(cod_grid %in% corresptb$cod_uf)) { 
    stop(paste0("Error: Invalid Value to argument 'cod_grid'. It must be one of the following: ",
                paste(unique(corresptb$cod_uf),collapse = " ")))
    
    # MAKE this work
    # >>> https://stackoverflow.com/questions/54993463/include-image-in-r-packages
    # grid_quads <- raster::stack("./man/figures/ipea_logo.jpg")
    # plotRGB(grid_quads)
    
    }
    
  # Correct state abbreviation
    else if(is.character(cod_grid) & cod_grid %in% corresptb$cod_uf) {
      
      # find grid quadrants that intersect with the passed state abbreviation
      corresptb_tmp <- corresptb[corresptb[,2] == cod_grid, ]
      grid_ids <- substr(corresptb_tmp$cod_grid, 4, 5)
      
      # list paths of files to download
      filesD <- as.character(subset(temp_meta, code %in% grid_ids)$download_path)
      
      # download files
      lapply(X=filesD, function(x) httr::GET(url=x, 
                                             httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T)) )
      
      # read files and pile them up
      files <- unlist(lapply(strsplit(filesD,"/"), tail, n = 1L))
      files <- paste0(tempdir(),"/",files)
      files <- lapply(X=files, FUN= readr::read_rds)
      shape <- do.call('rbind', files)
      return(shape)
      }

  
# if cod_grid is numeric grid quadrant
    if( !( cod_grid %in% temp_meta$code)){ stop("Error: Invalid Value to argument cod_grid.")

    } else{

    # list paths of file to download
    filesD <- as.character(subset(temp_meta, code== cod_grid)$download_path)

    # download files
    temps <- paste0(tempdir(),"/",unlist(lapply(strsplit(filesD,"/"),tail,n=1L)))
    httr::GET(url=filesD, httr::write_disk(temps, overwrite = T))
    
    # read sf
    shape <- readr::read_rds(temps)
    return(shape)
  }
}

    
