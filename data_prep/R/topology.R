

library(mapview)
library(geobr)
mapviewOptions(platform = 'mapdeck')

geobr::lookup_muni(name_muni = 'campinas')
df <- read_census_tract(code_tract = 3509502, simplified = F)
df <- subset(df, code_muni >1)

mapview(df)


df <- sf::st_make_valid(df)
df <- sf::st_buffer(df, dist = -1)

mapview(df)
