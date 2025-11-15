# package global variables
geobr_env <- new.env(parent = emptyenv()) # nocov start

.onLoad <- function(libname, pkgname){

  # data release
  geobr_env$data_release <- 'v2.0.0'

} # nocov end
