#### testing functions of mapsbrazil





### 1. read_uf -------------------------



# 1.1 Allow for uf 
a <- read_uf( )
plot(a)

head(a)


### 2. read_municipio -------------------------

a <- read_municipio(cod_mun=1200179, year=2017)
plot(a)

head(a)



### 3. read_mesorregiao -------------------------

a <- read_mesorregiao(cod_mun=1200179)
plot(a)



a <- readRDS("L:\\\\# DIRUR #\\ASMEQ\\pacoteR_shapefilesBR\\data\\meso_regiao//ME_2014//11ME.rds")
head(a)
