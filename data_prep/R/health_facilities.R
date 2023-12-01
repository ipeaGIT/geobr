
# 0. Download Raw zipped  ---------------------------------

#> DATASET: Localização dos estabelecimentos registrados no Cadastro Nacional de Estabelecimentos de Saúde. Sobre o CNES
#> Source: Cadastro Nacional de Estabelecimentos de Saúde - CNES


#' source:
#' https://dados.gov.br/dados/conjuntos-dados/cnes-cadastro-nacional-de-estabelecimentos-de-saude
file_url = 'https://s3.sa-east-1.amazonaws.com/ckan.saude.gov.br/CNES/cnes_estabelecimentos.zip'


update_health_facilities <- function(){

  current_date <- Sys.Date()
  dir.create(path = temp_dir, recursive = TRUE, showWarnings = FALSE)


  # wodnload file to tempdir
  temp_local_file <- download_file(file_url = file_url)

  # unzip file to tempdir
  temp_local_dir <- tempdir()
  utils::unzip(zipfile = temp_local_file, exdir = temp_local_dir)

  # get file name
  file_name <- utils::unzip(temp_local_file, list = TRUE)$Name
  file_full_name <- paste0(temp_local_dir,'/', file_name)

  file.info(file_url)

  # read file stored locally
  dt <- data.table::fread( file_full_name )
  head(dt)


# rename columns
  names(dt) <- tolower(names(dt))
  dt <- dplyr::rename(dt,
                      code_cnes = 'co_cnes',
                      code_state = 'co_uf',
                      code_muni6 = 'co_ibge',
                      cep = 'co_cep',
                      lat = 'nu_latitude',
                      lon = 'nu_longitude')

# add state and region
  dt <- add_state_info(temp_sf = dt, column = 'code_state')
  dt <- add_region_info(temp_sf = dt, column = 'code_state')


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

  # Save raw file in sf format
  sf::st_write(cnes_sf, dsn= paste0("./health_facilities/shapes_in_sf_all_years_cleaned/",most_freq_year,"/cnes_sf_",most_freq_year,".gpkg"))

  sf::st_write(temp2_simplified, i,
               overwrite = TRUE, append = FALSE,
               delete_dsn = T, delete_layer = T, quiet = T)


}
