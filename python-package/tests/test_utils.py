import pytest
import geobr
from time import time

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
