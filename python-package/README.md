# geobr: Download Official Spatial Data Sets of Brazil 

<img align="right" src="https://github.com/ipeaGIT/geobr/blob/master/r-package/man/figures/geobr_logo_b.png?raw=true" alt="logo" width="140"> 
<img align="right" src="https://github.com/ipeaGIT/geobr/blob/master/r-package/man/figures/geobr_logo_y.png?raw=true" alt="logo" width="140">
<p align="justify">geobr is a computational package to download official spatial data sets of Brazil. The package includes a wide range of geospatial data in geopackage format (like shapefiles but better), available at various geographic scales and for various years with harmonized attributes, projection and topology (see detailed list of available data sets below). </p> 

## [READ FULL DOCS](https://github.com/ipeaGIT/geobr)

## Contribute

To start the development environment run

```sh
uv sync
```

Test with

`uv run pytest -n auto`

You can use a helper to translate a function from R.
If you want to add `read_biomes`, just run

```sh
uv run python helpers/translate_from_R.py read_biomes
```

It will scrape the original R function to get documentation and metadata.
It adds:
- default year
- function name
- documentation one liner
- larger documentation
- very basic tests

! Be aware that if the function that you are adding is more complicated than the template. So, always double check !




## Translation Status

| Function                  | Translated? | Easy? |
| ------------------------- | ----------- | ----- |
| read_amazon               | Yes         | Super |
| read_biomes               | Yes         | Super |
| read_census_tract         | Yes         | No    |
| read_comparable_areas     | Yes         | Yes   |
| read_conservation_units   | Yes         | Super |
| read_country              | Yes         | Super |
| read_disaster_risk_area   | Yes         | Super |
| read_health_facilities    | Yes         | Super |
| read_health_region        | Yes         | Super |
| read_immediate_region     | Yes         | Yes   |
| read_indigenous_land      | Yes         | Super |
| read_intermediate_region  | Yes         | Yes   |
| read_meso_region          | Yes         | No    |
| read_metro_area           | Yes         | Super |
| read_micro_region         | Yes         | No    |
| read_municipal_seat       | Yes         | Super |
| read_municipality         | Yes         | No    |
| read_region               | Yes         | Super |
| read_semiarid             | Yes         | Super |
| read_state                | Yes         | Super |
| read_statistical_grid     | Yes         | No    |
| read_urban_area           | Yes         | Super |
| read_urban_concentrations | Yes         | Super |
| read_weighting_area       | Yes         | No    |
| list_geobr                | Yes         | Yes   |
| lookup_muni               | Yes         | No    |
| read_neighborhood         | Yes         | Yes   |


# Release new version

```
poetry version [patch|minor|major]
poetry publish --build
```
