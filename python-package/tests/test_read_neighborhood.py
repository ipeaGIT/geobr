import geopandas as gpd
import pytest
from geobr import read_neighborhood


def test_read_neighborhood():

    assert isinstance(read_neighborhood(), gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_neighborhood(year=9999999)
