


rename_index <- function(x){ # x <- myf[1]

  x

# old file name and index
old_name <- basename(x)
old_index <- substring(x, 29, 500)

# new file name and index
new_name <- stringr::str_replace_all(old_index, '/', '_')
new_name <- paste0( substring(old_name, 1,2),
                    new_name)


if (x %like% 'simplified') {
    new_name <- stringr::str_replace(new_name, paste0('_', old_name), '_simplified.gpkg')
  } else {
    new_name <- stringr::str_replace(new_name, paste0('_', old_name), '.gpkg')
  }



new_index <- stringr::str_replace(x, old_name, new_name)

# rename
file.rename(x, new_index)
}

# f <- list.files(path = '//storage1/geobr/test',full.names = T, recursive = T)
# pbapply::pblapply(X=f, FUN=rename_index)


library(stringr)
library(furrr)
library(future)

f <- list.files(path = '//storage1/geobr/data_gpkg/',full.names = T, recursive = T)
myf <- f[ f %like% 'amazonia_legal']

ok meso_region
ok health_region
ok health_region_macro
ok state
ok statistical_grid
ok micro_region
ok weighting_area
ok census_tract


municipality



future::plan(future::multisession())
furrr::future_map(.x= myf , .f = rename_index, .progress = T)

