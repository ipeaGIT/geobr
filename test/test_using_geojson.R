
# tests using geojson


sss <- read_state(year=2018, code_state = "all")
sf::st_write(sss, dsn = "C:/Users/r1701707/Desktop/a/country_.geojson")
readr::write_rds(sss, path = "C:/Users/r1701707/Desktop/a/country_.rds", compress="gz" )


test <- st_read("C:/Users/r1701707/Desktop/a/country_.geojson")
