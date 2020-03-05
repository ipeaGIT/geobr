# Geobr Python Version

## Behavior

```python
python
>>> import geobr
>>> geobr.read_biomes(year=2019)
```

## Contribute

To start the development environment run

```sh
make
. .env/bin/activate
```

Test with

`python -t pytest`

You can use a helper to translate a function from R.
If you want to add `read_biomes`, just run

`python helper/translate_from_R.py read_biomes`

It will scrape the original R function to get documentation and metadata.
It adds:
- default year
- function name
- documentation one liner
- larger documentation
- very basic tests

! Be aware that if the function that you are adding is more complicated than the template. So, double always double check !

#### For Windows

We recommend using conda  and creating an environment that includes all libraries simultaneously.

First create an environment and install Shapely and GDAL as such:

`conda create --name geobr_env python=3.7`

Activate the environmnet

`conda activate geobr_env`

Then add Shapely from conda-forge channel
 `conda install shapely gdal -c conda-forge`

Then the other packages 
`conda install fiona pandas geopandas requests -c conda-forge`

**Alternatively**, type on a terminal 

`conda create --name <env> --file conda_requirements.txt`

Finally, if **not** using conda, try:

`pip install -r pip_requirements.txt`

## Translation Status

|                          | Translated? | Easy? |
|--------------------------|-------------|-------|
| read_amazon              | Yes         | Super |
| read_biomes              | Yes         | Super |
| read_census_tract        |             | No    |
| read_conservation_units  | Yes         | Super |
| read_country             | Yes         | Super |
| read_disaster_risk_area  | Yes         | Super |
| read_health_facilities   | Yes         | Super |
| read_immediate_region    |             | Yes   |
| read_indigenous_land     | Yes         | Super |
| read_intermediate_region | Yes         | Yes   |
| read_meso_region         |             | No    |
| read_metro_area          | Yes         | Super |
| read_micro_region        |             | No    |
| read_municipal_seat      | Yes         | Super |
| read_municipality        |             | No    |
| read_region              | Yes         | Super |
| read_semiarid            | Yes         | Super |
| read_state               | Yes         | Super |
| read_statistical_grid    |             | No    |
| read_urban_area          | Yes         | Super |
| read_weighting_area      |             | No    |
| list_geobr               | Partialy    | Yes   |
| lookup_muni              |             | No    |