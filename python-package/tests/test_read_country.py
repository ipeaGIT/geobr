import geopandas as gpd
import pytest
from geobr import read_country

def test_read_country():

    assert isinstance(read_country(), 
                      gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_country(year=9999999)