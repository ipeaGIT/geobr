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


# arquipelago de Trindade e Martim Vaz
# trindade <- st_as_sf(
#   data.frame(lon = -29.3304281, lat = -20.503874),
#   coords = c("lon", "lat"),
#   crs = 4674
# )
#
# mapview::mapview(br) + costa + br_offcoast + trindade
# # mapview::mapview(trindade) + br

bb <- st_bbox(br_offcoast)
strip <- st_as_sfc(st_bbox(c(xmin = bb[["xmin"]], xmax = -28,
                             ymin = bb[["ymin"]], ymax = bb[["ymax"]]),
                           crs = st_crs(br_offcoast)))

big_chunk <- st_union(br_offcoast, strip)

# mapview::mapview(br) + costa + br_offcoast + big_chunk

# remove country and costa from chunk

br_offcoast2 <- duckspatial::ddbs_difference(
  x = big_chunk,
  y = br_buffer) |>
  duckspatial::ddbs_collect()


br_offcoast2 <- duckspatial::ddbs_difference(
  x = br_offcoast2,
  y = costa) |>
  duckspatial::ddbs_collect()

# mapview::mapview(br) + costa + br_offcoast2 + br_offcoast + big_chunk + br_offcoast3

br_offcoast3 <- duckspatial::ddbs_union(br_offcoast, br_offcoast2) |>
  duckspatial::ddbs_collect() |>
  sfheaders::sf_remove_holes()

# mapview::mapview(br) + br_offcoast + br_offcoast2 + br_offcoast3


class(br_offcoast3) <- setdiff(class(br_offcoast3), c("tbl_df", "tbl"))


duckspatial::ddbs_write_dataset(
  data = br_offcoast3,
  path = "./inst/extdata/br_offcoast.parquet",
  crs = "EPSG:4674",
  overwrite = T,
  parquet_compression = "SNAPPY",
  quiet = TRUE
)
