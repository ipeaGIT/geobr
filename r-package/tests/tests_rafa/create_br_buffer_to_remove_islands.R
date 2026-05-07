library(dplyr)
library(sf)
library(geoarrow)
library(arrow)

br <- read_country(year=2022, simplified = TRUE)
br$year <- NULL

br_buffer <- br |>
  sf::st_simplify(preserveTopology = T, dTolerance = 10000) |>
  st_transform(crs = 5880) |>   # SIRGAS 2000 / Brazil Polyconic
  st_buffer(dist = 20000) |> # 20 Km
  st_transform(4674)

arrow::write_parquet(br_buffer, "br_buffer.parquet")
# mapview(br) + br_buffer


costa <- geobr::read_biomes(year = 2019) |>
  filter(name_biome=="Sistema Costeiro")


br_offcoast <- sf::st_difference(costa, br_buffer) |>
  sf::st_simplify(preserveTopology = T, dTolerance = 1000)


mapview(br) + costa + br_offcoast

arrow::write_parquet(br_offcoast, "br_offcoast.parquet")
