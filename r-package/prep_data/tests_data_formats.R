library(sf)
library(readr)
library(geobr)
library(R.utils)
library(microbenchmark)
library(beepr)


#######  create folders for the test  ---------------------
  setwd('C:/Users/r1701707/Desktop/a')
  setwd('C:/Users/rafa/Desktop/a')

dir.create("./rds")
dir.create("./geojson")
dir.create("./gpkg")


####### Generate inputs ---------------------

#  download original geobr data
  am <- geobr::read_state(year=2018, code_state='AM')
  pa <- geobr::read_state(year=2018, code_state='PA')
  ac <- geobr::read_state(year=2018, code_state='AC')
  rr <- geobr::read_state(year=2018, code_state='RR')
  ap <- geobr::read_state(year=2018, code_state='AP')

  all <- geobr::read_state(year=2018, code_state='all')

br <- rbind(am, pa, ac, rr, ap)
plot(br)

####### Save inputs ---------------------

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
    R.utils::gzip(files_geojson[i] ,destname= paste0(files_geojson[i],'.gz'), remove=F )
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
    R.utils::gzip(files_gpkg[i] ,destname= paste0(files_gpkg[i],'.gz'), remove=F )
    }





####### BENCHMARK Download and Reading files ---------------------

  library(sf)
  library(readr)
  library(geobr)
  library(R.utils)
  library(microbenchmark)
  library(beepr)

mbm <- microbenchmark::microbenchmark(times = 30,

              ### RDS  -------------------------------------
              'rds' = { # files
                        files_rds <- c('http://www.ipea.gov.br/geobr/tests/rds/ac.rds',
                                       'http://www.ipea.gov.br/geobr/tests/rds/am.rds',
                                       'http://www.ipea.gov.br/geobr/tests/rds/ap.rds')


                        # download files
                        lapply(X=files_rds, function(x) httr::GET(url=x, httr::progress(),
                                                                  httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T)) )

                        # read files and pile them up
                        files <- unlist(lapply(strsplit(files_rds,"/"), tail, n = 1L))
                        files <- paste0(tempdir(),"/",files)
                        files <- lapply(X=files, FUN= readr::read_rds)
                        shape <- do.call('rbind', files)
                      },


              ### GPKG  -------------------------------------
              'gpkg' = { # files
                files_gpkg <- c('http://www.ipea.gov.br/geobr/tests/gpkg/ac.gpkg',
                                'http://www.ipea.gov.br/geobr/tests/gpkg/am.gpkg',
                                'http://www.ipea.gov.br/geobr/tests/gpkg/ap.gpkg')


                # download files
                lapply(X=files_gpkg, function(x) httr::GET(url=x, httr::progress(),
                                                          httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T)) )

                # read files and pile them up
                files <- unlist(lapply(strsplit(files_gpkg,"/"), tail, n = 1L))
                files <- paste0(tempdir(),"/",files)
                files <- lapply(X=files, FUN= sf::st_read)
                shape <- do.call('rbind', files)
              },

              ### GPKG_zip  -------------------------------------
              'gpkg_zip' = { # files
                        files_gpkg_zip <- c('http://www.ipea.gov.br/geobr/tests/gpkg/ac.gpkg.gz',
                                            'http://www.ipea.gov.br/geobr/tests/gpkg/am.gpkg.gz',
                                            'http://www.ipea.gov.br/geobr/tests/gpkg/ap.gpkg.gz')

                        # download files
                        lapply(X=files_gpkg_zip, function(x) httr::GET(url=x, httr::progress(),
                                                                   httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T)) )

                        # read files and pile them up
                        files <- unlist(lapply(strsplit(files_gpkg_zip,"/"), tail, n = 1L))
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
                      },


              ### geojson_zip -------------------------------------
              'geojson_zip' = { # files
                        files_geojson_zip <- c('http://www.ipea.gov.br/geobr/tests/geojson/ac.geojson.gz',
                                               'http://www.ipea.gov.br/geobr/tests/geojson/am.geojson.gz',
                                               'http://www.ipea.gov.br/geobr/tests/geojson/ap.geojson.gz')

                        # download files
                        lapply(X=files_geojson_zip, function(x) httr::GET(url=x, httr::progress(),
                                                                      httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T)) )

                        # read files and pile them up
                        files <- unlist(lapply(strsplit(files_geojson_zip,"/"), tail, n = 1L))
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
                        },


              ### geojson  -------------------------------------
              'geojson' = { # files
                files_geojson <- c('http://www.ipea.gov.br/geobr/tests/geojson/ac.geojson',
                                   'http://www.ipea.gov.br/geobr/tests/geojson/am.geojson',
                                   'http://www.ipea.gov.br/geobr/tests/geojson/ap.geojson')


                # download files
                lapply(X=files_geojson, function(x) httr::GET(url=x, httr::progress(),
                                                          httr::write_disk(paste0(tempdir(),"/", unlist(lapply(strsplit(x,"/"),tail,n=1L))), overwrite = T)) )

                # read files and pile them up
                files <- unlist(lapply(strsplit(files_geojson,"/"), tail, n = 1L))
                files <- paste0(tempdir(),"/",files)
                files <- lapply(X=files, FUN= sf::st_read)
                shape <- do.call('rbind', files)
              }

)

beepr::beep()

# plot result
ggplot2::autoplot(mbm)
ggplot2::autoplot( subset(mbm, expr != 'rds') )




####### BENCHMARK Reading files only ---------------------

mbmr_read <- microbenchmark::microbenchmark(times = 10,
                ### RDS  -------------------------------------
                'rds' = {
                          # files
                          files_rds <- list.files(path = '.', pattern = ".rds", recursive = T, full.names = T)

                          # read files and pile them up
                          files <- lapply(X=files_rds, FUN= readr::read_rds)
                          shape <- do.call('rbind', files)
                        },


                ### GPKG  -------------------------------------
                'gpkg' = {
                  # files
                  files_gpkg <- list.files(path = '.', pattern = ".gpkg", recursive = T, full.names = T)
                  files_gpkg <- files_gpkg[endsWith(files_gpkg, '.gpkg')]


                  # read files and pile them up
                  files <- lapply(X=files_gpkg, FUN= sf::st_read)
                  shape <- do.call('rbind', files)
                },

                ### GPKG_zip  -------------------------------------
                'gpkg_zip' = {
                          # files
                          files_gpkg_zip <- list.files(path = '.', pattern = ".gpkg.gz", recursive = T, full.names = T)

                          gpkg_fun <- function( zipf){

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
                          files <- lapply(X=files_gpkg_zip, FUN= gpkg_fun)
                          shape <- do.call('rbind', files)
                        },




                ### geojson  -------------------------------------
                'geojson' = {
                  # files
                  files_geojson <- list.files(path = '.', pattern = ".geojson", recursive = T, full.names = T)
                  files_geojson <- files_geojson[endsWith(files_geojson, '.geojson')]


                  # read files and pile them up
                  files <- lapply(X=files_geojson, FUN= sf::st_read)
                  shape <- do.call('rbind', files)
                },



                ### geojson_zip  -------------------------------------
                'geojson_zip' = {
                          # files
                          files_geojson_zip <- list.files(path = '.', pattern = ".geojson.gz", recursive = T, full.names = T)

                          geojson_fun <- function( zipf){

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
                          files <- lapply(X=files_geojson_zip, FUN= geojson_fun)
                          shape <- do.call('rbind', files)}
)

beepr::beep()

# plot result
  ggplot2::autoplot(mbmr_read)
  ggplot2::autoplot( subset(mbmr_read, expr != 'rds') )



  Hi @JoaoCarabetta . Sorry for the long wait. I'm gradually starting to work again on the python version of `geobr`. Last time we discussed this, we
