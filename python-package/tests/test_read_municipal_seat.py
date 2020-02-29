import geopandas as gpd
import pytest
from geobr import read_municipal_seat

def test_read_municipal_seat():

    assert isinstance(read_municipal_seat(), 
                      gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_municipal_seat(year=9999999)