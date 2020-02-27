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