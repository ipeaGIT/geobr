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
tracts <- use_encoding_utf8(tracts)


# cast all cities as MULTIPOLYGON
tracts <- st_cast(tracts, to="MULTIPOLYGON")



# Prepare Parallel processing using future.apply
future::plan(future::multiprocess)


##### Part 1, get cities with neighborhood info -----------------------------


# get all municipalities with neighborhood info
nei <- subset(tracts, !is.na(name_neighborhood))
all_muni_part1 <- unique(nei$code_muni)


# Dissolve borders in Parallel
temp_list1 <- furrr::future_map(.x = all_muni_part1, .progress = TRUE,
                                .f = function(X){dissolve_polygons( mysf = subset(nei, code_muni== X),
                                                                    group_column = 'code_neighborhood')}
                                )


# pille them up
part_1_neighborhood <- do.call('rbind', temp_list1)
# mapview(part_1_neighborhood)

# recover info from other columns
temp_nei <- select(nei, code_muni, name_muni,
                                   name_neighborhood,
                                   code_neighborhood,
                                   code_subdistrict,
                                   name_subdistrict,
                                   code_district,
                                   name_district
                                   )
temp_nei$geom <- NULL
temp_nei <- unique(temp_nei)


part_1_neighborhood_final <- left_join(part_1_neighborhood, temp_nei)
part_1_neighborhood_final$reference_geom <- 'neighborhood'
# mapview(part_1_neighborhood_final, platform='leafgl')


# Remove municipalities with few observationa that cover the whole municipality
part_1_neighborhood_final %<>%
  group_by(code_muni) %>%
  mutate(count=n())  %>%
  ungroup()

table(part_1_neighborhood_final$count)
part_1_neighborhood_final <- subset(part_1_neighborhood_final, count > 1)
part_1_neighborhood_final$count <- NULL






##### Part 2, get cities with  subdistrict info only -----------------------------

# get all municipalities with neighborhood info
df_subdistrict <- subset(tracts, is.na(name_neighborhood) & !is.na(name_subdistrict))
df_subdistrict <- subset(df_subdistrict, !(code_muni %in% all_muni_part1))
all_muni_part <- unique(df_subdistrict$code_muni)


# Dissolve borders in Parallel
temp_list2 <- furrr::future_map(.x = all_muni_part2, .progress = TRUE,
                               .f = function(X){dissolve_polygons( mysf = subset(df_subdistrict, code_muni== X),
                                                                   group_column = 'code_subdistrict')}
                                )




# pille them up
part_2_subdistrict <- do.call('rbind', temp_list2)
# mapview(part_2_subdistrict)

# recover info from other columns
temp_subdistrict <- select(df_subdistrict, code_muni, name_muni,
                   # name_neighborhood,
                   # code_neighborhood,
                   code_subdistrict,
                   name_subdistrict,
                   code_district,
                   name_district
                   )

temp_subdistrict$geom <- NULL
temp_subdistrict <- unique(temp_subdistrict)


part_2_subdistrict_final <- left_join(part_2_subdistrict, temp_subdistrict)
part_2_subdistrict_final$reference_geom <- 'subdistrict'
# mapview(part_2_subdistrict_final, platform='leafgl')

        # 66666666666666666666666666666
            # bbbb <- subset(part_2_subdistrict_final, code_muni == 1100205)
            # mapview(bbbb, platform='leafgl')
            #
            # aaaa <- subset(tracts, code_muni == 1100205)
            # mapview(aaaa, platform='leafgl')



# Remove municipalities with few observationa that cover the whole municipality
part_2_subdistrict_final %<>%
  group_by(code_muni) %>%
  mutate(count=n())  %>%
  ungroup()

table(part_2_subdistrict_final$count)
part_2_subdistrict_final <- subset(part_2_subdistrict_final, count > 5)
part_2_subdistrict_final$count <- NULL

# mapview(part_2_subdistrict_final, platform='leafgl')




##### Part 3. get cities with  district info only -----------------------------

# get all municipalities with neighborhood info
df_district <- subset(tracts, is.na(name_neighborhood) & is.na(name_subdistrict) & !is.na(name_district))
df_district <- subset(df_district, !(code_muni %in% all_muni_part1))
df_district <- subset(df_district, !(code_muni %in% all_muni_part2))
all_muni_part3 <- unique(df_district$code_muni)


# Dissolve borders in Parallel
temp_list3 <- furrr::future_map(.x = all_muni_part3, .progress = TRUE,
                               .f = function(X){dissolve_polygons( mysf = subset(df_district, code_muni== X),
                                                                   group_column = 'code_district')}
                               )



# pille them up
part_3_district <- do.call('rbind', temp_list3)
# mapview(part_3_district)

# recover info from other columns
temp_district <- select(df_district, code_muni, name_muni,
                           # name_neighborhood,
                           # code_neighborhood,
                           # code_subdistrict,
                           # name_subdistrict,
                           code_district,
                           name_district
                           )
temp_district$geom <- NULL
temp_district <- unique(temp_district)


part_3_district_final <- left_join(part_3_district, temp_district)
part_3_district_final$reference_geom <- 'district'



# Remove municipalities with few observationa that cover the whole municipality
part_3_district_final %<>%
  group_by(code_muni) %>%
  mutate(count=n())  %>%
  ungroup()

table(part_3_district_final$count)
part_3_district_final <- subset(part_3_district_final, count > 15)
part_3_district_final$count <- NULL


# mapview(part_3_district_final, platform='leafgl')



##### 6. Harmonize columns -----------------------------

# make sure data parts are mutually exclusive
intersect(part_1_neighborhood_final$code_muni, part_2_subdistrict_final$code_muni)
intersect(part_1_neighborhood_final$code_muni, part_3_district_final$code_muni)
intersect(part_3_district_final$code_muni, part_2_subdistrict_final$code_muni)


names(part_1_neighborhood_final)
names(part_2_subdistrict_final)
names(part_3_district_final)

ncol(part_1_neighborhood_final)
ncol(part_2_subdistrict_final)
ncol(part_3_district_final)

# subdistrict
part_2_subdistrict_final$name_neighborhood <- NA
part_2_subdistrict_final$code_neighborhood <- NA

# district
part_3_district_final$name_neighborhood <- NA
part_3_district_final$code_neighborhood <- NA
part_3_district_final$code_subdistrict <- NA
part_3_district_final$name_subdistrict <- NA


# reorder columns
setcolorder(part_1_neighborhood_final, c("code_muni", "name_muni",
                                         "name_neighborhood", "code_neighborhood",
                                         "code_subdistrict", "name_subdistrict",
                                         "code_district", "name_district",
                                         "reference_geom", "geometry"))


setcolorder(part_2_subdistrict_final, c("code_muni", "name_muni",
                                        "name_neighborhood", "code_neighborhood",
                                        "code_subdistrict", "name_subdistrict",
                                        "code_district", "name_district",
                                        "reference_geom", "geometry"))

setcolorder(part_3_district_final, c("code_muni", "name_muni",
                                     "name_neighborhood", "code_neighborhood",
                                     "code_subdistrict", "name_subdistrict",
                                     "code_district", "name_district",
                                     "reference_geom", "geometry"))



# pile them up
brazil <- rbind(part_1_neighborhood_final, part_2_subdistrict_final, part_3_district_final)
head(brazil)
nrow(brazil)


### Add State Code and Abbreviation
brazil <- add_state_info(brazil)
setcolorder(brazil, c("code_muni", "name_muni",
                                   "name_neighborhood", "code_neighborhood",
                                   "code_subdistrict", "name_subdistrict",
                                   "code_district", "name_district",
                                   "code_state", "abbrev_state",
                                   "reference_geom", "geometry"))
head(brazil)


# Remove municipalities with single observation that cover the whole municipality
brazil %<>%
  group_by(code_muni) %>%
  mutate(count=n())  %>%
  ungroup()

table(brazil$count)
brazil <- subset(brazil, count > 1)
brazil$count <- NULL




###### Harmonize spatial projection -----------------

brazil <- harmonize_projection(brazil)


# cast all cities as MULTIPOLYGON
brazil <- st_cast(brazil, to="MULTIPOLYGON")


###### 7. generate a lighter version of the dataset with simplified borders -----------------
# skip this step if the dataset is made of points, regular spatial grids or rater data

# simplify
brazil_simp <- simplify_temp_sf(brazil, tolerance=10)


as.numeric(object.size(brazil_simp)) / as.numeric(object.size(brazil))



# mapview(brazil_simp, platform='leafgl')




###### 8. Clean data set and save it in geopackage format-----------------

# save original and simplified datasets
sf::st_write(brazil, dsn= paste0(destdir, "/neighborhoods_", update, ".gpkg"))
sf::st_write(brazil_simp, dsn= paste0(destdir, "/neighborhoods_", update,"_simplified", ".gpkg"))


