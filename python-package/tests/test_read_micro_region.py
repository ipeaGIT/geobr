import geopandas as gpd
import pytest
from geobr import read_micro_region

def test_read_micro_region():

    assert isinstance(read_micro_region(code_micro=11008), 
                      gpd.geodataframe.GeoDataFrame)
    assert isinstance(read_micro_region(code_micro="AC", year=2010), 
                      gpd.geodataframe.GeoDataFrame)
    assert isinstance(read_micro_region(code_micro=11, year=2010),
                      gpd.geodataframe.GeoDataFrame)
    assert isinstance(read_micro_region(code_micro="all", year=2010), 
                      gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):

        read_micro_region(year=9999999)

        read_micro_region(code_micro=9999999)