# long-term cache

library(httr)
am <- 'https://github.com/ipeaGIT/geobr/releases/download/v1.7.0/amazonia_legal.gpkg'
as <- 'https://github.com/ipeaGIT/geobr/releases/download/v1.7.0/amazonia_legal_simplified.gpkg'



eee <- HEAD(url = am)
eee$headers$etag
eee$all_headers

HEAD(url = am)$headers$etag

# get all etags for metadata table
aaa <- lapply(X = c(am, as), FUN = function(x){HEAD(url = x)$headers$etag})
unlist(aaa)


f <- 'C:/Users/user/Downloads/amazonia_legal (2).gpkg'

file.info(f)$ctime

fff <- HEAD(url = f)



#' metadata table should have url and etag

#' DOWNLOAD fun
#' 1)if etag is not saved locally,
#' download fun should save etag locally and download data
#' if etag and data exists locally, then compare against metadata
#
