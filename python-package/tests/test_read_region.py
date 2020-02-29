import geopandas as gpd
import pytest
from geobr import read_region

def test_read_region():

    assert isinstance(read_region(), 
                      gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_region(year=9999999)