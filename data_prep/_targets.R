# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
suppressPackageStartupMessages({
  library(targets)
  library(tarchetypes)
  library(data.table)
  library(future)
  # library(future.callr)
  # library(future.batchtools)
  future::plan(future::multisession)
})

# Set target options:
tar_option_set(
  format = "rds", # default storage format "rds" "feather"
  memory = "transient",
  garbage_collection = TRUE,
  packages = c(
               'data.table',
               'dplyr',
               'httr',
               'lwgeom',
               # 'ggplot2',
               # 'units',
               # 'scales',
               # 'janitor',
               # 'RCurl',
               'rgeos',
               'sp',
               'maptools',
               'sfheaders',
               'stringr',
               'stringi',
               # 'readr',
               'future',
               'furrr',
               # 'geobr',
               # 'utils',
               'pbapply',
               'rvest',
               'sf'
               )
  )
# invisible(lapply(packages, library, character.only = TRUE))

# # tar_make_clustermq() configuration (okay to leave alone):
# options(clustermq.scheduler = "multisession")

# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
# tar_source()
source('./R/support_fun.R')



# 1. Municipios ----------------------------------------------------------
source("./R/muni_download.R", encoding = "UTF-8")
source("./R/muni_clean.R", encoding = "UTF-8")

list(
  # year input
  # tar_target(years_muni, c(2000, 2001, 2005, 2007, 2010,
  #                         # 2013, 2014,  2015, 2016, 2017,
  #                          2018, 2019, 2020, 2021, 2022)),

  tar_target(years_muni, c(2000, 2001,
                           2005, 2007,
                          2010 ,
                           2013,
                           2014,  2015, 2016, 2017,
                           2018, 2019, 2020,
                          2021,
                          2022
                           )
                            ),
  # download
  tar_target(name = download_municipios,
             command = download_muni(years_muni),
             pattern = map(years_muni)),

  # clean (aprox 14870.86 sec)
  tar_target(name = clean_municipios,
             command = clean_muni(download_municipios)
             , pattern = map(download_municipios)
             )
)

# # clean
# list(
#   tar_target(files_muni, local_files_muni),
#   tar_target(name = clean_municipios,
#              command = clean_muni(files_muni),
#              pattern = map(files_muni))
# )


# Estados ----------------------------------------------------------

# ....

# Metadata ----------------------------------------------------------

# Github assets ----------------------------------------------------------





# list(
#   tar_target(municipios, c("rio", "spo", "bho", "cur", "bel")),
#   tar_target(anos, c(2017, 2018, 2019)),
#   tar_target(printa, print(paste0(municipios, "_", anos)), pattern = cross(anos, municipios))
# )


# targets::tar_make()

# targets::tar_visnetwork(label='branches')
# targets::tar_progress_branches()

# targets::tar_meta(fields = error, complete_only = TRUE)


#
# saving 26municipality_2000.gpkg
# saving 27municipality_2000.gpkg
# saving 28municipality_2000.gpkg
# ✖ error branch clean_municipios_35345f30
# ▶ end pipeline [3.968 minutes]
# There were 31 warnings (use warnings() to see them)
# Error:
#   ! Error running targets::tar_make()
# Error messages: targets::tar_meta(fields = error, complete_only = TRUE)
# Debugging guide: https://books.ropensci.org/targets/debugging.html
# How to ask for help: https://books.ropensci.org/targets/help.html
# Last error: ℹ In index: 2.
# Caused by error in `wk_handle.wk_wkb()`:
#   ! Loop 0 is not valid: Edge 2 has duplicate vertex with edge 4
