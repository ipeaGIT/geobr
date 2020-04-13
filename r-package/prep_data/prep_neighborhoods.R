### Create a neighborhood data set from Census Tract data ------------

### Libraries (use any library as necessary)

library(geobr)
library(magrittr)
library(sf)
library(dplyr)
library(data.table)
library(mapview)
library(sfheaders)
library(furrr)
library(future)
library(pbapply)



####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")



# set data year
update <- 2010


# Create Directory to save clean sf.rds files
destdir <- paste0("./neighborhood/", update)
dir.create(destdir, recursive =T)


##### 1. read original census tract data -----------------------------

tracts <- geobr::read_census_tract(code_tract = 'all', year= update, simplified = F)
head(tracts)



##### 2. pre-process and clean data -----------------------------

# convert all factor columns to character
tracts <- tracts %>% mutate_if(is.factor, function(x){ x %>% as.character() } )

# cast all cities as MULTIPOLYGON
tracts <- st_cast(tracts, to="MULTIPOLYGON")

# convert all factor columns to character
tracts <- tracts %>% mutate_if(is.factor, function(x){ x %>% as.character() } )









##### 3. Function to get neighborhood -----------------------------


get_neibhd <- function(codemuni) {

#  codemuni <- all_muni[1]

  # subset muni
  muni <- subset(nei, code_muni == codemuni)

  # dissolve borders to get neighborhoods
  temp <- muni %>% group_by(  code_muni,
                              name_muni,
                              name_neighborhood,
                              code_neighborhood,
                              # code_district,
                              # name_district,
                              code_state
                            ) %>% summarize()


  # return neighborhoods of muni
  return(temp)

  # setDT(n)
  # a <- n[, .(geom = st_union(geom)), by= .(code_muni, code_neighborhood)]
  # a <- st_as_sf(a)
  # st_crs(a) <- 4674
  #
  # plot(a)
}



##### 3. Apply function in parallel -----------------------------

# get all municipalities with neighborhood info
nei <- subset(tracts, !is.na(name_neighborhood))
all_muni <- unique(nei$code_muni)

# # single core
 temp_list <- pbapply::pblapply(X= all_muni, FUN = get_neibhd)

# # in parellel
# future::plan(future::multiprocess)
# system.time( temp_list <- furrr::future_map(.x=all_muni[1:4], .f = get_neibhd, .progress = T) )

# pile all cities up
temp_sf <- do.call('rbind', temp_list)
beepr::beep()
head(temp_sf)


##### Brasila is a special case -----------------------------

df <- subset(tracts, code_muni == '5300108')

# dissolve bairros (regioes administrativas
df_RAS <- df %>% group_by(
                    code_muni,
                    name_muni,
                    # name_neighborhood,
                    # code_neighborhood,
                    code_subdistrict,
                    name_subdistrict,
                    code_state
                  ) %>% summarize()


# Harmonize columns
temp_sf$code_subdistrict <- NA
temp_sf$name_subdistrict <- NA

df_RAS$name_neighborhood <- NA
df_RAS$code_neighborhood <- NA

# reorder columns
setcolorder(temp_sf, c("code_muni", "name_muni",
                      "name_neighborhood", "code_neighborhood",
                      "code_subdistrict", "name_subdistrict",
                      "code_state", "geom"))

setcolorder(df_RAS, c("code_muni", "name_muni",
                      "name_neighborhood", "code_neighborhood",
                      "code_subdistrict", "name_subdistrict",
                      "code_state", "geom"))


brazil_neibhd <- rbind(temp_sf, df_RAS)
head(brazil_neibhd)



###### 7. generate a lighter version of the dataset with simplified borders -----------------
# skip this step if the dataset is made of points, regular spatial grids or rater data

# simplify
brazil_neibhd_simp <- st_transform(brazil_neibhd, crs=3857) %>%
  sf::st_simplify(preserveTopology = T, dTolerance = 100) %>% st_transform(crs=4674)

as.numeric(object.size(brazil_neibhd_simp)) / as.numeric(object.size(brazil_neibhd))




###### 8. Clean data set and save it in geopackage format-----------------

# save original and simplified datasets
sf::st_write(brazil_neibhd, dsn= paste0(destdir, "/neighborhoods_", update, ".gpkg"))
sf::st_write(brazil_neibhd_simp, dsn= paste0(destdir, "/neighborhoods_", update,"_simplified", ".gpkg"))


