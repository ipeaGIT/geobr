#' Download spatial data of IBGE's statistical grid
#'
#' @description
#' Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
#'
#' @param year Year of the data. Defaults to 2010. The only year available thus
#'             far is 2010.
#' @param code_grid If two-letter abbreviation of a state is passed, the function
#'                  will load all grid quadrants that intersect with that state.
#'                  If `code_grid="all"`, the grid of the whole country will be
#'                  loaded. Users may also pass a 7-digit code of a grid quadrant
#'                  to load an specific quadrant.
#' @param showProgress Logical. Defaults to `TRUE` display progress bar
#'
#' @return An `"sf" "data.frame"` object
#'
#' @export
#' @family general area functions
#' @examples \dontrun{
#' # Read specific municipality at a given year
#' grid <- read_statistical_grid(code_grid = 45, year=2010)
#'
#' # Read all municipalities of a state at a given year
#' state_grid <- read_statistical_grid(code_grid = "RJ")
#'}
read_statistical_grid <- function(code_grid, year=2010, showProgress=TRUE){ # nocov start

  # Get metadata with data url addresses
  temp_meta <- select_metadata(geography="statistical_grid", year=year, simplified=F)

  # load correspondence table
  data("grid_state_correspondence_table", envir=environment())


# Verify code_grid input ----------------------------------

  # Test if code_grid input is null
    if(is.null(code_grid)){ stop("Value to argument 'code_grid' cannot be NULL") }

  # if code_grid=="all", read the entire country
    if(code_grid=="all"){ message("Loading data for the whole country. This might take a few minutes. /n")

      # list paths of files to download
      file_url <- as.character(temp_meta$download_path)

      # download files
      temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
      return(temp_sf)
      }


# if code_grid is a state abbreviation  ----------------------------------

  # Error if the input does not match any state abbreviation
  if(is.character(code_grid) & !(code_grid %in% grid_state_correspondence_table$abbrev_state)) {
    stop(paste0("Error: Invalid Value to argument 'code_grid'. It must be one of the following: ",
                paste(unique(grid_state_correspondence_table$abbrev_state),collapse = " ")))

    # MAKE this work
    # >>> https://stackoverflow.com/questions/54993463/include-image-in-r-packages
    # grid_quads <- raster::stack("./man/figures/ipea_logo.jpg")
    # plotRGB(grid_quads)

    }

  # Valid state abbreviation
    else if(is.character(code_grid) & code_grid %in% grid_state_correspondence_table$abbrev_state) {

      # find grid quadrants that intersect with the passed state abbreviation
      grid_state_correspondence_table_tmp <- grid_state_correspondence_table[grid_state_correspondence_table[,2] == code_grid, ]
      grid_ids <- substr(grid_state_correspondence_table_tmp$code_grid, 4, 5)

      # list paths of files to download
      file_url <- as.character(subset(temp_meta, code %in% grid_ids)$download_path)

      # download gpkg
      temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
      return(temp_sf)
      }


# if code_grid is numeric grid quadrant  ----------------------------------
    if( !( code_grid %in% temp_meta$code)){ stop("Error: Invalid Value to argument code_grid.")

    } else{

    # list paths of file to download
    file_url <- as.character(subset(temp_meta, code== code_grid)$download_path)

    # download files
    temp_sf <- download_gpkg(file_url, progress_bar = showProgress)
    return(temp_sf)
    }

} # nocov end


