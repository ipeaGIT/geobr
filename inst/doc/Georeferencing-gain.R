## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----  message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----
library(spdep)
library(spgwr)
library(RColorBrewer)
library(geobr)
library(readxl)
library(dplyr)
library(ggplot2)


adh <- read_excel("atlas2013_dadosbrutos_pt.xlsx",sheet = "MUN 91-00-10")

adh <- adh %>%
  dplyr::select(ANO,UF,Codmun7,
         E_ANOSESTUDO,FECTOT,
         RAZDEP,IDHM)

adh_2010 <- adh %>%
  filter(ANO==2010)

shape <- read_municipality(cod_muni = "all", year = 2010)

shape_11 <- shape %>%
  filter(substr(code_muni,1,2)=="11") %>%
  left_join(adh_2010,by = c("code_muni"="Codmun7"))


brks <- seq(from = range(shape_11$FECTOT)[1],
            to = range(shape_11$FECTOT)[2],
            length.out =5)

ggplot(shape_11) +
  geom_sf(aes(fill=FECTOT)) +
  scale_fill_gradient(high = "red",
                      low= "grey90", name="Fecundity rate",
                       labels = round(brks,2),
                       breaks = brks) +
  labs(title = "Fecundity rate in Rondônia-Brazil (2010)")


## ----  message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----
library(spdep)
library(spgwr)
library(RColorBrewer)
library(geobr)
library(readxl)
library(dplyr)
library(ggplot2)


adh <- read_excel("C:\\Users\\Igor\\Documents\\geo_add\\atlas2013_dadosbrutos_pt.xlsx",
                  sheet = "MUN 91-00-10")

adh <- adh %>%
  dplyr::select(ANO,UF,Codmun7,
         E_ANOSESTUDO,FECTOT,
         RAZDEP,IDHM)

adh_2010 <- adh %>%
  filter(ANO==2010)

shape <- read_municipality(cod_muni = "all", year = 2010)

shape_11 <- shape %>%
  filter(substr(code_muni,1,2)=="11") %>%
  left_join(adh_2010,by = c("code_muni"="Codmun7"))


brks <- seq(from = range(shape_11$E_ANOSESTUDO)[1],
            to = range(shape_11$E_ANOSESTUDO)[2],
            length.out =5)

ggplot(shape_11) +
  geom_sf(aes(fill=E_ANOSESTUDO)) +
  scale_fill_gradient(high = "red",
                      low= "grey90", name="Tempo de estudo",
                       labels = round(brks,2),
                       breaks = brks) +
  labs(title = "Tempo de estudo em Rondônia-Brasil (2010)")


## ----message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----
col.bw <- gwr.sel(E_ANOSESTUDO ~ FECTOT, data=as(shape_11, "Spatial"))

gwr_model <- gwr(E_ANOSESTUDO ~ FECTOT, data=as(shape_11, "Spatial"),
                 bandwidth=col.bw, hatmatrix=TRUE)

ols_model <- lm(E_ANOSESTUDO ~ FECTOT, data=shape_11)

shape_11$residuals_ols <- ols_model$residuals
shape_11$residuals_gwr <- gwr_model$SDF$pred-shape_11$E_ANOSESTUDO

model_gwr_data <- gwr_model$SDF@data
model_gwr_data$code_muni <- shape_11$code_muni

model_gwr_data <- model_gwr_data %>% dplyr::select(code_muni,X.Intercept.,FECTOT)
names(model_gwr_data) <- c("code_muni","Intercept","Slope")
shape_11 <- shape_11 %>%
  left_join(model_gwr_data,by = "code_muni")


quantile(shape_11$Slope)
brks <- seq(-2.5,0,by=.5)

ggplot(shape_11) +
  geom_sf(aes(fill=Slope)) +
  scale_fill_gradient(high = "grey90",
                      low= "red", name="Slope",
                       labels = round(brks,2),
                       breaks = brks) +
  labs(title = "Slope coefficient")

## ----message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----

quantile(shape_11$Intercept)
brks <- seq(10,15,by=1)

ggplot(shape_11) +
  geom_sf(aes(fill=Intercept)) +
  scale_fill_gradient(high = "red",
                      low= "grey90", name="Intercept",
                       labels = round(brks,2),
                       breaks = brks) +
  labs(title = "Intercept coefficient")


## ----message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----
nb <- poly2nb(as(shape_11, "Spatial"))
lw <- nb2listw(nb)


quantile(shape_11$residuals_ols)
brks <- seq(from = -1.5,
            to = 1.5,
            length.out =5)

ggplot(shape_11) +
  geom_sf(aes(fill=residuals_ols)) +
  scale_fill_gradient2(high = "blue", low= "lightcoral", mid = "grey90", name="Residuals",
                      labels = round(brks,2),
                      breaks = brks) +
  labs(title = "Residuals distribuition") +
  labs(title = "OLS residuals")



moran.mc(shape_11$residuals_ols,
         lw, 999)

## ----message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----

qqnorm(shape_11$residuals_ols,col=2,pch = 20,main = "OLS residuals QQ-Plot")
qqline(shape_11$residuals_ols)
shapiro.test(shape_11$residuals_ols)


## ----message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----

quantile(shape_11$residuals_gwr)
brks <- seq(from = -1,
            to = 1,
            length.out =5)


ggplot(shape_11) +
  geom_sf(aes(fill=residuals_gwr)) +
  scale_fill_gradient2(high = "blue", mid= "grey90",low = "lightcoral", name="Residuals",
                       labels = round(brks,2),
                       breaks = brks) +
  labs(title = "GWR residuals")

moran.mc(shape_11$residuals_gwr,
         lw, 999)


## ----message=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----

qqnorm(shape_11$residuals_gwr,col=2,pch = 20,main = "GWR residuals QQ-Plot")
qqline(shape_11$residuals_gwr)
shapiro.test(shape_11$residuals_gwr)


