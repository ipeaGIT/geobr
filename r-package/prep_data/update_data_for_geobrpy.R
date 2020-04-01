# list.files('L:/# DIRUR #/ASMEQ/geobr/data-raw', pattern = '*.rds', full.names = T, recursive = T)
dir.create('L:/# DIRUR #/ASMEQ/geobr/data-raw/data_python')


## List all files in R
  r_files_fulladdress <- list.files('\\\\storage1\\geobr\\data', pattern = '*.rds', full.names = T, recursive = T)
  # f <- r_files_fulladdress[1:2]

  # somente o nome da base de dados (string between the last "/" and the file extension ".rds" )
  r_datasets <- lapply(X= f, function(i){gsub('^.*data/\\s*|\\s*.rds.*$', '', i)} )


## List all files in Python
py_files_fulladdress <- list.files('\\\\storage1\\geobr\\data_python', pattern = '*.gpkg', full.names = T, recursive = T)

  # somente o nome da base de dados
  py_datasets <- lapply(X= py_files_fulladdress, function(i){gsub('^.*data_python/\\s*|\\s*.gpkg.*$', '', i)} )






# Check if there are any differences
missing_py_data <- setdiff(r_datasets, py_datasets)



# create function to update python datasets in geopackage format

update_py_dataset <- function(f){

#  f <- missing_py_data[[1]]

# step 1: read original .rds file
temp_rds <- readr::read_rds( paste0('\\\\storage1\\geobr\\data\\', f, '.rds') )

# # change dir
# dest_file <- gsub("data", "data_python", f)
#
# # change file extension
# dest_file <- gsub(".rds", ".gpkg", f)

# create dest folder
dest_dir <- sub("^(.*)[/].*", "\\1", f)



dir.create( paste0('//storage1/geobr/data_python/', f), recursive = T )





# save file in geopackage format
sf::st_write(obj=temp_rds, paste0('//storage1/geobr/data_python/', f, '.gpkg') )

# should we zip compact file?


}

