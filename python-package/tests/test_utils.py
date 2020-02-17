import pytest
import geobr
from time import time
from geobr.utils import apply_year, apply_tp
import pandas as pd

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

def test_tp():

    metadata = pd.DataFrame(['url_simplified', 'url'], 
                            columns=["download_path"]) 
    
    assert apply_tp(metadata, 'simplified')['download_path'].unique()[0] \
            == 'url_simplified'
    
    assert apply_tp(metadata, 'normal')['download_path'].unique()[0] \
            == 'url'
    
    with pytest.raises(Exception):
       assert apply_tp(metadata, 'slified')
       assert apply_tp(metadata, None)
       assert apply_tp(metadata, 2324.12)