library(arrow)
library(dplyr)
library(sf)
library(mapview)
library(sfheaders)

dir_coord <- 'R:/Dropbox/git/import_cnefe/data/2022/coordenadas/parquet/'
dir_addrs <- 'R:/Dropbox/git/import_cnefe/data/2022/arquivos/parquet/'



#coord <- arrow::read_parquet(file = paste0(dir_coord,'53_DF.parquet'))
arqui <- arrow::read_parquet(file = paste0(dir_addrs,'53_DF.parquet'))


c <- subset(arqui, cep == 70355030) # 71665015
c

c <- sfheaders::sf_point(obj = c, x='lon', y='lat', keep = T)

st_crs(c) <- 4674
plot(c)

mapview(c)

# build polygons with {concaveman}
temp <- concaveman::concaveman(c)
plot(temp)


n <- unique(arqui$desc_localidade)
n <- sort(n)

get_neig_poly <- function(name){ # name = 'ASA SUL'


  c <- filter(arqui, desc_localidade == name)
  c <- sfheaders::sf_point(obj = c, x='lon', y='lat', keep = F)
  st_crs(c) <- 4674
  # mapview(c)

  temp <- concaveman::concaveman(c)
  # mapview(temp)
 # saveRDS(temp, file = paste0('./test_cnefe/', name, '.rds'))
  sf::st_write(temp, dsn = paste0('./test_cnefe/', name, '.gpkg'),quiet = T)

}

pbapply::pblapply(X = n, FUN = get_neig_poly)

