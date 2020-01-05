# log history of geobr package development

-------------------------------------------------------
# geobr v1.0 (2019-07-30)

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
# geobr v1.1 (2019-12-03)

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
  * New data set of biomes (2019) available at scale 1:250.000. (added in 2019-10-31) - closes issue #72
  * New data set of `read_intermediate_region` (2017) (added in 2019-11-28)
  * New data set of `read_immediate_region` (2017) (added in 2019-11-28)


-------------------------------------------------------
# geobr dev v1.2

  * New function `lookup_muni` to look up municipality codes by their name, or the other way around (added in 2019-12)  - closes issue #58.
  * New data set `read_metro_area` to read official metropolitan areas - closes issue #2 (added in 2019-12).
  * New function `list_geobr` to list all the datasets available in geobr - Closes issue #57.
