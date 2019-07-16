## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----  message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----
library(devtools)
library(digest)

# devtools::install_github("ipeaGIT/geobr")
library(geobr)

library(spdep)
library(spgwr)
library(RColorBrewer)
library(readxl)
library(dplyr)
library(ggplot2)
library(rio)

adh <- rio::import("http://atlasbrasil.org.br/2013/data/rawData/atlas2013_dadosbrutos_pt.xlsx",
                   which = "MUN 91-00-10")

adh <- adh %>%
  dplyr::select(ANO,UF,Codmun7,
         E_ANOSESTUDO,FECTOT,
         RAZDEP,IDHM)

adh_2010 <- adh %>%
  filter(ANO==2010)

shape <- read_municipality(code_muni = "all", year = 2010)

shape <- shape %>%
  filter(substr(code_muni,1,2)=="11") %>%
  left_join(adh_2010,by = c("code_muni"="Codmun7"))


brks <- seq(from = range(shape$FECTOT)[1],
            to = range(shape$FECTOT)[2],
            length.out =5)

ggplot(shape) +
  geom_sf(aes(fill=FECTOT)) +
  scale_fill_gradient(high = "red",
                      low= "grey90", name="Fecundity rate",
                       labels = round(brks,2),
                       breaks = brks) +
  labs(title = "Fecundity rate in Rondônia-Brazil (2010)")


## ----  message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----

adh <- rio::import("http://atlasbrasil.org.br/2013/data/rawData/atlas2013_dadosbrutos_pt.xlsx",
                   which = "MUN 91-00-10")


adh <- adh %>%
  dplyr::select(ANO,UF,Codmun7,
         E_ANOSESTUDO,FECTOT,
         RAZDEP,IDHM)

adh_2010 <- adh %>%
  filter(ANO==2010)

shape <- read_municipality(code_muni = 11, year = 2010)

shape <- shape %>%
  left_join(adh_2010,by = c("code_muni"="Codmun7"))


brks <- seq(from = range(shape$E_ANOSESTUDO)[1],
            to = range(shape$E_ANOSESTUDO)[2],
            length.out =5)

ggplot(shape) +
  geom_sf(aes(fill=E_ANOSESTUDO)) +
  scale_fill_gradient(high = "red",
                      low= "grey90", name="Years of schooling",
                       labels = round(brks,2),
                       breaks = brks) +
  labs(title = "Education in Rondônia-Brazil (2010)")


## ----message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----
bandwidth <- gwr.sel(E_ANOSESTUDO ~ FECTOT, data=as(shape, "Spatial"))

gwr_model <- gwr(E_ANOSESTUDO ~ FECTOT, 
                 data=as(shape, "Spatial"),
                 bandwidth=bandwidth, 
                 hatmatrix=TRUE)

ols_model <- lm(E_ANOSESTUDO ~ FECTOT, 
                data=shape)

shape$residuals_ols <- ols_model$residuals
shape$residuals_gwr <- gwr_model$SDF$pred-shape$E_ANOSESTUDO

model_gwr_data <- gwr_model$SDF@data
model_gwr_data$code_muni <- shape$code_muni

model_gwr_data <- model_gwr_data %>% 
  dplyr::select(code_muni,X.Intercept.,FECTOT)
names(model_gwr_data) <- c("code_muni","Intercept","Slope")
shape <- shape %>%
  left_join(model_gwr_data,by = "code_muni")

quantile(shape$Slope)
bks <- seq(-2.5,0,by=.5)

ggplot(shape) +
  geom_sf(aes(fill=Slope)) +
  scale_fill_gradient(high = "grey90",
                      low= "red", name="Slope",
                       labels = round(bks,2),
                       breaks = bks) +
  labs(title = "Slope coefficient")

## ----message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----

quantile(shape$Intercept)
bks <- seq(10,15,by=1)

ggplot(shape) +
  geom_sf(aes(fill=Intercept)) +
  scale_fill_gradient(high = "red",
                      low= "grey90", name="Intercept",
                       labels = round(bks,2),
                       breaks = bks) +
  labs(title = "Intercept coefficient")


## ----message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----
nb <- poly2nb(as(shape, "Spatial"))
lw <- nb2listw(nb)


quantile(shape$residuals_ols)
bks <- seq(from = -1.5,
            to = 1.5,
            length.out =5)

ggplot(shape) +
  geom_sf(aes(fill=residuals_ols)) +
  scale_fill_gradient2(high = "blue", low= "lightcoral",
                       mid = "grey90", name="Residuals",
                      labels = round(bks,2),
                      breaks = bks) +
  labs(title = "Residuals distribuition") +
  labs(title = "OLS residuals")



moran.mc(shape$residuals_ols,
         lw, 999)

## ----message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----

qqnorm(shape$residuals_ols,col=2,pch = 20,
       main = "OLS residuals QQ-Plot")
qqline(shape$residuals_ols)
shapiro.test(shape$residuals_ols)


## ----message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----

quantile(shape$residuals_gwr)
brk <- seq(from = -1,
            to = 1,
            length.out =5)


ggplot(shape) +
  geom_sf(aes(fill=residuals_gwr)) +
  scale_fill_gradient2(high = "blue", mid= "grey90",
                       low = "lightcoral", 
                       name="Residuals",
                       labels = round(brk,2),
                       breaks = brks) +
  labs(title = "GWR residuals")

moran.mc(shape$residuals_gwr,
         lw, 999)


## ----message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----

qqnorm(shape$residuals_gwr,col=2,pch = 20,
       main = "GWR residuals QQ-Plot")
qqline(shape$residuals_gwr)
shapiro.test(shape$residuals_gwr)


