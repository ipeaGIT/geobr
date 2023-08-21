
# 0. Download Raw zipped files for all years ---------------------------------
#' input: year
#' download raw data from source website to temp zip file
#' save raw data in .rds format in the data-raw dir
#' output: returns path to all raw files of that year
download_muni <- function(year){

  # year = 2000

  message(paste0("\nDownloading year: ", year, '\n'))

  ftp <- "https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/"

  # create dir if it has not been created already
  dest_dir <- paste0('./data-raw/municipios/', year)
  if (isFALSE(dir.exists(dest_dir))) { dir.create(dest_dir,
                                                  recursive = T,
                                                  showWarnings = FALSE) }

  if (year >= 2015) {

    # list files and get file name
    subdir <- paste0(ftp, "municipio_", year,"/", 'Brasil', "/", 'BR', "/")
    files <- list_folders(subdir)
    files <- files[ data.table::like(files, 'Municipio|municipio') ]
    filenameext <- files[ data.table::like(files, '.zip') ]
    filename <- gsub('.zip', '', filenameext)

    # Download zipped files
    temp_dir <- tempdir()
    temp_dir <- paste0(temp_dir, '/', year, '/', filename)
    dir.create(path = temp_dir, recursive = TRUE, showWarnings = FALSE)

    tempf <- paste0(temp_dir, '/', filenameext)
    httr::GET(url = paste0(subdir, filename),
              httr::progress(),
              httr::write_disk(tempf, overwrite = T),
              config = httr::config(ssl_verifypeer = FALSE)
              )

    ## save raw data in .rds
    #message('\nsaving raw\n')
    muni_saveraw(tempf, temp_dir, dest_dir)
    }

  if (year %in% c(2005, 2007)) {

    # list folders
    subdir <- paste0(ftp, 'municipio_', year, "/")
    folders <- list_folders(subdir)
    folder <- folders[data.table::like(folders, '2500mil')]

    # LEVEL 2 escala e projecao
    if(year==2005){subdir = paste0(ftp,'municipio_', year, "/", folder, "proj_geografica/arcview_shp/uf/")}
    if(year==2007){subdir = paste0(ftp,'municipio_', year, "/", folder, "proj_geografica_sirgas2000/uf/")}

    folders <- list_folders(subdir)
    folders <- folders[nchar(folders) == 3]

    # LEVEL 3
    for (n2 in folders){ # n2 <- folders[2]

      ## debugging 66666
      # n2 in folders[1:2]

      # list files
      subdir2 <- paste0(subdir, n2)
      files <- list_folders(subdir2)
      files <- files[ data.table::like(files, 'mu2500') ]
      filenameext <- files[ data.table::like(files, '.zip') ]
      filename <- gsub('.zip', '', filenameext)

      # Download zipped files
      temp_dir <- tempdir()
      temp_dir <- paste0(temp_dir, '/', year, '/', filename)
      dir.create(path = temp_dir, recursive = TRUE, showWarnings = FALSE)

      tempf <- paste0(temp_dir, '/', filenameext)
      httr::GET(url = paste0(subdir2, filenameext),
                httr::progress(),
                httr::write_disk(tempf, overwrite = T),
                config = httr::config(ssl_verifypeer = FALSE)
                )
      ## save raw data in .rds
      #message('\nsaving raw\n')
      muni_saveraw(tempf, temp_dir, dest_dir)
      }
    }

  if (year < 2015 & year!=2005 & year!=2007) {

    # list folders
    subdir <- paste0(ftp, 'municipio_', year, "/")
    folders <- list_folders(subdir)
    folders <- folders[nchar(folders) == 3]

    # LEVEL 2
    for (n2 in folders){ # n2 <- folders[2]

      ## debugging 66666
      # n2 in folders
      # n2 in folders[1:2]

      # list files
      subdir2 <- paste0(subdir, n2)
      files <- list_folders(subdir2)
      files <- files[ data.table::like(files, 'Municipio|municipio|mu2500g') ]
      filenameext <- files[ data.table::like(files, '.zip') ]
      filename <- gsub('.zip', '', filenameext)

      # Download zipped files
      temp_dir <- tempdir()
      temp_dir <- paste0(temp_dir, '/', year, '/', filename)
      dir.create(path = temp_dir, recursive = TRUE, showWarnings = FALSE)

      tempf <- paste0(temp_dir, '/', filenameext)
      httr::GET(url = paste0(subdir2, filename),
                httr::progress(),
                httr::write_disk(tempf, overwrite = T),
                config = httr::config(ssl_verifypeer = FALSE)
                )

      ## save raw data in .rds
      #message('\nsaving raw\n')
      muni_saveraw(tempf, temp_dir, dest_dir)
      }


    }

  # list files
  muni_raw_paths <- list.files(path = dest_dir,
                              pattern = '.rds',
                            #  recursive = TRUE,
                              full.names = TRUE
                              )
 return(muni_raw_paths)

  #clean_muni(muni_raw_path)
  }

# 1. read raw zipped file in temporary dir  ---------------------------------
#' input: tempfile of raw data, temp dir of raw data, dest dir to save raw data
#' unzip and read raw data
#' output: save raw data in .rds format in the data-raw dir
muni_saveraw <- function(tempf, temp_dir, dest_dir) {

  ## 1.1 Unzip original data
  unzip(zipfile = tempf, exdir = temp_dir, overwrite = TRUE)

  ## 1.2. read shape file

  # List shape file
  shape_file <- list.files(path = temp_dir, full.names = T, recursive = T, pattern = ".shp$")
  shape_file <- shape_file <- shape_file[ data.table::like(shape_file, 'MU|mu2500|Municipios|municipios') ]

  # detect year from file name
  year <- detect_year_from_string(tempf)
  year <- year[year != '2500']
  year <- year[year != '0807']
  year <- year[1]

  # Encoding for different years
  if (year %like% "2000") {
    temp_sf <- sf::st_read(shape_file, quiet = T, stringsAsFactors=F, options = "ENCODING=IBM437")
  }

  if (year %like% "2001|2005|2007|2010"){
    temp_sf <- sf::st_read(shape_file, quiet = T, stringsAsFactors=F, options = "ENCODING=WINDOWS-1252")
  }

  if (year >= 2013) {
    temp_sf <- sf::st_read(shape_file, quiet = T, stringsAsFactors=F, options = "ENCODING=UTF8")
  }


  ## 1.3. Save original data in compact .rds format

  # file name
  file_name <- gsub(".shp$", ".rds", basename(shape_file), ignore.case = T)

  # save in .rds
  saveRDS(temp_sf, file = paste0(dest_dir,"/", file_name), compress = TRUE)

  # # return path to raw file
  # muni_raw_path <- paste0(dest_dir,"/", file_name)
  # return(muni_raw_path)
}




