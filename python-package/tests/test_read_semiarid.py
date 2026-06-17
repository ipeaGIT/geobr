import geopandas as gpd
import pytest
from geobr import read_semiarid


def test_read_semiarid():

    gdf = read_semiarid(2022)
    assert isinstance(gdf, gpd.geodataframe.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_semiarid(year=9999999)
