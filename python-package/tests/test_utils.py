import pytest
from time import time
import pandas as pd
import geopandas as gpd

import geobr
from geobr.utils import apply_year, apply_data_type, download_gpkg, load_gpkg,\
    get_metadata


@pytest.fixture
def metadata_file():
    return geobr.utils.download_metadata()

def test_download_metadata(metadata_file):

    # Check if it fails if it doesn't find a file
    with pytest.raises(Exception):
        geobr.utils.download_metadata(
            url='http://www.ipea.gov.br/geobr/metadata/met')

    # Check if columns are the same
    assert (['geo', 'year', 'code', 'download_path', 'code_abrev'] == \
            metadata_file.columns).all()

    # Check if it has content
    assert len(metadata_file) > 0

def test_download_metadata_cache():
    
    # Check if cache works
    start_time = time()
    geobr.utils.download_metadata()
    assert time() - start_time < 1

def test_apply_year(): 

    metadata = pd.DataFrame([2004,2019], columns=["year"]) 
    
    assert apply_year(metadata, None)['year'].unique()[0] == 2019
    
    assert apply_year(metadata, 2004)['year'].unique()[0] == 2004
    
    with pytest.raises(Exception):
       assert apply_year(metadata, 2006)
       assert apply_year(metadata, 'as')
       assert apply_year(metadata, 2324.12)

def test_data_type():

    metadata = pd.DataFrame(['url_simplified', 'url'], 
                            columns=["download_path"]) 
    
    assert apply_data_type(metadata, 'simplified')['download_path'].unique()[0] \
            == 'url_simplified'
    
    assert apply_data_type(metadata, 'normal')['download_path'].unique()[0] \
            == 'url'
    
    with pytest.raises(Exception):
       assert apply_data_type(metadata, 'slified')
       assert apply_data_type(metadata, None)
       assert apply_data_type(metadata, 2324.12)

def test_load_gpkg():

    valid_url = 'http://www.ipea.gov.br/geobr/data_gpkg/amazonia_legal/2012/amazonia_legal.gpkg'

    assert isinstance(load_gpkg(valid_url), gpd.geodataframe.GeoDataFrame)
    
    # Test Cache
    start_time = time()
    load_gpkg(valid_url)
    assert time() - start_time < 1
    

    with pytest.raises(Exception):
        isinstance(load_gpkg('asd'), gpd.geodataframe.GeoDataFrame)
        isinstance(load_gpkg(1234), gpd.geodataframe.GeoDataFrame)
        isinstance(load_gpkg(valid_url + 'asdf'), 
                    gpd.geodataframe.GeoDataFrame)

def test_download_gpkg():

    multiple_metadata = pd.DataFrame([
        'http://www.ipea.gov.br/geobr/data_gpkg/amazonia_legal/2012/amazonia_legal.gpkg',
        'http://www.ipea.gov.br/geobr/data_gpkg/meso_regiao/2014/17ME_simplified.gpkg'], 
                            columns=["download_path"]) 

    single_metadata = pd.DataFrame([
        'http://www.ipea.gov.br/geobr/data_gpkg/amazonia_legal/2012/amazonia_legal.gpkg'],
                            columns=["download_path"]) 
 
    # assert isinstance(download_gpkg(multiple_metadata), 
    #                   gpd.geodataframe.GeoDataFrame)
    assert isinstance(download_gpkg(single_metadata), 
                      gpd.geodataframe.GeoDataFrame)

def test_get_metadata():

    assert isinstance(get_metadata('state', 'simplified', 2010), 
                    pd.core.frame.DataFrame)

    assert isinstance(get_metadata('state', 'simplified', None), 
                    pd.core.frame.DataFrame)

    assert isinstance(get_metadata('state', 'normal', None), 
                    pd.core.frame.DataFrame)

    with pytest.raises(Exception):
        get_metadata(123, 123, 123)
        get_metadata('state', 123, 123)
        get_metadata('state', 'simplified', 12334)
