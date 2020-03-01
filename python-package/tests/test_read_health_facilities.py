import geopandas as gpd
import pytest
from geobr import read_health_facilities

def test_read_health_facilities():

    assert isinstance(read_health_facilities(), 
                      gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_health_facilities(year=9999999)