#' List all datasets available in the geobr package
#'
#' Returns a data frame with all datasets available in the geobr package
#'
#' @export
#' @family general support functions
#' @examples \donttest{
#'
#' library(geobr)
#'
#' df <- list_geobr()
#'
#'}
#'
list_geobr <- function(){

# Get readme.md file
tempf <- file.path(tempdir(), "readme.md")

# check if metadata has already been downloaded
if (file.exists(tempf)) {
  readme <- readLines(tempf, encoding = "UTF-8")

} else {
  # download it and save to metadata
  httr::GET(url="https://raw.githubusercontent.com/ipeaGIT/geobr/master/README.md", httr::write_disk(tempf, overwrite = T))
  readme <- readLines(tempf, encoding = "UTF-8")
}



# find start and end of table
table_start <- grep("Available datasets:", readme) + 1
table_end <- grep("Other functions", readme) -1

# get table string in Markdown
table_strig <- readme[table_start:table_end]

# read table as a data.frame
suppressWarnings({ df <- readr::read_delim(table_strig, delim = '|', trim_ws = T) })

# clean colunms
  df$X1 <- NULL
  df$X6 <- NULL

# remove 1st row with "-----"
df <- df[-1,]

# rename columns
colnames(df) <- c("function", "geography", "years", "source")

return(df)
}
