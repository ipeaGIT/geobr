import geopandas as gpd
import pytest
from geobr import read_semiarid


def test_read_semiarid():

    assert isinstance(read_semiarid(), gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_semiarid(year=9999999)
