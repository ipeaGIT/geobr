# log history of geobr package development

-------------------------------------------------------
# geobr v1.0 (2019-30-07)

* Launch of **geobr** v1.0 on [CRAN](https://cran.r-project.org/web/packages/geobr/index.html) with the following data sets:
  * Country
  * States
  * Regions
  * Meso regions
  * Micro regions
  * Municipalities
  * Census weighting areas
  * Census tracts
  * Statistical Grid 

-------------------------------------------------------
# geobr dev1.0.1 

* closes issue #42 (2019-08-05)
  * Shows a single download progress bar when `*_code="all"`. 
  * This fixes the output of vignette

* New data sets/functions
  * New Function `read_indigenous_land` to read official data of indigenous lands of all ethnicities according to stage of demarcation (2019-09-04).
  * New Function `read_disaster_risk_area` to read official data of areas exposed to risks of geodynamic and hydro-meteorological disasters capable of triggering landslides and floods (added in 2019-09-24).
  * New Function `read_biomes` to read official data of polygons of all of all biomes present in Brazilian territory(added in 2019-09-24).


