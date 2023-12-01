
# 0. Download Raw zipped  ---------------------------------

#> DATASET: Localização dos estabelecimentos registrados no Cadastro Nacional de Estabelecimentos de Saúde. Sobre o CNES
#> Source: Cadastro Nacional de Estabelecimentos de Saúde - CNES




update_health_facilities <- function(){

  #' source:
  #' https://dados.gov.br/dados/conjuntos-dados/cnes-cadastro-nacional-de-estabelecimentos-de-saude
  file_url = 'https://s3.sa-east-1.amazonaws.com/ckan.saude.gov.br/CNES/cnes_estabelecimentos.zip'

  # determine date of last update
  caminho_api <- "https://dados.gov.br/api/publico/conjuntos-dados/cnes-cadastro-nacional-de-estabelecimentos-de-saude"

  meta <- jsonlite::read_json(caminho_api, simplifyVector = TRUE) |>
      purrr::pluck("resources")  |>
      tibble::as_tibble() |>
      dplyr::filter(format == "ZIP")

  meta$created
  date_update <- as.Date(meta$created) |> as.character()
  date_update <- gsub("-", "", date_update)
  year_update <- substring(date_update, 1, 4)

  # wodnload file to tempdir
  temp_local_file <- download_file(file_url = file_url)

  # unzip file to tempdir
  temp_local_dir <- tempdir()
  utils::unzip(zipfile = temp_local_file, exdir = temp_local_dir)

  # get file name
  file_name <- utils::unzip(temp_local_file, list = TRUE)$Name
  file_full_name <- paste0(temp_local_dir,'/', file_name)

  # read file stored locally
  dt <- data.table::fread( file_full_name )
  head(dt)

  # rename columns
  names(dt) <- tolower(names(dt))
  dt <- dplyr::rename(dt,
                      code_cnes = 'co_cnes',
                      code_state = 'co_uf',
                      code_muni6 = 'co_ibge',
                      lat = 'nu_latitude',
                      lon = 'nu_longitude')

  # fix code_cnes to 7 digits
  dt[, code_cnes := sprintf("%07d", code_cnes)]

  # fix code_muni to 7 digits
  muni <- geobr::read_municipality(code_muni = 'all', year = as.numeric(year_update) - 1)
  code7 <- data.table(code_muni = muni$code_muni)
  code7[, code_muni6 := as.numeric(substring(code_muni, 1, 6))]

  dt[code7,  on = 'code_muni6', code_muni := i.code_muni]
  dt[, code_muni6 := NULL]

  # add state and region
  dt <- add_state_info(temp_sf = dt, column = 'code_state')
  dt <- add_region_info(temp_sf = dt, column = 'code_state')

  # add update date columns
  dt[, date_update := as.character(date_update)]
  dt[, year_update := as.character(year_update)]

  # reorder columns
  data.table::setcolorder(dt,
                          c('code_cnes',
                            'code_muni',
                            'code_state', 'abbrev_state', 'name_state',
                            'code_region', 'name_region',
                            'date_update', 'year_update'))



  head(dt)
  #   dt[is.na(lat) | is.na(lon),]
  #   dt[lat==0,]

  # replace NAs with 0
  data.table::setnafill(dt,
                        type = "const",
                        fill = 0,
                        cols=c("lat","lon")
                        )



  # Convert originl data frame into sf
  temp_sf <- sf::st_as_sf(x = dt,
                          coords = c("lon", "lat"),
                          crs = "+proj=longlat +datum=WGS84")


  # Change CRS to SIRGAS  Geodetic reference system "SIRGAS2000" , CRS(4674).
  temp_sf <- harmonize_projection(temp_sf)


  # create folder to save the data
  dest_dir <- paste0('./data/health_facilities/')
  dir.create(path = dest_dir, recursive = TRUE, showWarnings = FALSE)


  # Save raw file in sf format
  sf::st_write(cnes_sf,
               dsn= paste0(dest_dir, 'cnes_', date_update,".gpkg"),
               overwrite = TRUE,
               append = FALSE,
               delete_dsn = T,
               delete_layer = T,
               quiet = T
               )

}
