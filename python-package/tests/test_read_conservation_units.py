import geopandas as gpd
import pytest
from geobr import read_conservation_units


def test_read_conservation_units():

    assert isinstance(read_conservation_units(), gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_conservation_units(year=9999999)
