import geopandas as gpd
import pytest
from geobr import read_schools

def test_read_schools():

    assert isinstance(read_schools(), 
                      gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_schools(year=9999999)