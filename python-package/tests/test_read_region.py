import geopandas as gpd
import pytest
from geobr import read_region


def test_read_region():

    gdf = read_region(2025)
    assert isinstance(gdf, gpd.geodataframe.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_region(year=9999999)
