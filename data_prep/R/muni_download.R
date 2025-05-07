
# 0. Download Raw zipped files for all years ---------------------------------
#' input: year
#' download raw data from source website to temp zip file
#' save raw data in .rds format in the data_raw dir
#' output: returns path to all raw files of that year
download_muni <- function(year){

  # year = 2023

  message(paste0("\nDownloading year: ", year, '\n'))

  ftp <- "https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/"

  # create dir if it has not been created already
  dest_dir <- paste0('./data_raw/municipios/', year)
  if (isFALSE(dir.exists(dest_dir))) { dir.create(dest_dir,
                                                  recursive = T,
                                                  showWarnings = FALSE) }

  if (year >= 2015 & year <= 2022) {

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



  if (year >= 2023) {

    # list files and get file name
    subdir <- paste0(ftp, "municipio_", year,"/", 'Brasil', "/")
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





