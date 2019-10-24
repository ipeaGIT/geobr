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
# geobr dev1.1

* closes issue #42 (2019-08-05)
  * Shows a single download progress bar when `*_code="all"`. 
  * This fixes the output of vignette

* New data sets/functions
  * New data set `read_indigenous_land` to read official data of indigenous lands of all ethnicities according to stage of demarcation - closes issue #47 (2019-09-04).
  * New data set `read_disaster_risk_area` to read official data of areas exposed to risks of geodynamic and hydro-meteorological disasters capable of triggering landslides and floods - closes issue #14 (added in 2019-09-24).
  * New data set `read_biomes` to read official data of polygons of all of all biomes present in Brazilian territory - closes issue #45 (added in 2019-09-24).
  * New function `download_metadata` simply the download of df with data set addresses.
  * New data set `read_amazon` to read official data of Brazil's Legal Amazon - closes issue #38 (added in 2019-10-07).
  * New data set `read_conservation_units` to read official data of Environmental Conservation Units - closes issue #59 (added in 2019-10-08).
  * New data set `read_urban_area` to read official data of urban footprint of Brazilian cities - closes issue #52 (added in 2019-10-17).
  * Changes to `read_region` function to improve speed and remove `dplyr`dependency (added in 2019-10-22).

