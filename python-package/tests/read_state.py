#!/usr/bin/env python
# coding: utf-8


import requests
import geopandas as gpd
import pandas as pd
import os
import tempfile
import sys

def download_metadata(
    url='http://www.ipea.gov.br/geobr/metadata/metadata_gpkg.csv'):
    """Support function to download metadata internally used in geobr.
    Parameters
    ----------
    url : str, optional
        Metadata url, by default 'http://www.ipea.gov.br/geobr/metadata/metadata_gpkg.csv'
    
    Returns
    -------
    pd.DataFrame
        Table with all metadata of geopackages
    
    Raises
    ------
    Exception
        Leads user to Github issue page if metadata url is not found
    Examples
    --------
    >>> metadata = download_metadata()
    >>> metadata.head(1)
                  geo  year code                                      download_path      code_abrev
    0  amazonia_legal  2012   am  http://www.ipea.gov.br/geobr/data_gpkg/amazoni...  amazonia_legal
    """

    try:
        return pd.read_csv(url)

    except HTTPError:
        raise Exception('Metadata file not found.             Please report to https://github.com/ipeaGIT/geobr/issues')



# Get metadata with data addresses
metadata = download_metadata()

# year = 2000

# mode = "simplified"

# Select geo
temp_meta = metadata.query('geo=="uf"')


# Select mode
if mode == "simplified":
    temp_meta = temp_meta[temp_meta['download_path'].str.contains("simplified")]
elif mode =="normal":
    temp_meta = temp_meta[~temp_meta['download_path'].str.contains("simplified")]
else:
    print("not a valid argument for mode")


# Verify year input
if year is None:
  print("Using data from year 2010\n")
  year = 2010
  temp_meta = temp_meta[temp_meta.year == 2010]
elif year in temp_meta.year.unique():
  temp_meta = temp_meta[temp_meta.year == year]
else:
  print("Error: Invalid Value to argument 'year'. It must be one of the following: ",temp_meta['year'].unique())
  sys.exit()


# BLOCK 2.1 From 1872 to 1991  ----------------------------
if year < 1992 :
    if code_mun is None:
        sys.exit("Value to argument 'code_state' cannot be NULL")
    print("Loading data for the whole country\n")

# list paths of files to download
    filesD = temp_meta.download_path
    


filesD = temp_meta.download_path

print(filesD)




