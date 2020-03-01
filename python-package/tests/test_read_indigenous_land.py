import geopandas as gpd
import pytest
from geobr import read_indigenous_land

def test_read_indigenous_land():

    assert isinstance(read_indigenous_land(), 
                      gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_indigenous_land(year=9999999)