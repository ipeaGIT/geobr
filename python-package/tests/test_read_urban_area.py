import geopandas as gpd
import pytest
from geobr import read_urban_area


def test_read_urban_area():

    assert isinstance(read_urban_area(), gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_urban_area(year=9999999)
