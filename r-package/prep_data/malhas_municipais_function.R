# Region options:
# uf, municipio, meso_regiao, micro_regiao

malhas_municipais <- function(region=NULL){
  
  ########  0. Download original data sets from IBGE ftp     -----------------

    ftp <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais"
    
    ########  1. Unzip original data sets downloaded from IBGE -----------------
    
    # Root directory
    root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw//malhas_municipais"
    setwd(root_dir)
    
    #### 1.1. GROUP 1/3 - Data available separately by state in a single resolution E -----------------
    # 2000, 2001, 2010, 2013, 2014
    
    # List all zip files for all years
    all_zipped_files <- list.files(full.names = T, recursive = T, pattern = ".zip")
    
    if (region == "uf"){all_zipped_files <- all_zipped_files[(all_zipped_files %like% "unidades_da_")]}
    if (region == "meso_regiao"){all_zipped_files <- all_zipped_files[all_zipped_files %like% "mesorregioes|me"]}
    if (region == "micro_regiao"){all_zipped_files <- all_zipped_files[all_zipped_files %like% "microrregioes|mi"]}
    if (region == "municipio"){all_zipped_files <- all_zipped_files[all_zipped_files %like% "municipios|mu500|mu2500|mu1000"]}
    
    # Select files of selected years
    # 540 files (4 geographies x 27 states x 5 years) 4*27*5
    files_1st_batch <- all_zipped_files[all_zipped_files %like% "2000|2001|2010|2013|2014"]
    
    # function to Unzip files in their original sub-dir
    unzip_fun <- function(f){
      # f <- files_1st_batch[1]
      unzip(f, exdir = file.path(root_dir, substr(f, 2, 20) ))
    }
    
    # create computing clusters
    cl <- parallel::makeCluster(detectCores())
    parallel::clusterExport(cl=cl, varlist= c("files_1st_batch", "root_dir"), envir=environment())
    
    # apply function in parallel
    parallel::parLapply(cl, files_1st_batch, unzip_fun)
    stopCluster(cl)
    
    
    rm(list=setdiff(ls(), c("root_dir","all_zipped_files","region")))
    gc(reset = T)
    
    #### 1.2 GROUP 2/3 - Data available separately by state in a single resolution and file -----------------
    # 2015, 2016, 2017, 2018
    
    # List all zip files for all years
    all_zipped_files
    
    # Select files of selected years
    files_2nd_batch <- all_zipped_files[all_zipped_files %like% "2015|2016|2017|2018|2019"]
    
    # remove Brazil files
    files_2nd_batch <- files_2nd_batch[!(files_2nd_batch %like% "BR")]
    
    # Select one file for each state
    # 540 files (4 geographies x 27 states x 4 years) 4*27*4
    files_2nd_batch <- files_2nd_batch[nchar(files_2nd_batch) > 30]
    
    
    # function to Unzip files in their original sub-dir
    unzip_fun <- function(f){
      # f <- files_2nd_batch[14]
      unzip(f, exdir = file.path(root_dir, substr(f, 2, 23)) )
    }
    
    # create computing clusters
    cl <- parallel::makeCluster(detectCores())
    parallel::clusterExport(cl=cl, varlist= c("files_2nd_batch", "root_dir"), envir=environment())
    
    # apply function in parallel
    parallel::parLapply(cl, files_2nd_batch, unzip_fun)
    stopCluster(cl)
    
    rm(list=setdiff(ls(), c("root_dir","all_zipped_files","region")))
    gc(reset = T)
    
    
    #### 1.3 GROUP 3/3 - Data available separately by state in a single resolution and file -----------------
    # 2005, 2007
    
    # List all zip files for all years
    all_zipped_files
    
    # Select files of selected years
    files_3rd_batch <- all_zipped_files[all_zipped_files %like% "2005|2007"]
    
    # Selc only zip files organized by UF at scale  1:2.500.000
    # 54 files (27 files x 2 years) 27*2
    files_3rd_batch <- files_3rd_batch[files_3rd_batch %like% "escala_2500mil/proj_geografica/arcview_shp/uf|escala_2500mil/proj_geografica_sirgas2000/uf"]
    
    # function to Unzip files in their original sub-dir
    unzip_fun <- function(f){
      # f <- files_3rd_batch[54]
      
      # subdir to unzip/save files
      dest_dir <- file.path(root_dir, substr(f, 2, 65))
      
      # unzip
      unzip(f, exdir = dest_dir )
    }
    
    # create computing clusters
    cl <- parallel::makeCluster(detectCores())
    parallel::clusterExport(cl=cl, varlist= c("files_3rd_batch", "root_dir"), envir=environment())
    
    # apply function in parallel
    parallel::parLapply(cl, files_3rd_batch, unzip_fun)
    stopCluster(cl)
    
    gc(reset = T)
    
    #### 2. Create folders to save sf.rds files  -----------------
    
    sub_dirs <- list.dirs(path =root_dir, recursive = F)
    
    # get all years in the directory
    last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
    years <- lapply(sub_dirs, last4)
    years <-  unlist(years)
    
    # create directory to save original shape files in sf format
    dir.create(file.path("shapes_in_sf_all_years_original"), showWarnings = FALSE)
    
    # create a subdirectory of states, municipalities, micro and meso regions
    dir.create(file.path("shapes_in_sf_all_years_original/",paste0(region)), showWarnings = FALSE)
    
    # create a subdirectory of years
    sub_dirs <- paste0("./shapes_in_sf_all_years_original/",region)
    
    
    
    for (i in sub_dirs){
      for (y in years){
        dir.create(file.path(i, y), showWarnings = FALSE)
      }
    }
    
    sub_dirs <- paste0("./shapes_in_sf_all_years_cleaned/",region)
    
    for (i in sub_dirs){
      for (y in years){
        dir.create(file.path(i, y), showWarnings = FALSE)
      }
    }
    
    gc(reset = T)
    
    
    
    
    
    #### 3. Save original data sets downloaded from IBGE in compact .rds format-----------------
    
    # List shapes for all years
    all_shapes <- list.files(full.names = T, recursive = T, pattern = ".shp$")
    
    if (region == "uf"){all_shapes <- all_shapes[(all_shapes %like% "UFE250|uf500|UF2500|UF500|UF2500|UF_")]}
    if (region == "meso_regiao"){all_shapes <- all_shapes[all_shapes %like% "mesorregioes|ME500|ME2500|ME1000|ME500|ME2500|ME1000"]}
    if (region == "micro_regiao"){all_shapes <- all_shapes[all_shapes %like% "MI500|MI2500|MI1000|mi500|mi2500|mi1000|Microrregioes"]}
    if (region == "municipio"){all_shapes <- all_shapes[all_shapes %like% "MU500|MU2500|MU1000|mu500|mu2500|mu1000|municipios"]}
    
    shp_to_sf_rds <- function(x){
      
      
      # get corresponding year of the file
      year <- substr(x, 13, 16)
      
      region <- region
      
      # select file
      # x <- all_shapes[all_shapes %like% 2000][3]
      

      # Encoding for different years
      if (year %like% "2000"){
        shape <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=IBM437")
      }
      
      if (year %like% "2001|2005|2007|2010"){
        shape <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")
      }
      
      if (year %like% "2013|2014|2015|2016|2017|2018|2019"){
        shape <- st_read(x, quiet = T, stringsAsFactors=F, options = "ENCODING=UTF8")
      }
      
      
      # get destination subdirectory based on abbreviation of the geography
      last15 <- substr(x, nchar(x)-15, nchar(x))   # function to get the last 4 digits of a string
      
      if ( last15 %like% "UF|uf|ME|me|MI|mi|MU|mu|municipio"){ dest_dir <- paste0("./shapes_in_sf_all_years_original/",region,"/", year)}

      # name of the file that will be saved
      if( year %like% "2000|2001|2010|2013|2014"){ file_name <- paste0(toupper(substr(x, 21, 24)), ".rds") }
      if( year %like% "2005"){ file_name <- paste0( toupper(substr(x, 67, 70)), ".rds") }
      if( year %like% "2007"){ file_name <- paste0( toupper(substr(x, 66, 69)), ".rds") }
      if( year %like% "2015|2016|2017|2018|2019"){ file_name <- paste0( toupper(substr(x, 25, 28)), ".rds") }
      
      # save in .rds
      write_rds(shape, path = paste0(dest_dir,"/", file_name), compress="gz" )
    }
    
    
    # Apply function to save original data sets in rds format
    
    # create computing clusters
    cl <- parallel::makeCluster(detectCores())
    
    clusterEvalQ(cl, c(library(data.table), library(readr), library(sf)))
    parallel::clusterExport(cl=cl, varlist= c("all_shapes","region","malhas_municipais"), envir=environment())
    
    # apply function in parallel
    parallel::parLapply(cl, all_shapes, shp_to_sf_rds)
    stopCluster(cl)
    
    # rm(list= ls())
    gc(reset = T)

  
}