library(dplyr)
library(sf)
library(geoarrow)
library(arrow)
library(duckspatial)

br <- read_country(year=2022, simplified = TRUE)
br$year <- NULL

br_buffer <- br |>
  sf::st_simplify(preserveTopology = T, dTolerance = 10000) |>
  st_transform(crs = 5880) |>   # SIRGAS 2000 / Brazil Polyconic
  st_buffer(dist = 20000) |> # 20 Km
  st_transform(4674)

# arrow::write_parquet(br_buffer, "br_buffer.parquet")
# mapview(br) + br_buffer


costa <- geobr::read_biomes(year = 2019) |>
  filter(name_biome=="Sistema Costeiro")

st_crs(costa) <- 4674

br_offcoast <- sf::st_difference(costa, br_buffer) |>
  sf::st_simplify(preserveTopology = T, dTolerance = 1000) |>
  select(year)


mapview::mapview(br) + costa + br_offcoast

class(br_offcoast) <- setdiff(class(br_offcoast), c("tbl_df", "tbl"))


duckspatial::ddbs_write_dataset(
  data = br_offcoast,
  path = "./inst/extdata/br_offcoast.parquet",
  crs = "EPSG:4674",
  overwrite = T,
  parquet_compression = "SNAPPY",
  quiet = TRUE
)
