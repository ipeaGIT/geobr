

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









library(sf)
library(geobr)
library(dplyr)

biomes <- read_biomes(
  year = 2019,
  simplified = FALSE,
  showProgress = FALSE
)

fix_topology_brute <- function(poly_sf){ # poly_sf = biomes

  # check which polys are valid
  is_valid <- sf::st_is_valid(poly_sf)

  # keep hold of valid polys
  poly_valid <- poly_sf[is_valid, ]

  # let's work on invalid ones
  poly_invalid <- poly_sf[!is_valid, ]

  # detect problematic edges
  problem_edges <- st_is_valid(poly_invalid, reason=TRUE)
  problem_edges <- sub(".*:\\D*(\\d+).*", "\\1", problem_edges) |> as.numeric()

  # convert to point
  poly_invalid2 <- sf::st_cast(poly_invalid, "POINT") |> suppressWarnings()

  # drop problem edges
  poly_invalid2 <- poly_invalid2[-c(problem_edges), ]

  poly_invalid2 <- sf::st_combine(poly_invalid2)
  poly_invalid2 <- sf::st_cast(poly_invalid2, "POLYGON")
  poly_invalid2 <- sf::st_sf(poly_invalid2)

  poly_invalid2 <- rename(poly_invalid2, geom = poly_invalid2)
  poly_invalid2$code_biome <- 1
  poly_invalid2$name_biome <- 'Amazônia'
  poly_invalid2$year <- 2019
  poly_invalid2 <- dplyr::select(poly_invalid2, names(poly_valid))

  manchas_consertadas <- rbind(poly_valid, poly_invalid2)
  manchas_consertadas <- sf::st_union(manchas_consertadas)
  manchas_consertadas <- sf::st_make_valid(manchas_consertadas)

  return(manchas_consertadas)
}
