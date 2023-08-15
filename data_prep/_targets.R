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
               'stringr',
               'stringi',
               # 'readr',
               # 'future',
               # 'furrr',
               # 'geobr',
               # 'utils',
               'pbapply',
               'rvest',
               'sf'
               )
  )


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

  tar_target(years_muni, c(2000, #2001#,
                           2005, 2007, 2010,
                           2013,
                           2014,  2015, 2016, 2017#,
                           #2018, 2019, 2020, 2021, 2022
                           )
                            ),
  # download
  tar_target(name = download_municipios,
             command = download_muni(years_muni),
             pattern = map(years_muni))
  # # clean
  # tar_target(name = clean_municipios,
  #            command = clean_muni(download_municipios)
  #            # , pattern = map(years_muni)
  #            )
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

# targets::tar_make()
# targets::tar_make_future(workers = 2)

# targets::tar_visnetwork()

# targets::tar_meta(fields = error, complete_only = TRUE)




# list(
#   tar_target(municipios, c("rio", "spo", "bho", "cur", "bel")),
#   tar_target(anos, c(2017, 2018, 2019)),
#   tar_target(printa, print(paste0(municipios, "_", anos)), pattern = cross(anos, municipios))
# )