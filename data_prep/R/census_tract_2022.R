library(sf)
library(data.table)
library(dplyr)
library(furrr)

year <- 2022

# create dest dir
raw_dir <- paste0('./data_raw/census_tracts/',year)
dest_dir <- paste0('./data/census_tracts/',year)
dir.create(raw_dir, recursive = T)
dir.create(dest_dir, recursive = T)




#### 0. Download original data sets from IBGE ftp -----------------

if(year == 2022){

  # ftp <- 'https://ftp.ibge.gov.br/Censos/Censo_Demografico_2022/Agregados_por_Setores_Censitarios_preliminares/malha_com_atributos/setores/gpkg/BR/BR_Malha_Preliminar_2022.zip'
  ftp <- 'https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2022/setores/gpkg/BR/BR_setores_CD2022.gpkg'
  dest_file <-  download_file(file_url = ftp, dest_dir = raw_dir)

}





#### 1. clean and save data -----------------
df <- sf::st_read(paste0(raw_dir,'/BR_setores_CD2022.gpkg'))

temp_sf <- dplyr::select(
  df,
  code_tract = CD_SETOR,
  code_muni = CD_MUN,
  name_muni = NM_MUN,
  name_neighborhood = NM_BAIRRO,
  code_neighborhood = CD_BAIRRO,
  code_subdistrict = CD_SUBDIST,
  name_subdistrict = NM_SUBDIST,
  code_district = CD_DIST,
  name_district = NM_DIST,
  code_urban_concentration = CD_CONCURB,
  name_urban_concentration = NM_CONCURB,
  code_state = CD_UF,
  name_state = NM_UF,
  code_immediate = CD_RGI,
  name_immediate = NM_RGI,
  code_intermediate = CD_RGINT,
  name_intermediate = NM_RGINT,
  code_region = CD_REGIAO,
  name_region = NM_REGIAO,
  situacao = SITUACAO,
  code_situacao = CD_SIT,
  code_type = CD_TIPO,
  area_km2 = AREA_KM2
  )

head(temp_sf)


# make all name columns as character
all_cols <- names(temp_sf)
char_cols <- all_cols[all_cols %like% 'name_']
temp_sf <- mutate(temp_sf, across(all_of(char_cols), as.character))

# make all columns as character
num_cols <- all_cols[all_cols %like% 'code_']
temp_sf <- mutate(temp_sf, across(all_of(num_cols), as.numeric))

# remove lagoa dos patos e mirim
temp_sf <- subset(temp_sf, code_muni != 430000100000000)
temp_sf <- subset(temp_sf, code_muni != 430000200000000)


# Use UTF-8 encoding
temp_sf <- use_encoding_utf8(temp_sf)

# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
temp_sf <- harmonize_projection(temp_sf)
gc()




# harmonize and save

save_state <- function(code_uf){ # code_uf <- 33

    message(code_uf)

    temp_sf2 <- subset(temp_sf, code_state == code_uf)
    # temp_sf2 <- subset(temp_sf, code_muni == '3304557')

    temp_sf2 <- fix_topoly(temp_sf2)

    # convert to MULTIPOLYGON
    temp_sf2 <- to_multipolygon(temp_sf2)


    # simplify
    temp_sf_simplified <- simplify_temp_sf(temp_sf2, tolerance = 10)
    temp_sf_simplified <- fix_topoly(temp_sf_simplified)

    # Save cleaned sf in the cleaned directory
    sf::st_write(temp_sf2, paste0(dest_dir,'/', code_uf,'census_tract_', year, '.gpkg'))
    sf::st_write(temp_sf_simplified, paste0(dest_dir,'/', code_uf,'census_tract_', year, '_simplified.gpkg'))

  }


all_states <- unique(temp_sf$code_state)

# Apply function to save the data
gc(reset = T)

# tictoc::tic()
# future::plan(strategy = 'multisession')
# furrr::future_map(.x=all_states,
#                   .f=save_state,
#                   .progress = T,
#                   .options = furrr_options(seed=TRUE))
# tictoc::toc()


tictoc::tic()
pbapply::pblapply(X=all_states, FUN=save_state)
tictoc::toc()
