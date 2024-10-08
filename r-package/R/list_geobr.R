#' List all data sets available in the geobr package
#'
#' @description
#' Returns a data frame with all datasets available in the geobr package
#'
#' @return A `data.frame`
#'
#' @export
#' @family support functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' df <- list_geobr()
#'
list_geobr <- function(){

# Get readme.md file
tempf <- fs::path(fs::path_temp(), "readme.md")

# check if metadata has already been downloaded
if (file.exists(tempf) & file.info(tempf)$size != 0) {
  readme <- readLines(tempf, encoding = "UTF-8")

} else {
  # download it and save to metadata
  git_url = "https://raw.githubusercontent.com/ipeaGIT/geobr/master/README.md"

  # test server connection
  try(silent = TRUE,
      check_con <- check_connection(git_url)
      )
  if(is.null(check_con) | isFALSE(check_con)){ return(invisible(NULL)) }

  try( silent = TRUE,
       downloaded_files <- curl::multi_download(
         urls = git_url,
         destfiles = tempf,
         resume = TRUE,
         progress = FALSE
       )
  )

  readme <- readLines(tempf, encoding = "UTF-8")
}



# find start and end of table
table_start <- grep("Available datasets:", readme) + 4
table_end <- grep("Other functions", readme) -1

# get table string in Markdown
table_strig <- readme[table_start:table_end]

# read table as a data.frame
# suppressWarnings({ df <- readr::read_delim(I(table_strig),
#                                            delim = '|',
#                                            trim_ws = TRUE,
#                                            show_col_types = FALSE,
#                                            col_names = FALSE) })
suppressWarnings({ df <- utils::read.table(text = I(table_strig),
                                           header = FALSE,
                                           sep = '|',
                                           strip.white = TRUE,
                                           colClasses = 'character',
                                           row.names = NULL,
                                           quote="")
                                        })

# clean colunms
  df[[1]] <- NULL
  df[[5]] <- NULL

# remove 1st row with "-----"
  df <- df[-1,]
  df <- df[-1,]
  rownames(df) <- 1:nrow(df)

# rename columns
colnames(df) <- c("function", "geography", "years", "source")

return(df)
}
