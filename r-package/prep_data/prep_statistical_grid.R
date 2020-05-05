### Libraries (use any library as necessary)

library(RCurl)
library(stringr)
library(sf)
library(magrittr)
library(data.table)
library(dplyr)


####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")



###### 0. Create folders to save the data -----------------

# Directory to keep raw zipped files
  dir.create("L:////# DIRUR #//ASMEQ//geobr//data-raw//grade_estatistica")
  dir.create("L:////# DIRUR #//ASMEQ//geobr//data-raw//grade_estatistica//2010")

# Directory to keep raw sf files
  dir.create("L:////# DIRUR #//ASMEQ//geobr//data-raw//grade_estatistica//shapes_in_sf_all_years_original")
  dir.create("L:////# DIRUR #//ASMEQ//geobr//data-raw//grade_estatistica//shapes_in_sf_all_years_original//2010")

# Directory to keep cleaned sf files
  dir.create("L:////# DIRUR #//ASMEQ//geobr//data-raw//grade_estatistica//shapes_in_sf_all_years_cleaned")
  dir.create("L:////# DIRUR #//ASMEQ//geobr//data-raw//grade_estatistica//shapes_in_sf_all_years_cleaned//2010")



# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//grade_estatistica//2010"
setwd(root_dir)





###### 1. Download 2010 Raw data -----------------

url = "ftp://geoftp.ibge.gov.br/recortes_para_fins_estatisticos/grade_estatistica/censo_2010/"
filenames = getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filenames <- strsplit(filenames, "\r\n")
filenames = unlist(filenames)


# Download zipped files
  for (filename in filenames) {
    download.file(paste(url, filename, sep = ""), paste(filename))
  }










###### 2. Unzip Raw data -----------------

for (filename in filenames[-c(1,2)]) {
  unzip(paste(filename))
}

###### 3. Save original data sets downloaded from IBGE in compact .rds format-----------------

# nah

###### 3. Save cleaned data sets downloaded from IBGE in compact .rds format-----------------

# Root directory
  root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//grade_estatistica//2010"
  setwd(root_dir)


# list all shape files
  all_shapes <- list.files(full.names = T, recursive = T, pattern = ".shp")
  all_shapes <- all_shapes[ !(all_shapes %like% ".xml")]



shp_to_sf_rds <- function(x){

# select file
  # x <- "./grade_id15.shp"


# read shape as sf file
  shape <- st_read(x, quiet = T, stringsAsFactors=F)

# drop unecessary columns
  shape$Shape_Leng <- NULL
  shape$Shape_Area <- NULL

  ###### 6. generate a lighter version of the dataset with simplified borders -----------------
  # skip this step if the dataset is made of points, regular spatial grids or rater data

  # # simplify
  # shape_simplified <- st_transform(shape, crs=3857) %>%
  #   sf::st_simplify(preserveTopology = T, dTolerance = 100) %>%
  #   st_transform(crs=4674)
  # head(shape)

# get file name
  file_name <- paste0(substr(x, 11, 12), "grid.rds")

# save in .rds
  readr::write_rds(x=shape, path = paste0("../shapes_in_sf_all_years_cleaned/2010/", substr(x, 11, 12), "grid.rds"), compress="gz" )
  sf::st_write(temp_sf,  dsn= paste0("../shapes_in_sf_all_years_cleaned/2010/", substr(x, 11, 12), "grid.gpkg") )
  # sf::st_write(temp_sf7, dsn= paste0("../shapes_in_sf_all_years_cleaned/2010/", substr(x, 11, 12), "grid_simplified", ".gpkg"))
  }


# Apply function to save original data sets in rds format

# create computing clusters
  cl <- parallel::makeCluster(detectCores())

  clusterEvalQ(cl, c(library(data.table), library(readr), library(sf)))
  parallel::clusterExport(cl=cl, varlist= c("all_shapes"), envir=environment())

  # apply function in parallel
  parallel::parLapply(cl, all_shapes, shp_to_sf_rds)
  stopCluster(cl)

  rm(list= ls())
  gc(reset = T)


# # DO NOT run
#   # remove all unzipped shape files
#     # list all unzipped shapes
#       f <- list.files(path = root_dir, full.names = T, recursive = T, pattern = ".shx|.shp|.prj|.dbf|.cpg|.xml|.sbx|.sbn")
#       file.remove(f)


###### 4. Prepare table with correspondence between grid ID and code_state -----------------


grid_state_correspondence_table <- structure(list(name_uf = c("Acre", "Acre", "Acre", "Acre", "Amazonas",
                                  "Amazonas", "Amazonas", "Amazonas", "Amazonas", "Amazonas", "Amazonas",
                                  "Amazonas", "Amazonas", "Amazonas", "Amazonas", "Amazonas", "Roraima",
                                  "Roraima", "Roraima", "Roraima", "Roraima", "Roraima", "Amapá",
                                  "Amapá", "Amapá", "Amapá", "Pará", "Pará", "Pará", "Pará", "Pará",
                                  "Pará", "Pará", "Pará", "Pará", "Pará", "Pará", "Pará", "Pará",
                                  "Maranhão", "Maranhão", "Maranhão", "Maranhão", "Maranhão", "Maranhão",
                                  "Maranhão", "Piauí", "Piauí", "Piauí", "Piauí", "Piauí", "Piauí",
                                  "Ceará", "Ceará", "Ceará", "Rio Grande do Norte", "Rio Grande do Norte",
                                  "Paraíba", "Paraíba", "Pernambuco", "Pernambuco", "Pernambuco",
                                  "Pernambuco", "Pernambuco", "Alagoas", "Alagoas", "Sergipe",
                                  "Sergipe", "Bahia", "Bahia", "Bahia", "Bahia", "Bahia", "Espírito Santo",
                                  "Espírito Santo", "Espírito Santo", "Rio de Janeiro", "Rio de Janeiro",
                                  "Rio de Janeiro", "Rio de Janeiro", "São Paulo", "São Paulo",
                                  "São Paulo", "São Paulo", "São Paulo", "Paraná", "Paraná", "Santa Catarina",
                                  "Santa Catarina", "Santa Catarina", "Santa Catarina", "Rio Grande do Sul",
                                  "Rio Grande do Sul", "Rio Grande do Sul", "Rio Grande do Sul",
                                  "Mato Grosso do Sul", "Mato Grosso do Sul", "Mato Grosso do Sul",
                                  "Mato Grosso do Sul", "Mato Grosso do Sul", "Mato Grosso do Sul",
                                  "Mato Grosso do Sul", "Minas Gerais", "Minas Gerais", "Minas Gerais",
                                  "Minas Gerais", "Minas Gerais", "Minas Gerais", "Minas Gerais",
                                  "Minas Gerais", "Goiás", "Goiás", "Goiás", "Goiás", "Goiás",
                                  "Goiás", "Goiás", "Distrito Federal", "Tocantins", "Tocantins",
                                  "Tocantins", "Tocantins", "Tocantins", "Mato Grosso", "Mato Grosso",
                                  "Mato Grosso", "Mato Grosso", "Mato Grosso", "Mato Grosso", "Mato Grosso",
                                  "Mato Grosso", "Mato Grosso", "Mato Grosso", "Rondônia", "Rondônia",
                                  "Rondônia", "Rondônia", "Rondônia", "Rondônia"), code_state = c("AC",
                                                                                              "AC", "AC", "AC", "AM", "AM", "AM", "AM", "AM", "AM", "AM", "AM",
                                                                                              "AM", "AM", "AM", "AM", "RR", "RR", "RR", "RR", "RR", "RR", "AP",
                                                                                              "AP", "AP", "AP", "PA", "PA", "PA", "PA", "PA", "PA", "PA", "PA",
                                                                                              "PA", "PA", "PA", "PA", "PA", "MA", "MA", "MA", "MA", "MA", "MA",
                                                                                              "MA", "PI", "PI", "PI", "PI", "PI", "PI", "CE", "CE", "CE", "RN",
                                                                                              "RN", "PB", "PB", "PE", "PE", "PE", "PE", "PE", "AL", "AL", "SE",
                                                                                              "SE", "BA", "BA", "BA", "BA", "BA", "ES", "ES", "ES", "RJ", "RJ",
                                                                                              "RJ", "RJ", "SP", "SP", "SP", "SP", "SP", "PR", "PR", "SC", "SC",
                                                                                              "SC", "SC", "RS", "RS", "RS", "RS", "MS", "MS", "MS", "MS", "MS",
                                                                                              "MS", "MS", "MG", "MG", "MG", "MG", "MG", "MG", "MG", "MG", "GO",
                                                                                              "GO", "GO", "GO", "GO", "GO", "GO", "DF", "TO", "TO", "TO", "TO",
                                                                                              "TO", "MT", "MT", "MT", "MT", "MT", "MT", "MT", "MT", "MT", "MT",
                                                                                              "RO", "RO", "RO", "RO", "RO", "RO"), code_grid = c("ID_50", "ID_51",
                                                                                                                                                "ID_60", "ID_61", "ID_51", "ID_60", "ID_61", "ID_62", "ID_63",
                                                                                                                                                "ID_70", "ID_71", "ID_72", "ID_73", "ID_80", "ID_81", "ID_82",
                                                                                                                                                "ID_72", "ID_81", "ID_82", "ID_83", "ID_92", "ID_93", "ID_74",
                                                                                                                                                "ID_75", "ID_84", "ID_85", "ID_53", "ID_54", "ID_55", "ID_63",
                                                                                                                                                "ID_64", "ID_65", "ID_73", "ID_74", "ID_75", "ID_76", "ID_83",
                                                                                                                                                "ID_84", "ID_85", "ID_55", "ID_56", "ID_65", "ID_66", "ID_75",
                                                                                                                                                "ID_76", "ID_77", "ID_56", "ID_57", "ID_66", "ID_67", "ID_76",
                                                                                                                                                "ID_77", "ID_67", "ID_68", "ID_77", "ID_67", "ID_68", "ID_67",
                                                                                                                                                "ID_68", "ID_57", "ID_58", "ID_67", "ID_68", "ID_69", "ID_57",
                                                                                                                                                "ID_58", "ID_57", "ID_58", "ID_37", "ID_46", "ID_47", "ID_56",
                                                                                                                                                "ID_57", "ID_36", "ID_37", "ID_39", "ID_26", "ID_27", "ID_36",
                                                                                                                                                "ID_37", "ID_24", "ID_25", "ID_26", "ID_34", "ID_35", "ID_24",
                                                                                                                                                "ID_25", "ID_14", "ID_15", "ID_24", "ID_25", "ID_4", "ID_13",
                                                                                                                                                "ID_14", "ID_15", "ID_23", "ID_24", "ID_33", "ID_34", "ID_35",
                                                                                                                                                "ID_43", "ID_44", "ID_25", "ID_26", "ID_35", "ID_36", "ID_37",
                                                                                                                                           "ID_45", "ID_46", "ID_47", "ID_34", "ID_35", "ID_44", "ID_45",
                                                                                                                                                "ID_46", "ID_55", "ID_56", "ID_45", "ID_45", "ID_55", "ID_56",
                                                                                                                                                "ID_65", "ID_66", "ID_33", "ID_34", "ID_43", "ID_44", "ID_45",
                                                                                                                                                "ID_52", "ID_53", "ID_54", "ID_55", "ID_63", "ID_42", "ID_43",
                                                                                                                                                "ID_51", "ID_52", "ID_53", "ID_62")), .Names = c("name_uf", "code_state",
                                                                                                                                                                                                 "code_grid"), row.names = c(NA, -139L), class = "data.frame")

# Use UTF-8 encoding in all character columns

  grid_state_correspondence_table <- use_encoding_utf8(grid_state_correspondence_table)


# sort data alphabetically
grid_state_correspondence_table <- grid_state_correspondence_table[order(grid_state_correspondence_table$name_uf),]

# save table
  save(grid_state_correspondence_table, file = "./data/grid_state_correspondence_table.RData", compress = T)
  #


