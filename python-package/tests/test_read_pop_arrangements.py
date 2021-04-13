import geopandas as gpd
import pytest
from geobr import read_pop_arrangements

def test_read_pop_arrangements():

    assert isinstance(read_pop_arrangements(), 
                      gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_pop_arrangements(year=9999999)