import geopandas as gpd
import pytest
from geobr import read_metro_area


def test_read_metro_area():

    assert isinstance(read_metro_area(), gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_metro_area(year=9999999)
