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

### Libraries (use any library as necessary)

library(sf)
library(dplyr)
library(tidyverse)
library(tidyr)
library(data.table)
library(mapview)
library(geobr)



####### Load Support functions to use in the preprocessing of the data
 # setwd("C:/Users/Babis/Documents/IPEA/geobr/r-package")
source("./R/support_fun.R")


year <- 2015


###### 1. Create Root folder to save the data -----------------

# create dirs
dir_raw <- paste0("./data_raw/urban_area/",year,'/')
dest_dir <- paste0("./data/urban_area/",year,'/')
dir.create(dir_raw, recursive = T, showWarnings = F)
dir.create(dest_dir, recursive = T, showWarnings = F)


#### 2. Download original data sets  -----------------

zip_file <- paste0(dir_raw, "/areas_urbanizadas_do_Brasil_", year, "_shapes.zip")

if(year==2005) {
  download.file(
    "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/areas_urbanizadas_do_brasil/2005/areas_urbanizadas_do_Brasil_2005_shapes.zip" ,
    destfile = zip_file)
}
if (year == 2015) {
  download.file(
    "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/areas_urbanizadas_do_brasil/2015/Shape/AreasUrbanizadasDoBrasil_2015.zip" ,
    destfile = zip_file)
}


#### 3. Unzipe shape files -----------------

unzip( zip_file, exdir = dir_raw)




#### 4. 2005 Clean data set and save it in compact .rds format-----------------


##### 4.1 read shape files -------------------

if(year==2005){
    ACP_urban_05 <- st_read( paste0(dir_2005,"/AreasUrbanizadas_MunicipiosACP_porMunicipio.shp"),
                             options = "ENCODING=WINDOWS-1252")
    cemk_urban_05 <- st_read( paste0(dir_2005,"/AreasUrbanizadas_MunicipiosAcima100k_porMunicipio.shp"),
                              options = "ENCODING=WINDOWS-1252")
    cost_urban_05 <- st_read( paste0(dir_2005,"/AreasUrbanizadas_MunicipiosCosteiros_porMunicipio.shp"),
                              options = "ENCODING=WINDOWS-1252")
    }

if(year==2015){
  mais_urban_15 <- st_read( paste0(dir_raw,"/AreasUrbanizadasDoBrasil_2015_Concentracoes_Urbanas_com_mais_de_300000_habitantes.shp"),
                            options = "ENCODING=UTF-8")
  ate_urban_15 <- st_read( paste0(dir_raw,"/AreasUrbanizadasDoBrasil_2015_Concentracoes_Urbanas_de_100000_a_300000_habitantes.shp"),
                           options = "ENCODING=UTF-8")
  }

# # do they come with the same projection? Yes
#
#   st_crs(ACP_urban_05) == st_crs(cemk_urban_05)
#   st_crs(ACP_urban_05) == st_crs(cost_urban_05)
#
#   original_crs <- st_crs(mais_urban_15)



##### 4.2 Pile them up by year -------------------

# Make sure all data sets have the same columns (in the same order)

if(year==2005){
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
        }


if(year==2015){

  mais_urban_15 <- mais_urban_15 |>
                   dplyr::mutate(OBJECTID = NULL,
                                 UF = substring(CodConcUrb, 1, 2))


  ate_urban_15 <- ate_urban_15 |>
                  dplyr::rename(NomeConcUr = NomConcUrb) |>
                  dplyr::mutate(FID_1 = NA)


    # if  they come with the same projection, reorder and rbind
   if( st_crs(mais_urban_15) == st_crs(ate_urban_15)){
     col_order <- names(mais_urban_15)
     ate_urban_15 <- dplyr::select(ate_urban_15, all_of(col_order))

     temp_sf <- rbind(ate_urban_15,mais_urban_15)
   } else{stop('cannot rbind 2015 data sets')}
}



##### 4.3 Data cleaning -------------------

# Rename and reoder columns

if(year==2005){
  temp_sf <- dplyr::select(temp_sf,
                          code_urb = GEOC_URB,
                          pop_2005 = POP_2005,
                          density = Tipo,
                          code_muni = GEOCODIGO,
                          name_muni = NOME_MUNIC,
                          code_acp = COD_ACP,
                          name_acp = ACP,
                          abbrev_state = UF,
                          dataset = dataset,
                          geometry = geometry
                          )
  }

if(year==2015){
  temp_sf <- dplyr::select(temp_sf,
                          fid_1 = FID_1,
                          code_muni = CodConcUrb,
                          name_muni = NomeConcUr,
                          code_state = UF,
                          type = Tipo,
                          density = Densidade,
                          area_km2 = AREA_GEO,
                          geometry = geometry
                          )
  }



# convert codes to numeric
# convert codes to character


# remove Z dimension of spatial data
temp_sf <- remove_z_dimension(temp_sf)

# Add state info
temp_sf <- add_state_info(temp_sf, column = 'code_muni')

# Add region info
temp_sf <- add_region_info(temp_sf, column = 'code_muni')

# Use UTF-8 encoding in all character columns
temp_sf <- use_encoding_utf8(temp_sf)

# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
temp_sf <- harmonize_projection(temp_sf)

# convert to MULTIPOLYGON
temp_sf <- to_multipolygon(temp_sf)

# Make any invalid geometry valid # st_is_valid( sf)
temp_sf <- fix_topoly(temp_sf)

# reoder columns
  if(year == 2015){
    col_order <- c("fid_1", "code_muni", 'name_muni', "code_state",  "name_state",
                   "abbrev_state", "code_region", "name_region", "type", "density",
                   "area_km2", "geometry")
  }
  if(year == 2005){
    col_order <- c("code_urb", "pop_2005", "density", "code_muni", "name_muni", "code_acp", "name_acp",
                   "code_state", "abbrev_state", "name_state", "dataset", "geometry")
    }

  temp_sf <- dplyr::select(temp_sf, all_of(col_order))



###### 6. generate a lighter version of the dataset with simplified borders -----------------
# skip this step if the dataset is made of points, regular spatial grids or rater data

  # simplify
  temp_sf_simplified <- simplify_temp_sf(temp_sf, tolerance = 50)

##### 4.4 Save  -------------------

# Save cleaned sf in the cleaned directory
  sf::st_write(temp_sf, dsn= paste0(dest_dir,"/urban_area_", year, ".gpkg"))
  sf::st_write(temp_sf_simplified, dsn= paste0(dest_dir,"/urban_area_", year, "_simplified.gpkg"))


