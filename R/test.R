#### testing functions of mapsbrazil





### 1. read_uf -------------------------



# 1.1 Allow for uf 
a <- read_uf(cod_uf = "SP")
plot(a)



### 2. read_municipio -------------------------

a <- read_municipio(cod_mun=1200179)
plot(a)





### 3. read_mesorregiao -------------------------

a <- read_mesorregiao(cod_mun=1200179)
plot(a)
