import geopandas as gpd
import pytest
from geobr import read_amazon

def test_read_amazon():

    assert isinstance(read_amazon(), 
                      gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_amazon(year=9999999)