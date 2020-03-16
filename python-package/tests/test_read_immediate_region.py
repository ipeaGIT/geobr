import geopandas as gpd
import pytest
from geobr import read_immediate_region

def test_read_immediate_region():

    assert isinstance(read_immediate_region(), 
                      gpd.geodataframe.GeoDataFrame)

    assert isinstance(read_immediate_region(code_immediate=11), 
                      gpd.geodataframe.GeoDataFrame)

    assert isinstance(read_immediate_region(code_immediate='AC'), 
                      gpd.geodataframe.GeoDataFrame)

    assert len(read_immediate_region(code_immediate=110002).columns) == 8

    with pytest.raises(Exception):
        read_immediate_region(year=9999999)
        read_immediate_region(code_intermediate=5201108312313213)