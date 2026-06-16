import geopandas as gpd
import pytest
from geobr import read_conservation_units


def test_read_conservation_units():

    gdf = read_conservation_units(202503)
    assert isinstance(gdf, gpd.geodataframe.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_conservation_units(year=9999999)
