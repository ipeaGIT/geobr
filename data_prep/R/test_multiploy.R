library(geobr)
library(data.table)


a <- geobr::read_municipality(year = 2000)
b <- geobr::read_municipality(year = 2001 )

unique(b$code_state)


a1 <- geobr::read_municipality(year = 2000, code_muni = 11)
a5 <- geobr::read_municipality(year = 2000, code_muni = 15)


sapply(a1, class)
sapply(a5, class)



a11 <- sf::st_cast(a1, "MULTIPOLYGON")
sapply(a11, class)


rbindlist(list(a11, a5))











aa <- subset(temp_sf, code_muni == 1508308)

