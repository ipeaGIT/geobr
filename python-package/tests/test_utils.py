import pytest
import pandas as pd
import geobr

@pytest.fixture
def metadata_file():
    return geobr.utils.download_metadata()

def test_utils(metadata_file):

    # Check if it fails if it doesn't find a file
    with pytest.raises(Exception):
        geobr.utils.download_metadata(
            url='http://www.ipea.gov.br/geobr/metadata/met')

    # Check if columns are the same
    assert (['geo', 'year', 'code', 'download_path', 'code_abrev'] == \
            metadata_file.columns).all()

    # Check if it has content
    assert len(metadata_file) > 0