
### Create a neighborhood data set from Census Tract data ------------

library(geobr)
library(magrittr)
library(sf)
library(dplyr)
library(data.table)
library(mapview)
library(sfheaders)

##### 1. read original census tract data -----------------------------

tracts <- read_census_tract(code_tract = 'all', year=2010, simplified = F)
head(tracts)


# keep only observations with neighborhood info
nei <- subset(tracts, !is.na(name_neighborhood))



##### 2. Function to get neighborhood -----------------------------


get_neibhd <- function(codemuni) {
  # subset muni
  n <- subset(nei, code_muni == codemuni)


  # dissolve borders to get neighborhoods
  temp <- n %>%
    group_by(
      zone,
      code_muni,
      name_muni,
      name_neighborhood,
      code_neighborhood,
      code_district,
      name_district,
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

# get all municipalities
all_muni <- unique(nei$code_muni)

# # single core
# temp_list <- lapply(X= all_muni[1:4], FUN = get_neibhd)

# in parellel
future::plan(future::multiprocess)
temp_list <- future.apply::future_lapply(X = all_muni, FUN=get_neibhd, future.packages=c('sf', 'dplyr'))


# pile all cities up
temp_sf <- do.call('rbind', temp_list)



##### 4. Save the data  -----------------------------
