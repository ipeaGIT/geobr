#> DATASET: urbanized areas
#> Source: 2005 - ftp://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/areas_urbanizadas_do_brasil/2005/areas_urbanizadas_do_Brasil_2005_shapes.zip
#>         2015 - ftp://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/areas_urbanizadas_do_brasil/2015/Shape/AreasUrbanizadasDoBrasil_2015.zip
#> Metadata:
# Title: urbanized areas
# Alternate title: ***
# Date: Update 2015
#
# Presentation form: Shape
# Language: Pt-BR
# Character set: 2005 - WINDOWS-1252
#                2015 - UTF-8
#
# Abstract: Polygons of the brazilian urbanized areas.
# Purpose:: Identify the brazilian urbanized areas.
#
# Status: in development
# keywords:****
# Reference System Information: SIRGAS 2000



library(sf)
library(dplyr)
library(tidyverse)
library(tidyr)
library(data.table)
library(mapview)




###### 1. Create Root folder to save the data -----------------
# Root directory
root_dir <- "L:\\# DIRUR #\\ASMEQ\\geobr\\data-raw"
setwd(root_dir)


# Directory to keep raw zipped files
  dir.create("./urban_area")
  dir_2005 <- paste0("./urban_area/2005")
  dir_2015 <- paste0("./urban_area/2015")
  dir.create(dir_2005)
  dir.create(dir_2015)


# Directory to save clean sf.rds files
dir.create("./urban_area/shapes_in_sf_all_years_cleaned", showWarnings = FALSE)
destdir_clean_2005 <- paste0("./urban_area/shapes_in_sf_all_years_cleaned/",2005)
destdir_clean_2015 <- paste0("./urban_area/shapes_in_sf_all_years_cleaned/",2015)
dir.create(destdir_clean_2005)
dir.create(destdir_clean_2015)




#### 2. Download original data sets  -----------------



# download shape files
download.file("ftp://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/areas_urbanizadas_do_brasil/2005/areas_urbanizadas_do_Brasil_2005_shapes.zip" ,
              destfile= paste0(dir_2005,"/areas_urbanizadas_do_Brasil_2005_shapes.zip") )

download.file("ftp://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/areas_urbanizadas_do_brasil/2015/Shape/AreasUrbanizadasDoBrasil_2015.zip" ,
              destfile= paste0(dir_2015,"/areas_urbanizadas_do_Brasil_2015_shapes.zip"))




#### 3. Unzipe shape files -----------------

# 2005
unzip( paste0(dir_2005,"/areas_urbanizadas_do_Brasil_2005_shapes.zip"), exdir = dir_2005)

# 2015
unzip( paste0(dir_2015,"/areas_urbanizadas_do_Brasil_2015_shapes.zip"), exdir = dir_2015)






#### 4. 2005 Clean data set and save it in compact .rds format-----------------


##### 4.1 read shape files -------------------
setwd(root_dir)

# 2005
  ACP_urban_05 <- st_read( paste0(dir_2005,"/AreasUrbanizadas_MunicipiosACP_porMunicipio.shp"),
                                    options = "ENCODING=WINDOWS-1252")
  cemk_urban_05 <- st_read( paste0(dir_2005,"/AreasUrbanizadas_MunicipiosAcima100k_porMunicipio.shp"),
                                     options = "ENCODING=WINDOWS-1252")
  cost_urban_05 <- st_read( paste0(dir_2005,"/AreasUrbanizadas_MunicipiosCosteiros_porMunicipio.shp"),
                                     options = "ENCODING=WINDOWS-1252")


  # 2015
  mais_urban_15 <- st_read( paste0(dir_2015,"/AreasUrbanizadasDoBrasil_2015_Concentracoes_Urbanas_com_mais_de_300000_habitantes.shp"),
                                   options = "ENCODING=UTF-8")
  ate_urban_15 <- st_read( paste0(dir_2015,"/AreasUrbanizadasDoBrasil_2015_Concentracoes_Urbanas_de_100000_a_300000_habitantes.shp"),
                                    options = "ENCODING=UTF-8")


# do they come with the same projection? Yes
  st_crs(ACP_urban_05) == st_crs(cemk_urban_05)
  st_crs(ACP_urban_05) == st_crs(cost_urban_05)


  original_crs <- st_crs(mais_urban_15)



##### 4.2 Pile them up by year -------------------

# Make sure all data sets have the same columns (in the same order)
  #2005
   ACP_urban_05$POP_2005 <- NA
   ACP_urban_05$dataset <- "population concentration area"

   cost_urban_05$POP_2005 <- NA
   cost_urban_05$ACP <- NA
   cost_urban_05$COD_ACP <- NA
   cost_urban_05$dataset <- "coastal area"

   cemk_urban_05$ACP <- NA
   cemk_urban_05$COD_ACP <- NA
   cemk_urban_05$dataset <- "population above 100k"

   # columns in the same order
    setDT(ACP_urban_05)
    setDT(cost_urban_05)
    setDT(cemk_urban_05)

    setcolorder(cost_urban_05, neworder= c(names(ACP_urban_05)) )
    setcolorder(cemk_urban_05, neworder=  c(names(ACP_urban_05)) )


   # pile them up
    urb_2005 <- rbind(ACP_urban_05, cemk_urban_05, cost_urban_05)

 #2015
   ate_urban_15$FID_1 <-  NA
   ate_urban_15$UF <-  NULL
   ate_urban_15 <- dplyr::rename(ate_urban_15, NomeConcUr = NomConcUrb)
   mais_urban_15$OBJECTID <- NULL

   # do they come with the same projection? Yes
    st_crs(mais_urban_15) == st_crs(ate_urban_15)



   # columns in the same order
    setDT(mais_urban_15)
    setDT(ate_urban_15)

    setcolorder(ate_urban_15, neworder= c(names(mais_urban_15)) )

   # pile them up
    urb_2015 <- rbind(ate_urban_15,mais_urban_15)



##### 4.3 Data cleaning -------------------

  # Rename and reoder columns
  urb_2005 <- dplyr::select(urb_2005,
                            code_urb = GEOC_URB,
                            pop_2005 = POP_2005,
                            area_km2 = Area_Km2,
                            density = Tipo,
                            code_muni = GEOCODIGO,
                            name_muni = NOME_MUNIC,
                            code_acp = COD_ACP,
                            name_acp = ACP,
                            abbrev_state = UF,
                            dataset = dataset,
                            geometry = geometry
                            )

   urb_2015 <- dplyr::select(urb_2015,
                             fid_1 = FID_1,
                             density = Densidade,
                             code_muni = CodConcUrb,
                             type = Tipo,
                             name_muni = NomeConcUr,
                             area_geo = AREA_GEO,
                             shape_leng = Shape_Leng,
                             shape_area = Shape_Area,
                             geometry = geometry
                             )


# convert codes to numeric
  urb_2005$code_urb <- urb_2005$code_urb %>% as.character() %>% as.numeric()
  urb_2005$code_muni <- urb_2005$code_muni %>% as.character() %>% as.numeric()
  urb_2005$code_acp <- urb_2005$code_acp %>% as.character() %>% as.numeric()

  urb_2015$fid_1 <- urb_2015$fid_1 %>% as.character() %>% as.numeric()
  urb_2015$code_muni <- urb_2015$code_muni %>% as.character() %>% as.numeric()
  #urb_2015$code_acp <- urb_2015$code_acp %>% as.character() %>% as.numeric()

  # convert codes to character
  urb_2005$density <- urb_2005$density %>% as.character()
  urb_2005$name_muni <- urb_2005$name_muni %>% as.character()
  urb_2005$name_acp <- urb_2005$name_acp %>% as.character()
  urb_2005$abbrev_state <- urb_2005$abbrev_state %>% as.character()
  urb_2005$dataset <- urb_2005$dataset %>% as.character()

  urb_2015$density <- urb_2015$density %>% as.character()
  urb_2015$name_muni <- urb_2015$name_muni %>% as.character()
  urb_2015$tipo <- urb_2015$tipo %>% as.character()
  #urb_2015$code_muni <- urb_2015$abbrev_state %>% as.character()
  #urb_2015$dataset <- urb_2015$dataset %>% as.character()



# remove Z dimension of spatial data
  urb_2015 <- urb_2015 %>% st_sf() %>% st_zm( drop = T, what = "ZM")
  urb_2005 <- urb_2005 %>% st_sf() %>% st_zm( drop = T, what = "ZM")



# Recupera info de code_state e name_state

# 2005
  estados <- geobr::read_state(code_state = 'all', year=2010)
  estados$geometry <- NULL
  estados <- select(estados, 'code_state', 'abbrev_state', 'name_state')
  urb_2005 <- left_join(urb_2005, estados)


# 2015
  municipios <- geobr::read_municipality(code_muni  = 'all', year=2015)
  municipios$geometry <- NULL
  municipios <- select(municipios, 'code_muni','name_muni','code_state','abbrev_state')
  urb_2015 <- dplyr::left_join(urb_2015, municipios)


# Use UTF-8 encoding in all character columns
  urb_2005 <- urb_2005 %>%
                      mutate_if(is.factor, function(x){ x %>% as.character() %>%
                                                      stringi::stri_encode("UTF-8") } )
  urb_2015 <- urb_2015 %>%
                      mutate_if(is.factor, function(x){ x %>% as.character() %>%
                                                      stringi::stri_encode("UTF-8") } )


# reoder columns
  setDT(urb_2005)
  setcolorder(urb_2005, c("code_urb", "pop_2005", "area_km2", "density", "code_muni", "name_muni", "code_acp", "name_acp",
                          "code_state", "abbrev_state", "name_state", "dataset", "geometry"))

  setDT(urb_2015)
  setcolorder(urb_2015, c("fid_1", "density", "code_muni", "tipo",  "name_muni", "area_geo", "shape_leng", "shape_area",
                          "code_state", "abbrev_state", "geometry"))

# Convert data.table back into sf
  urb_2005 <- st_as_sf(urb_2005, crs=original_crs)
  urb_2015 <- st_as_sf(urb_2015, crs=original_crs)


# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
  urb_2005 <- if( is.na(st_crs(urb_2005)) ){ st_set_crs(urb_2005, 4674) } else { st_transform(urb_2005, 4674) }
  st_crs(urb_2005) <- 4674

  urb_2015 <- if( is.na(st_crs(urb_2015)) ){ st_set_crs(urb_2015, 4674) } else { st_transform(urb_2015, 4674) }
  st_crs(urb_2015) <- 4674



# Make any invalid geometry valid # st_is_valid( sf)
  urb_2005 <- lwgeom::st_make_valid(urb_2005)
  urb_2015 <- lwgeom::st_make_valid(urb_2015)



##### 4.4 Save  -------------------

  # Save cleaned sf in the cleaned directory
  readr::write_rds(urb_2005, path=paste0(destdir_clean_2005,"/urban_area_2005.rds"), compress = "gz")
  readr::write_rds(urb_2015, path=paste0(destdir_clean_2015,"/urban_area_2015.rds"), compress = "gz")



# #### 4. 2015 Clean data set and save it in compact .rds format-----------------
#
#
#
#
#
#
# #### 5. 2015 Clean data set and save it in compact .rds format-----------------
#
#
# ##### 5.1 read shape files -------------------
#   setwd(root_dir)
#  # activate directory 2015
#   setwd(dir_2015)
#
#  # do they come with the same projection? Yes
#   st_crs(ACP_urban_05) == st_crs(cemk_urban_05)
#   st_crs(ACP_urban_05) == st_crs(cost_urban_05)
#   st_crs(mais_urban_15) == st_crs(ate_urban_15)
#
#   original_crs <- st_crs(mais_urban_15)
#
#
#
#
#
#
#
#
# ########  mais ---------------------
#
# # rename and create columns
# mais_urban_15 <- dplyr::rename(mais_urban_15, fid_1 = FID_1, densidade = Densidade, tipo = Tipo, code_muni = CodConcUrb)
#
# mais_urban_15_new<-merge(mais_urban_15,ibge_15,by="code_muni")
# head(mais_urban_15)
#
# # order and and delete columns
# mais_urb_15 <- mais_urban_15_new[,c("densidade","code_muni","code_state","name_muni",
#                                     "abbrev_state","geometry","tipo")]
#
# # store original CRS
# original_crs <- sf::st_crs(mais_urb_15)
#
# # Convert data.table back into sf
# mais_urb_15_sf <- st_as_sf(mais_urb_15, crs=original_crs)
#
# # Use UTF-8 encoding
# str(mais_urb_15_sf)
#
# mais_urb_15_sf$name_muni <- stringi::stri_encode(as.character(mais_urb_15_sf$name_muni), "UTF-8")
# mais_urb_15_sf$abbrev_state <- stringi::stri_encode(as.character(mais_urb_15_sf$abbrev_state), "UTF-8")
#
# # test the shape
# mapview(mais_urb_15_sf)
#
# # Save cleaned sf in the cleaned directory
# readr::write_rds(mais_urb_15_sf,"./mais_urb_15.rds", compress = "gz")
#
#
# #############
# ##### até ---------------
#
# # rename and create columns
# ate_urban_15 <- dplyr::rename(ate_urban_15, densidade = Densidade, tipo = Tipo, code_muni = CodConcUrb)
#
# ate_urban_15_new<-merge(ate_urban_15,ibge_15,by="code_muni")
# head(ate_urban_15)
#
# # order and and delete columns
# ate_urb_15 <- ate_urban_15_new[,c("densidade","code_muni","code_state","name_muni",
#                                     "abbrev_state","geometry","tipo")]
#
# # store original CRS
# original_crs <- sf::st_crs(ate_urb_15)
#
# # Convert data.table back into sf
# ate_urb_15_sf <- st_as_sf(ate_urb_15, crs=original_crs)
#
#
# # Use UTF-8 encoding
# str(ate_urb_15_sf)
#
# ate_urb_15_sf$name_muni <- stringi::stri_encode(as.character(ate_urb_15_sf$name_muni), "UTF-8")
# ate_urb_15_sf$abbrev_state <- stringi::stri_encode(as.character(ate_urb_15_sf$abbrev_state), "UTF-8")
#
# # test the shape
# mapview(ate_urb_15_sf)
#
# # Save cleaned sf in the cleaned directory
# readr::write_rds(ate_urb_15_sf,"./ate_urb_15.rds", compress = "gz")
#
#
#
# ##### join datasets --------------------
#
#
#
# # Save cleaned sf in the cleaned directory
# readr::write_rds(urb_2005_sf,"./urb_2005.rds", compress = "gz")
#
# # creat dataset column
# setwd(dir_2015)
#
# mais_urb_15$dataset <- "population greater than 300k"
# ate_urb_15$dataset <- "population less than 300k"
#
# dim(mais_urb_15)
# dim(ate_urb_15)
#
# urb_2015 <- rbind(ate_urb_15,mais_urb_15)
# dim(urb_2015)
#
# # store original CRS
# original_crs <- sf::st_crs(urb_2015)
#
# # Convert data.table back into sf
# urb_2015_sf <- st_as_sf(urb_2015, crs=original_crs)
#
# #test the shape
# mapview(urb_2015_sf)
#
# # Save cleaned sf in the cleaned directory
# readr::write_rds(urb_2015_sf,"./urb_2015.rds", compress = "gz")
#
