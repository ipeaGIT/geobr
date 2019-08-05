library(sf)
library(readr)
library(geobr)
library(R.utils)

setwd('C:/Users/r1701707/Desktop/a')

am <- geobr::read_state(year=2018, code_state='AM')
pa <- geobr::read_state(year=2018, code_state='PA')
ac <- geobr::read_state(year=2018, code_state='AC')
rr <- geobr::read_state(year=2018, code_state='RR')
ap <- geobr::read_state(year=2018, code_state='AP')

all <- geobr::read_state(year=2018, code_state='all')

br <- rbind(am, pa, ac, rr, ap)
plot(br)

# save as RDS
  readr::write_rds(am, "./rds/am.rds", compress="gz")
  readr::write_rds(pa, "./rds/pa.rds", compress="gz")
  readr::write_rds(ac, "./rds/ac.rds", compress="gz")
  readr::write_rds(rr, "./rds/rr.rds", compress="gz")
  readr::write_rds(ap, "./rds/ap.rds", compress="gz")
  readr::write_rds(all, "./rds/all.rds", compress="gz")

# save as geojson
  sf::st_write(am, "./geojson/am.geojson")
  sf::st_write(pa, "./geojson/pa.geojson")
  sf::st_write(ac, "./geojson/ac.geojson")
  sf::st_write(rr, "./geojson/rr.geojson")
  sf::st_write(ap, "./geojson/ap.geojson")
  sf::st_write(all, "./geojson/all.geojson")

  # zip files
  files_geojson <- list.files(path = '.', pattern = ".geojson", recursive = T, full.names = T)
  for (i in seq_along(files_geojson)){
    R.utils::gzip(files_geojson[i] ,destname= paste0(files_geojson[i],'.gz'))
  }


# save as geopackage
  sf::st_write(am, "./gpkg/am.gpkg")
  sf::st_write(pa, "./gpkg/pa.gpkg")
  sf::st_write(ac, "./gpkg/ac.gpkg")
  sf::st_write(rr, "./gpkg/rr.gpkg")
  sf::st_write(ap, "./gpkg/ap.gpkg")
  sf::st_write(all, "./gpkg/all.gpkg")

# zip files
  files_gpkg <- list.files(path = '.', pattern = ".gpkg", recursive = T, full.names = T)
  for (i in seq_along(files_gpkg)){
    R.utils::gzip(files_gpkg[i] ,destname= paste0(files_gpkg[i],'.gz'))
    }


##### BENCHMARK
# 2.47026 secs

# RDS  -------------------------------------
start_time <- Sys.time()

  # files
    files_rds <- c('http://www.ipea.gov.br/geobr/tests/rds/ac.rds',
                 'http://www.ipea.gov.br/geobr/tests/rds/am.rds',
                 'http://www.ipea.gov.br/geobr/tests/rds/ap.rds',
                 'http://www.ipea.gov.br/geobr/tests/rds/all.rds')


  # download files
    lapply(X=files_rds, function(x) httr::GET(url=x, httr::progress(),
                                           httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T)) )


  # read files and pile them up
    files <- unlist(lapply(strsplit(files_rds,"/"), tail, n = 1L))
    files <- paste0(tempdir(),"/",files)
    files <- lapply(X=files, FUN= readr::read_rds)
    shape <- do.call('rbind', files)

end_time <- Sys.time()
end_time - start_time





### GPKG -----------------------------------------------
# 24.62294 secs

start_time <- Sys.time()


# files
files_gpkg <- c('http://www.ipea.gov.br/geobr/tests/gpkg/ac.gpkg.gz',
                'http://www.ipea.gov.br/geobr/tests/gpkg/am.gpkg.gz',
                'http://www.ipea.gov.br/geobr/tests/gpkg/ap.gpkg.gz',
                'http://www.ipea.gov.br/geobr/tests/gpkg/all.gpkg.gz')



# download files
lapply(X=files_gpkg, function(x) httr::GET(url=x, httr::progress(),
                                           httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T)) )



# read files and pile them up
files <- unlist(lapply(strsplit(files_gpkg,"/"), tail, n = 1L))
files <- paste0(tempdir(),"/",files)

gpkg_fun <- function( zipf){

  # zipf <- files[1]
  # zipf = zipado
  # paste0(stringr::str_match(zipf[1], "gpkg/(.*?).gpkg")[2],".gpkg")

  # temp file
  tempf <- file.path(tempdir(), paste0(stringr::str_match(zipf, "/(.*?).gpkg.gz")[2],".gpkg") )
  # unzip
  R.utils::gunzip(zipf, remove=F, overwrite=T, tempf)
  # read
  a <- sf::st_read(dsn=tempf,  quiet = TRUE)
  return(a)

  files <- list.files(tempdir(), full.names = T, pattern = "^file")
  file.remove(files)
}
files <- lapply(X=files, FUN= gpkg_fun)
shape <- do.call('rbind', files)

end_time <- Sys.time()
end_time - start_time

# plot(shape)







### geojson -----------------------------------------------
# 10.48832 secs


start_time <- Sys.time()


# files
files_geojson <- c('http://www.ipea.gov.br/geobr/tests/geojson/ac.geojson.gz',
                   'http://www.ipea.gov.br/geobr/tests/geojson/am.geojson.gz',
                   'http://www.ipea.gov.br/geobr/tests/geojson/ap.geojson.gz',
                   'http://www.ipea.gov.br/geobr/tests/geojson/all.geojson.gz')


# download files
lapply(X=files_geojson, function(x) httr::GET(url=x, httr::progress(),
                                              httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T)) )



# read files and pile them up
files <- unlist(lapply(strsplit(files_geojson,"/"), tail, n = 1L))
files <- paste0(tempdir(),"/",files)

geojson_fun <- function( zipf){

  # zipf <- files[1]
  # zipf = zipado
  # paste0(stringr::str_match(zipf[1], "geojson/(.*?).geojson")[2],".geojson")

  # temp file
  tempf <- file.path(tempdir(), paste0(stringr::str_match(zipf, "/(.*?).geojson.gz")[2],".geojson") )
  # unzip
  R.utils::gunzip(zipf, remove=F, overwrite=T, tempf)
  # read
  a <- sf::st_read(dsn=tempf,  quiet = TRUE)
  return(a)

  files <- list.files(tempdir(), full.names = T, pattern = "^file")
  file.remove(files)
}
files <- lapply(X=files, FUN= geojson_fun)
shape <- do.call('rbind', files)

end_time <- Sys.time()
end_time - start_time

# plot(shape)


