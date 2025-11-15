# package global variables
geobr_env <- new.env(parent = emptyenv()) # nocov start

.onLoad <- function(libname, pkgname){

  # data release
  geobr_env$data_release <- 'v2.0.0'

  geobr_env$all_code_state <- c(11, 12, 13, 14, 15, 16, 17, 21, 22, 23, 24, 25,
                                26, 27, 28, 29, 31, 32, 33, 35, 41, 42, 43, 50,
                                51, 52, 53)

  geobr_env$all_abbrev_state <- c("RO", "AC", "AM", "RR", "PA", "AP", "TO", "MA",
                                  "PI", "CE", "RN", "PB", "PE", "AL", "SE", "BA",
                                  "MG", "ES", "RJ", "SP", "PR", "SC", "RS", "MS",
                                  "MT", "GO", "DF")


} # nocov end
