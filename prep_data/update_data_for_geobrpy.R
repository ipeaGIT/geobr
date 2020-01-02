# list.files('L:/# DIRUR #/ASMEQ/geobr/data-raw', pattern = '*.rds', full.names = T, recursive = T)
dir.create('L:/# DIRUR #/ASMEQ/geobr/data-raw/data_python')


# List all files in R
r_files_fulladdress <- list.files('\\\\storage1\\geobr\\data', pattern = '*.rds', full.names = T, recursive = T)

# r_files_fulladdress <- f[c(1,100,400)] # TESTE

  # somente o nome da base de dados
  r_datasets <- gsub('^.*/data\\s*|\\s*.rds.*$', '', f[1])




  
# List all files in Python
py_files_fulladdress <- list.files('\\\\storage1\\geobr\\data_python', pattern = '*.gpkg', full.names = T, recursive = T)
  
  # somente o nome da base de dados
  py_datasets <- 

  
  
# Check if there are any differences
missing_py_data <- setdiff(r_datasets, py_datasets)




# create function to update python datasets in geopackage format

update_py_dataset <- function(f)

# step 1: read original .rds file
temp_rds <- readr::read_rds(f)

# change dir
dest_file <- gsub("data", "data_python", f)

# change file extension
dest_file <- gsub(".rds", ".gpkg", f)

# save file in geopackage format
sf::st_write(obj=temp_rds, dest_file)

# should we zip compact file?




