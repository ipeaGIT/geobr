library(sf)
library(data.table)
library(dplyr)

dest_dir <- 'C:/Users/user/Downloads/BR_Malha_Preliminar_2022/'

df <- sf::st_read('C:/Users/user/Downloads/BR_Malha_Preliminar_2022/BR_Malha_Preliminar_2022.gpkg')
saveRDS(df, 'C:/Users/user/Downloads/BR_Malha_Preliminar_2022/BR_Malha_Preliminar_2022.rds')

df$AREA_KM2 <- NULL

temp_sf <- dplyr::rename(df,
                     code_tract = CD_SETOR,
                     code_muni = CD_MUN,
                     name_muni = NM_MUN,
                     code_subdistrict = CD_SUBDIST,
                     name_subdistrict = NM_SUBDIST,
                     code_district = CD_DIST,
                     name_district = NM_DIST,
                     code_urban_concentration = CD_CONCURB,
                     name_urban_concentration = NM_CONCURB,
                     code_state = CD_UF,
                     name_state = NM_UF,
                     code_micro = CD_MICRO,
                     name_micro = NM_MICRO,
                     code_meso = CD_MESO,
                     name_meso = NM_MESO,
                     code_immediate = CD_RGI,
                     name_immediate = NM_RGI,
                     code_intermediate = CD_RGINT,
                     name_intermediate = NM_RGINT,
                     code_region = CD_REGIAO,
                     name_region = NM_REGIAO
                     )
head(temp_sf)


# remove P from code tract
temp_sf <- mutate(temp_sf, code_tract = gsub("P","", code_tract))
head(temp_sf)


# make all columns as character
char_cols <- names(temp_sf)
char_cols <- char_cols[char_cols %like% 'code_|name_']
temp_sf <- mutate(temp_sf, across(all_of(char_cols), as.character))


# Use UTF-8 encoding
temp_sf <- use_encoding_utf8(temp_sf)

# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
temp_sf <- harmonize_projection(temp_sf)

save_state <- function(code_uf){ # code_uf <- 11

    temp_sf2 <- subset(temp_sf, code_state == code_uf)

   # temp_sf2 <- subset(temp_sf2, code_muni == '3304557')


    # convert to MULTIPOLYGON
    temp_sf2 <- to_multipolygon(temp_sf2)

    # simplify
    temp_sf_simplified <- simplify_temp_sf(temp_sf2, tolerance = 10)

    # Save cleaned sf in the cleaned directory
  #  sf::st_write(temp_sf2, paste0(dest_dir, code_uf,".gpkg") )
    sf::st_write(temp_sf_simplified, paste0(dest_dir, code_uf,"_simplified.gpkg"))

  }


all_states <- unique(temp_sf$code_state)

# Apply function to save the data
gc(reset = T)

tictoc::tic()
future::plan(strategy = 'multisession')
furrr::future_map(.x=all_states, .f=save_state, .progress = T)
tictoc::toc()


tictoc::tic()
pbapply::pblapply(X=all_states, FUN=save_state)
tictoc::toc()
